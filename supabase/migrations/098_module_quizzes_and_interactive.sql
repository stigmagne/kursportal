-- Migration 098: Module Quizzes and Interactive Elements
-- Adds support for quizzes attached to modules and drag-and-drop questions

-- 1. Add module_id to quizzes table
ALTER TABLE public.quizzes
ADD COLUMN IF NOT EXISTS module_id UUID REFERENCES public.course_modules(id) ON DELETE CASCADE;

-- Create index for module_id
CREATE INDEX IF NOT EXISTS idx_quizzes_module ON public.quizzes(module_id);

-- 2. Update question_type check constraint
ALTER TABLE public.quiz_questions
DROP CONSTRAINT IF EXISTS quiz_questions_question_type_check;

ALTER TABLE public.quiz_questions
ADD CONSTRAINT quiz_questions_question_type_check 
CHECK (question_type IN ('multiple_choice', 'true_false', 'short_answer', 'drag_and_drop'));

-- 3. Add match_text to quiz_answer_options for matching pairs
-- For drag_and_drop: option_text is the "draggable" item, match_text is the "drop target" (or vice versa depending on UI implementation)
ALTER TABLE public.quiz_answer_options
ADD COLUMN IF NOT EXISTS match_text TEXT;

-- 4. Comments
COMMENT ON COLUMN public.quizzes.module_id IS 'Link to module if this is a module-level quiz (not lesson-specific)';
COMMENT ON COLUMN public.quiz_answer_options.match_text IS 'Target text for drag-and-drop matching pairs';
