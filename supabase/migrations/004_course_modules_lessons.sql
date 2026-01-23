-- Migration 004: Course Modules & Lessons (LMS Phase 1)
-- Transforms flat courses into hierarchical structure with modules and lessons

-- ============================================
-- 1. COURSE MODULES (Sections/Chapters)
-- ============================================
CREATE TABLE IF NOT EXISTS public.course_modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    order_index INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(course_id, order_index)
);

CREATE INDEX idx_course_modules_course ON public.course_modules(course_id);
CREATE INDEX idx_course_modules_order ON public.course_modules(course_id, order_index);

-- ============================================
-- 2. LESSONS (Individual content units)
-- ============================================
CREATE TABLE IF NOT EXISTS public.lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    module_id UUID NOT NULL REFERENCES public.course_modules(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    order_index INTEGER NOT NULL DEFAULT 0,
    duration_minutes INTEGER, -- Estimated time to complete
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(module_id, order_index)
);

CREATE INDEX idx_lessons_module ON public.lessons(module_id);
CREATE INDEX idx_lessons_order ON public.lessons(module_id, order_index);

-- ============================================
-- 3. LESSON CONTENT (Multiple content types per lesson)
-- ============================================
CREATE TYPE content_type AS ENUM ('text', 'video', 'quiz', 'file');

CREATE TABLE IF NOT EXISTS public.lesson_content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    type content_type NOT NULL,
    order_index INTEGER NOT NULL DEFAULT 0,
    
    -- Content fields (use appropriate field based on type)
    text_content TEXT, -- For type = 'text', supports markdown
    video_url TEXT, -- For type = 'video', YouTube/Vimeo URLs
    quiz_id UUID REFERENCES public.quizzes(id) ON DELETE SET NULL, -- For type = 'quiz'
    file_url TEXT, -- For type = 'file', Supabase storage URL
    file_name TEXT,
    file_size_bytes BIGINT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(lesson_id, order_index)
);

CREATE INDEX idx_lesson_content_lesson ON public.lesson_content(lesson_id);

-- ============================================
-- 4. LESSON PREREQUISITES (Unlock logic)
-- ============================================
CREATE TABLE IF NOT EXISTS public.lesson_prerequisites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    prerequisite_lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(lesson_id, prerequisite_lesson_id),
    CHECK (lesson_id != prerequisite_lesson_id) -- Can't be prerequisite of itself
);

CREATE INDEX idx_lesson_prereqs_lesson ON public.lesson_prerequisites(lesson_id);

-- ============================================
-- 5. LESSON COMPLETION (Track individual lesson progress)
-- ============================================
CREATE TABLE IF NOT EXISTS public.lesson_completion (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, lesson_id)
);

CREATE INDEX idx_lesson_completion_user ON public.lesson_completion(user_id);
CREATE INDEX idx_lesson_completion_lesson ON public.lesson_completion(lesson_id);

-- ============================================
-- 6. DRIP SCHEDULES (Timed content release)
-- ============================================
CREATE TYPE drip_type AS ENUM ('days_after_enrollment', 'specific_date');

CREATE TABLE IF NOT EXISTS public.drip_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    type drip_type NOT NULL,
    
    -- For 'days_after_enrollment'
    days_after_enrollment INTEGER,
    
    -- For 'specific_date'
    unlock_date TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(lesson_id),
    CHECK (
        (type = 'days_after_enrollment' AND days_after_enrollment IS NOT NULL AND unlock_date IS NULL) OR
        (type = 'specific_date' AND unlock_date IS NOT NULL AND days_after_enrollment IS NULL)
    )
);

CREATE INDEX idx_drip_schedules_lesson ON public.drip_schedules(lesson_id);

-- ============================================
-- 7. ROW LEVEL SECURITY (RLS)
-- ============================================

-- Modules: Admins full access, users read enrolled courses
ALTER TABLE public.course_modules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage modules" ON public.course_modules
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

CREATE POLICY "Users can view modules of enrolled courses" ON public.course_modules
    FOR SELECT USING (true); -- Will be restricted by course enrollment check in app

-- Lessons: Same as modules
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage lessons" ON public.lessons
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

CREATE POLICY "Users can view lessons" ON public.lessons
    FOR SELECT USING (true);

-- Lesson Content
ALTER TABLE public.lesson_content ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage lesson content" ON public.lesson_content
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

CREATE POLICY "Users can view lesson content" ON public.lesson_content
    FOR SELECT USING (true);

-- Lesson Prerequisites
ALTER TABLE public.lesson_prerequisites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage prerequisites" ON public.lesson_prerequisites
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

CREATE POLICY "Users can view prerequisites" ON public.lesson_prerequisites
    FOR SELECT USING (true);

-- Lesson Completion: Users can only manage their own
ALTER TABLE public.lesson_completion ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own completions" ON public.lesson_completion
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Admins can view all completions" ON public.lesson_completion
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

-- Drip Schedules
ALTER TABLE public.drip_schedules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage drip schedules" ON public.drip_schedules
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

CREATE POLICY "Users can view drip schedules" ON public.drip_schedules
    FOR SELECT USING (true);

-- ============================================
-- 8. HELPER FUNCTIONS
-- ============================================

-- Function to calculate module completion percentage for a user
CREATE OR REPLACE FUNCTION get_module_completion_pct(p_user_id UUID, p_module_id UUID)
RETURNS INTEGER AS $$
DECLARE
    total_lessons INTEGER;
    completed_lessons INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_lessons
    FROM public.lessons
    WHERE module_id = p_module_id;
    
    IF total_lessons = 0 THEN
        RETURN 100; -- Empty module is 100% complete
    END IF;
    
    SELECT COUNT(*) INTO completed_lessons
    FROM public.lesson_completion lc
    JOIN public.lessons l ON l.id = lc.lesson_id
    WHERE l.module_id = p_module_id 
    AND lc.user_id = p_user_id 
    AND lc.completed = true;
    
    RETURN (completed_lessons * 100 / total_lessons);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if lesson is unlocked for user
CREATE OR REPLACE FUNCTION is_lesson_unlocked(p_user_id UUID, p_lesson_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    prereq_count INTEGER;
    completed_prereq_count INTEGER;
    drip_unlock TIMESTAMPTZ;
    enrollment_date TIMESTAMPTZ;
BEGIN
    -- Check prerequisites
    SELECT COUNT(*) INTO prereq_count
    FROM public.lesson_prerequisites
    WHERE lesson_id = p_lesson_id;
    
    IF prereq_count > 0 THEN
        SELECT COUNT(*) INTO completed_prereq_count
        FROM public.lesson_prerequisites lp
        JOIN public.lesson_completion lc ON lc.lesson_id = lp.prerequisite_lesson_id
        WHERE lp.lesson_id = p_lesson_id 
        AND lc.user_id = p_user_id 
        AND lc.completed = true;
        
        IF completed_prereq_count < prereq_count THEN
            RETURN false;
        END IF;
    END IF;
    
    -- Check drip schedule (implementation pending - needs enrollments table)
    -- For now, return true if prerequisites are met
    
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON TABLE public.course_modules IS 'Modules/sections that organize lessons within a course';
COMMENT ON TABLE public.lessons IS 'Individual lessons containing different types of content';
COMMENT ON TABLE public.lesson_content IS 'Content blocks within lessons (video, text, quiz, files)';
COMMENT ON TABLE public.lesson_prerequisites IS 'Prerequisites that must be completed to unlock a lesson';
COMMENT ON TABLE public.lesson_completion IS 'Tracks which lessons users have completed';
COMMENT ON TABLE public.drip_schedules IS 'Controls when lessons become available based on time';
