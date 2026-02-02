-- Migration: Consolidate Multiple Permissive RLS Policies
-- This migration removes duplicate/overlapping RLS policies to fix
-- "multiple_permissive_policies" warnings from Supabase Performance Advisor
-- 
-- Strategy: When "Anyone can view" or "Users can view" policies exist,
-- remove overlapping admin SELECT policies (admin access via FOR ALL is sufficient)

-- ============================================================================
-- GRUPPE 1: Tables with "Anyone can view" + "Admins can manage" overlap
-- Remove admin SELECT since anyone-can-view already covers it
-- ============================================================================

-- assessment_dimensions: "Admins can manage dimensions" overlaps with "Anyone can view"
DROP POLICY IF EXISTS "Admins can manage dimensions" ON assessment_dimensions;
CREATE POLICY "Admins can manage dimensions" ON assessment_dimensions
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- assessment_questions: Same pattern
DROP POLICY IF EXISTS "Admins can manage questions" ON assessment_questions;
CREATE POLICY "Admins can manage questions" ON assessment_questions
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- assessment_types: Same pattern
DROP POLICY IF EXISTS "Admins can manage all assessment data" ON assessment_types;
CREATE POLICY "Admins can manage all assessment data" ON assessment_types
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- categories: "Admins can manage categories" overlaps with "Anyone can view categories"
DROP POLICY IF EXISTS "Admins can manage categories" ON categories;
CREATE POLICY "Admins can manage categories" ON categories
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- course_categories
DROP POLICY IF EXISTS "Admins can manage course categories" ON course_categories;
CREATE POLICY "Admins can manage course categories" ON course_categories
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- course_groups
DROP POLICY IF EXISTS "Admins can manage course groups" ON course_groups;
CREATE POLICY "Admins can manage course groups" ON course_groups
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- course_tags
DROP POLICY IF EXISTS "Admins can manage course tags" ON course_tags;
CREATE POLICY "Admins can manage course tags" ON course_tags
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- course_user_categories
DROP POLICY IF EXISTS "Admins can manage course category assignments" ON course_user_categories;
CREATE POLICY "Admins can manage course category assignments" ON course_user_categories
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- email_templates
DROP POLICY IF EXISTS "Admins can manage email templates" ON email_templates;
CREATE POLICY "Admins can manage email templates" ON email_templates
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- groups
DROP POLICY IF EXISTS "Admins can manage groups" ON groups;
CREATE POLICY "Admins can manage groups" ON groups
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- invitations
DROP POLICY IF EXISTS "Admins can manage invitations" ON invitations;
CREATE POLICY "Admins can manage invitations" ON invitations
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- journal_tool_types
DROP POLICY IF EXISTS "Admins can manage tool types" ON journal_tool_types;
CREATE POLICY "Admins can manage tool types" ON journal_tool_types
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- journal_tools
DROP POLICY IF EXISTS "Admins can manage tools" ON journal_tools;
CREATE POLICY "Admins can manage tools" ON journal_tools
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- lesson_content
DROP POLICY IF EXISTS "Admins can manage lesson content" ON lesson_content;
CREATE POLICY "Admins can manage lesson content" ON lesson_content
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- lesson_prerequisites
DROP POLICY IF EXISTS "Admins can manage prerequisites" ON lesson_prerequisites;
CREATE POLICY "Admins can manage prerequisites" ON lesson_prerequisites
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- quiz_answer_options
DROP POLICY IF EXISTS "Admins can manage answers" ON quiz_answer_options;
CREATE POLICY "Admins can manage answers" ON quiz_answer_options
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- quiz_questions
DROP POLICY IF EXISTS "Admins can manage questions" ON quiz_questions;
CREATE POLICY "Admins can manage questions" ON quiz_questions
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- tags
DROP POLICY IF EXISTS "Admins can manage tags" ON tags;
CREATE POLICY "Admins can manage tags" ON tags
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- drip_schedules
DROP POLICY IF EXISTS "Admins can manage drip schedules" ON drip_schedules;
CREATE POLICY "Admins can manage drip schedules" ON drip_schedules
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- course_modules
DROP POLICY IF EXISTS "Admins can manage modules" ON course_modules;
CREATE POLICY "Admins can manage modules" ON course_modules
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- GRUPPE 2: Tables with duplicate user policies - consolidate into one
-- ============================================================================

