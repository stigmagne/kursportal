-- Migration 009: Quiz System
-- Adds comprehensive quiz functionality with questions, answers, and attempt tracking

-- ============================================================================
-- TABLES
-- ============================================================================

-- Quizzes table
CREATE TABLE IF NOT EXISTS public.quizzes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id UUID REFERENCES public.lessons(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    passing_score INTEGER NOT NULL DEFAULT 70, -- percentage 0-100
    time_limit_minutes INTEGER, -- NULL = no time limit
    shuffle_questions BOOLEAN DEFAULT false,
    shuffle_answers BOOLEAN DEFAULT true,
    show_correct_answers BOOLEAN DEFAULT true, -- show after completion
    required_for_completion BOOLEAN DEFAULT false, -- must pass to complete lesson
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Quiz questions
CREATE TABLE IF NOT EXISTS public.quiz_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quiz_id UUID NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type TEXT NOT NULL CHECK (question_type IN ('multiple_choice', 'true_false')),
    order_index INTEGER NOT NULL,
    points INTEGER DEFAULT 1, -- for weighted scoring
    explanation TEXT, -- shown after answering
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Answer options (for multiple choice and true/false)
CREATE TABLE IF NOT EXISTS public.quiz_answer_options (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID NOT NULL REFERENCES public.quiz_questions(id) ON DELETE CASCADE,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT false,
    order_index INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Student quiz attempts
CREATE TABLE IF NOT EXISTS public.quiz_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quiz_id UUID NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    score DECIMAL(5,2) NOT NULL, -- percentage 0-100.00
    total_points INTEGER NOT NULL,
    earned_points INTEGER NOT NULL,
    passed BOOLEAN NOT NULL,
    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ NOT NULL,
    answers JSONB NOT NULL, -- { "question_id": "answer_id", ... }
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_quizzes_lesson ON public.quizzes(lesson_id);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz ON public.quiz_questions(quiz_id, order_index);
CREATE INDEX IF NOT EXISTS idx_quiz_answer_options_question ON public.quiz_answer_options(question_id, order_index);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user_quiz ON public.quiz_attempts(user_id, quiz_id, created_at DESC);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_answer_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_attempts ENABLE ROW LEVEL SECURITY;

-- Quizzes: Students can view, admins can manage
CREATE POLICY "Anyone can view quizzes" ON public.quizzes 
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage quizzes" ON public.quizzes 
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- Questions: Students can view, admins can manage
CREATE POLICY "Anyone can view quiz questions" ON public.quiz_questions 
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage questions" ON public.quiz_questions 
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- Answer options: Students can view, admins can manage
CREATE POLICY "Anyone can view answer options" ON public.quiz_answer_options 
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage answers" ON public.quiz_answer_options 
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- Attempts: Users can create own, view own; admins can view all
CREATE POLICY "Users can create own attempts" ON public.quiz_attempts 
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own attempts" ON public.quiz_attempts 
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all attempts" ON public.quiz_attempts 
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to get best quiz score for a user
CREATE OR REPLACE FUNCTION get_best_quiz_score(p_user_id UUID, p_quiz_id UUID)
RETURNS DECIMAL AS $$
DECLARE
    v_best_score DECIMAL;
BEGIN
    SELECT COALESCE(MAX(score), 0) INTO v_best_score
    FROM quiz_attempts
    WHERE user_id = p_user_id AND quiz_id = p_quiz_id;
    
    RETURN v_best_score;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user passed quiz
CREATE OR REPLACE FUNCTION has_passed_quiz(p_user_id UUID, p_quiz_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_passed BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM quiz_attempts
        WHERE user_id = p_user_id 
        AND quiz_id = p_quiz_id 
        AND passed = true
    ) INTO v_passed;
    
    RETURN v_passed;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE public.quizzes IS 'Quizzes embedded in lessons for assessment';
COMMENT ON TABLE public.quiz_questions IS 'Questions within quizzes';
COMMENT ON TABLE public.quiz_answer_options IS 'Answer options for quiz questions';
COMMENT ON TABLE public.quiz_attempts IS 'Student quiz attempt history and scores';
