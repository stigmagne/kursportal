-- Migration 008: Fix lesson_completion duplicates
-- Add unique constraint to prevent duplicate completions

-- First, clean up any existing duplicates
DELETE FROM lesson_completion a
USING lesson_completion b
WHERE a.id > b.id
AND a.user_id = b.user_id
AND a.lesson_id = b.lesson_id;

-- Add unique constraint
ALTER TABLE lesson_completion
ADD CONSTRAINT unique_user_lesson UNIQUE (user_id, lesson_id);

-- Drop old index (replaced by unique constraint)
DROP INDEX IF EXISTS idx_lesson_completion_user_lesson;

-- Create index for performance (unique constraint already handles uniqueness)
CREATE INDEX IF NOT EXISTS idx_lesson_completion_user_lesson 
ON lesson_completion(user_id, lesson_id);
