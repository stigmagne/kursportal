-- Migration 099: Add Case Study Content Type (Schema Only)
-- Adds 'case_study' to content_type enum and adds storage column

-- 1. Add 'case_study' to content_type enum
-- Postgres doesn't support IF NOT EXISTS for enum values directly in a simple way in older versions, 
-- but we can use a safe block.
DO $$
BEGIN
    ALTER TYPE content_type ADD VALUE IF NOT EXISTS 'case_study';
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Add case_study_data column to lesson_content
ALTER TABLE public.lesson_content
ADD COLUMN IF NOT EXISTS case_study_data JSONB;

COMMENT ON COLUMN public.lesson_content.case_study_data IS 'Structured data for case studies: { "situation": "...", "reflection": "...", "learning_point": "..." }';
