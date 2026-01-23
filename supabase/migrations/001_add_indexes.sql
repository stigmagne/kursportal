-- Performance Indexes Migration
-- Add indexes to frequently queried foreign keys and lookup columns

-- Courses indexes
CREATE INDEX IF NOT EXISTS idx_courses_author ON public.courses(author_id);
CREATE INDEX IF NOT EXISTS idx_courses_published ON public.courses(published) WHERE published = true;

-- Quizzes indexes
CREATE INDEX IF NOT EXISTS idx_quizzes_course ON public.quizzes(course_id);

-- User Progress indexes
CREATE INDEX IF NOT EXISTS idx_progress_user ON public.user_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_progress_course ON public.user_progress(course_id);
CREATE INDEX IF NOT EXISTS idx_progress_status ON public.user_progress(status);

-- Journals indexes
CREATE INDEX IF NOT EXISTS idx_journals_user ON public.journals(user_id);
CREATE INDEX IF NOT EXISTS idx_journals_created ON public.journals(created_at DESC);

-- Composite index for common query pattern
CREATE INDEX IF NOT EXISTS idx_progress_user_status ON public.user_progress(user_id, status);