-- certificates: Multiple INSERT and SELECT policies
DROP POLICY IF EXISTS "Users can create own certificates" ON certificates;
DROP POLICY IF EXISTS "Users can view own certificates" ON certificates;
DROP POLICY IF EXISTS "Admins can manage certificates" ON certificates;

CREATE POLICY "Users can manage own certificates" ON certificates
    FOR ALL USING (
        user_id = (select auth.uid())
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        user_id = (select auth.uid())
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- lesson_completion: "Admins can view all completions" + "Users can manage own completions"
DROP POLICY IF EXISTS "Admins can view all completions" ON lesson_completion;
DROP POLICY IF EXISTS "Users can manage own completions" ON lesson_completion;

CREATE POLICY "Users can manage own completions" ON lesson_completion
    FOR ALL USING (
        user_id = (select auth.uid())
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        user_id = (select auth.uid())
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- lesson_comments: "Authenticated users can create comments" + "Users can create comments"
DROP POLICY IF EXISTS "Authenticated users can create comments" ON lesson_comments;
DROP POLICY IF EXISTS "Users can create comments" ON lesson_comments;

CREATE POLICY "Users can create comments" ON lesson_comments
    FOR INSERT WITH CHECK (
        auth.uid() IS NOT NULL
    );

-- email_queue: "Admins can view all email queue" + "Users can view own email queue"
DROP POLICY IF EXISTS "Admins can view all email queue" ON email_queue;
DROP POLICY IF EXISTS "Users can view own email queue" ON email_queue;

CREATE POLICY "View email queue" ON email_queue
    FOR SELECT USING (
        user_id = (select auth.uid())
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- GRUPPE 3: quiz_attempts - Multiple overlapping policies
-- ============================================================================

DROP POLICY IF EXISTS "Users can create own attempts" ON quiz_attempts;
DROP POLICY IF EXISTS "Users can create own quiz attempts" ON quiz_attempts;
DROP POLICY IF EXISTS "Admins can view all attempts" ON quiz_attempts;
DROP POLICY IF EXISTS "Admins can view all quiz attempts" ON quiz_attempts;
DROP POLICY IF EXISTS "Users can view own quiz attempts" ON quiz_attempts;
DROP POLICY IF EXISTS "Users can view quiz attempts in their subgroup" ON quiz_attempts;

CREATE POLICY "Users can create quiz attempts" ON quiz_attempts
    FOR INSERT WITH CHECK (
        user_id = (select auth.uid())
    );

CREATE POLICY "View quiz attempts" ON quiz_attempts
    FOR SELECT USING (
        user_id = (select auth.uid())
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
        OR EXISTS (
            SELECT 1 FROM profiles p1
            JOIN profiles p2 ON p1.group_id = p2.group_id
            WHERE p1.id = quiz_attempts.user_id
            AND p2.id = (select auth.uid())
        )
    );

-- ============================================================================
-- GRUPPE 4: courses - Multiple admin policies + view policies
-- ============================================================================

DROP POLICY IF EXISTS "Admins can manage all courses" ON courses;
DROP POLICY IF EXISTS "Admins can manage courses" ON courses;
DROP POLICY IF EXISTS "Admins can view all courses" ON courses;

CREATE POLICY "Admins can manage courses" ON courses
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- GRUPPE 5: lessons - Multiple SELECT policies
-- ============================================================================

DROP POLICY IF EXISTS "Admins can manage lessons" ON lessons;
DROP POLICY IF EXISTS "Users can view lessons" ON lessons;
-- Keep "Lessons visible to course-authorized users" as main view policy

CREATE POLICY "Admins can manage lessons" ON lessons
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- GRUPPE 6: profiles - Duplicate SELECT policies
-- ============================================================================

DROP POLICY IF EXISTS "Anyone can read profiles" ON profiles;
-- Keep "Public profiles are viewable by everyone"

-- End of migration
