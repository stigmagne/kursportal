-- Migration: Fix admin SELECT access for courses and lessons
-- Problem: Migration 062 removed admin SELECT by splitting FOR ALL into INSERT/UPDATE/DELETE only
-- This caused 404 errors when admins try to view courses/lessons

-- ============================================================================
-- Add admin SELECT policies for courses and lessons
-- ============================================================================

-- Courses: Admin must be able to see ALL courses (including unpublished)
DROP POLICY IF EXISTS "Admins can view all courses" ON courses;
CREATE POLICY "Admins can view all courses" ON courses
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- Lessons: Admin must be able to see ALL lessons
DROP POLICY IF EXISTS "Admins can view all lessons" ON lessons;
CREATE POLICY "Admins can view all lessons" ON lessons
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- End of migration
