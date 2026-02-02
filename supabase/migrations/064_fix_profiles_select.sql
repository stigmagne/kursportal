-- Migration: Fix profiles SELECT access
-- Problem: Migration 061 dropped "Anyone can read profiles" assuming 
-- "Public profiles are viewable by everyone" existed, but it may not.
-- This breaks admin role checks since profiles can't be queried.

-- Re-create a SELECT policy for profiles so role checks work
CREATE POLICY IF NOT EXISTS "Users can view profiles" ON profiles
    FOR SELECT USING (true);

-- Also ensure lessons has proper SELECT for authorized users
DROP POLICY IF EXISTS "Lessons visible to course-authorized users" ON lessons;
CREATE POLICY "Lessons visible to course-authorized users" ON lessons
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses c
            JOIN course_groups cg ON cg.course_id = c.id
            JOIN profiles p ON p.group_id = cg.group_id
            WHERE c.id = lessons.course_id
            AND p.id = (select auth.uid())
            AND c.published = true
        )
        OR EXISTS (
            SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin'
        )
    );

-- End of migration
