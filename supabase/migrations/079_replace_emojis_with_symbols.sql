-- Migration: 079_replace_emojis_with_symbols.sql
-- Purpose: Replace emojis in lesson content with clean Unicode symbols
-- This creates a neo-brutalist aesthetic with simple, clear markers

-- Replace emojis in lessons.content column
UPDATE lessons
SET content = regexp_replace(content, '✅\s*', '✓ ', 'g')
WHERE content LIKE '%✅%';

UPDATE lessons
SET content = regexp_replace(content, '❌\s*', '✗ ', 'g')
WHERE content LIKE '%❌%';

-- Also update any lesson_content blocks (text_content column)
UPDATE lesson_content
SET text_content = regexp_replace(text_content, '✅', '✓', 'g')
WHERE text_content LIKE '%✅%';

UPDATE lesson_content
SET text_content = regexp_replace(text_content, '❌', '✗', 'g')
WHERE text_content LIKE '%❌%';

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Migration 079 completed: Replaced ✅/❌ emojis with ✓/✗ symbols';
END $$;
