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

-- Also update any lesson_content blocks if they exist
UPDATE lesson_content
SET data = regexp_replace(data::text, '✅', '✓', 'g')::jsonb
WHERE data::text LIKE '%✅%';

UPDATE lesson_content
SET data = regexp_replace(data::text, '❌', '✗', 'g')::jsonb
WHERE data::text LIKE '%❌%';

-- Update journal_tools if they use emojis (optional - for icon column)
-- Skip this as icons may need different handling

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Migration 079 completed: Replaced ✅/❌ emojis with ✓/✗ symbols';
END $$;
