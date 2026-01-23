-- Migration 030: Seed target groups and fix data
-- Ensures that courses and users have necessary data for access control to work

-- 1. Ensure all published courses have target groups set
-- We enable all categories for existing courses to ensure visibility
UPDATE courses 
SET target_groups = ARRAY['søsken', 'foreldre', 'helsepersonell']::TEXT[]
WHERE published = true 
AND (target_groups IS NULL OR target_groups = '{}');

-- 2. Ensure profiles (especially test users) have a category
-- If a user has no category, default to 'søsken' (safest bet for testing)
UPDATE profiles 
SET user_category = 'søsken'
WHERE user_category IS NULL 
AND role != 'admin';

-- 3. Ensure test user (if exists via email) has a category
-- Adjust email if needed, assuming 'test@example.com' or similar if known
-- But the generic update above covers it.

-- 4. Verify/Fix specific test user if identifiable
-- (Optional: Add specific logic if we knew the ID)

-- 5. Force update search vector for courses to include target groups if we index them?
-- (Not strictly needed for RLS, but might affect search if we filter by it)

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Migration 030 completed: Target groups seeded for courses and profiles updated';
END $$;
