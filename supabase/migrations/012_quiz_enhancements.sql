-- Migration 012: Quiz Enhancements
-- Add support for media in questions and short answer type

-- ============================================================================
-- ALTER QUIZ_QUESTIONS TABLE
-- ============================================================================

-- Add media support to questions
ALTER TABLE public.quiz_questions 
ADD COLUMN IF NOT EXISTS image_url TEXT,
ADD COLUMN IF NOT EXISTS video_url TEXT;

-- Update question_type enum to include short_answer
-- Note: PostgreSQL doesn't allow direct enum modification, so we'll use constraint
ALTER TABLE public.quiz_questions
DROP CONSTRAINT IF EXISTS quiz_questions_question_type_check;

ALTER TABLE public.quiz_questions
ADD CONSTRAINT quiz_questions_question_type_check 
CHECK (question_type IN ('multiple_choice', 'true_false', 'short_answer'));

-- ============================================================================
-- ALTER QUIZ_ATTEMPTS TABLE
-- ============================================================================

-- Add column to store student's text answers for short answer questions
ALTER TABLE public.quiz_attempts
ADD COLUMN IF NOT EXISTS text_answers JSONB DEFAULT '{}'::jsonb;

-- Add column to track grading status
ALTER TABLE public.quiz_attempts
ADD COLUMN IF NOT EXISTS grading_status TEXT DEFAULT 'auto_graded'
CHECK (grading_status IN ('auto_graded', 'pending_review', 'manually_graded'));

-- Add columns for manual grading
ALTER TABLE public.quiz_attempts
ADD COLUMN IF NOT EXISTS graded_by UUID REFERENCES auth.users(id),
ADD COLUMN IF NOT EXISTS graded_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS grading_notes TEXT;

-- ============================================================================
-- CREATE SHORT ANSWER RESPONSES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.quiz_short_answer_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    attempt_id UUID NOT NULL REFERENCES public.quiz_attempts(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES public.quiz_questions(id) ON DELETE CASCADE,
    student_answer TEXT NOT NULL,
    points_awarded DECIMAL DEFAULT 0,
    max_points DECIMAL NOT NULL,
    feedback TEXT,
    graded_by UUID REFERENCES auth.users(id),
    graded_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_short_answer_attempt ON public.quiz_short_answer_responses(attempt_id);
CREATE INDEX IF NOT EXISTS idx_short_answer_question ON public.quiz_short_answer_responses(question_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_grading_status ON public.quiz_attempts(grading_status);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.quiz_short_answer_responses ENABLE ROW LEVEL SECURITY;

-- Students can view their own responses
CREATE POLICY "Students can view own responses" ON public.quiz_short_answer_responses
    FOR SELECT USING (
        attempt_id IN (
            SELECT id FROM public.quiz_attempts WHERE user_id = auth.uid()
        )
    );

-- Students can insert their own responses
CREATE POLICY "Students can insert own responses" ON public.quiz_short_answer_responses
    FOR INSERT WITH CHECK (
        attempt_id IN (
            SELECT id FROM public.quiz_attempts WHERE user_id = auth.uid()
        )
    );

-- Admins can manage all responses
CREATE POLICY "Admins can manage responses" ON public.quiz_short_answer_responses
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Get pending grading attempts
CREATE OR REPLACE FUNCTION get_pending_grading_attempts()
RETURNS TABLE (
    attempt_id UUID,
    student_name TEXT,
    quiz_title TEXT,
    course_title TEXT,
    submitted_at TIMESTAMPTZ,
    pending_questions INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        qa.id as attempt_id,
        p.full_name as student_name,
        q.title as quiz_title,
        c.title as course_title,
        qa.completed_at as submitted_at,
        COUNT(qsar.id)::INTEGER as pending_questions
    FROM public.quiz_attempts qa
    JOIN public.profiles p ON qa.user_id = p.id
    JOIN public.quizzes q ON qa.quiz_id = q.id
    JOIN public.lessons l ON q.lesson_id = l.id
    JOIN public.course_modules cm ON l.module_id = cm.id
    JOIN public.courses c ON cm.course_id = c.id
    LEFT JOIN public.quiz_short_answer_responses qsar ON qa.id = qsar.attempt_id AND qsar.graded_at IS NULL
    WHERE qa.grading_status = 'pending_review'
    GROUP BY qa.id, p.full_name, q.title, c.title, qa.completed_at
    ORDER BY qa.completed_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grade short answer response
CREATE OR REPLACE FUNCTION grade_short_answer(
    p_response_id UUID,
    p_points DECIMAL,
    p_feedback TEXT,
    p_grader_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_attempt_id UUID;
    v_all_graded BOOLEAN;
BEGIN
    -- Update the response
    UPDATE public.quiz_short_answer_responses
    SET 
        points_awarded = p_points,
        feedback = p_feedback,
        graded_by = p_grader_id,
        graded_at = NOW()
    WHERE id = p_response_id
    RETURNING attempt_id INTO v_attempt_id;

    -- Check if all short answers for this attempt are graded
    SELECT NOT EXISTS (
        SELECT 1 FROM public.quiz_short_answer_responses
        WHERE attempt_id = v_attempt_id AND graded_at IS NULL
    ) INTO v_all_graded;

    -- If all graded, update attempt status and recalculate score
    IF v_all_graded THEN
        -- Recalculate total score including short answer points
        -- (Implementation depends on scoring logic - simplified here)
        UPDATE public.quiz_attempts
        SET 
            grading_status = 'manually_graded',
            graded_by = p_grader_id,
            graded_at = NOW()
        WHERE id = v_attempt_id;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- PERMISSIONS
-- ============================================================================

GRANT EXECUTE ON FUNCTION get_pending_grading_attempts() TO authenticated;
GRANT EXECUTE ON FUNCTION grade_short_answer(UUID, DECIMAL, TEXT, UUID) TO authenticated;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON COLUMN public.quiz_questions.image_url IS 'URL to image displayed with question';
COMMENT ON COLUMN public.quiz_questions.video_url IS 'URL to video displayed with question';
COMMENT ON TABLE public.quiz_short_answer_responses IS 'Student responses to short answer questions requiring manual grading';
COMMENT ON FUNCTION get_pending_grading_attempts() IS 'Returns quiz attempts awaiting manual grading';
COMMENT ON FUNCTION grade_short_answer(UUID, DECIMAL, TEXT, UUID) IS 'Grade a short answer response and update attempt if all graded';
