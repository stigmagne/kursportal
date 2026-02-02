-- Migration: Fix remaining RLS policy conflicts
-- Problem: Admin "FOR ALL" policies still conflict with public SELECT policies
-- Solution: Split admin policies to INSERT/UPDATE/DELETE only (not ALL)

-- ============================================================================
-- GRUPPE 1: Fix admin policies to NOT include SELECT when public can view
-- ============================================================================

-- assessment_dimensions
DROP POLICY IF EXISTS "Admins can manage dimensions" ON assessment_dimensions;
CREATE POLICY "Admins can modify dimensions" ON assessment_dimensions
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update dimensions" ON assessment_dimensions
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete dimensions" ON assessment_dimensions
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- assessment_questions
DROP POLICY IF EXISTS "Admins can manage questions" ON assessment_questions;
CREATE POLICY "Admins can modify questions" ON assessment_questions
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update questions" ON assessment_questions
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete questions" ON assessment_questions
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- assessment_types
DROP POLICY IF EXISTS "Admins can manage all assessment data" ON assessment_types;
CREATE POLICY "Admins can modify assessment types" ON assessment_types
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update assessment types" ON assessment_types
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete assessment types" ON assessment_types
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- categories
DROP POLICY IF EXISTS "Admins can manage categories" ON categories;
CREATE POLICY "Admins can modify categories" ON categories
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update categories" ON categories
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete categories" ON categories
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- course_categories
DROP POLICY IF EXISTS "Admins can manage course categories" ON course_categories;
CREATE POLICY "Admins can modify course categories" ON course_categories
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update course categories" ON course_categories
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete course categories" ON course_categories
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- course_groups
DROP POLICY IF EXISTS "Admins can manage course groups" ON course_groups;
CREATE POLICY "Admins can modify course groups" ON course_groups
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update course groups" ON course_groups
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete course groups" ON course_groups
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- course_tags
DROP POLICY IF EXISTS "Admins can manage course tags" ON course_tags;
CREATE POLICY "Admins can modify course tags" ON course_tags
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update course tags" ON course_tags
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete course tags" ON course_tags
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- course_user_categories
DROP POLICY IF EXISTS "Admins can manage course category assignments" ON course_user_categories;
CREATE POLICY "Admins can modify course category assignments" ON course_user_categories
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update course category assignments" ON course_user_categories
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete course category assignments" ON course_user_categories
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- courses
DROP POLICY IF EXISTS "Admins can manage courses" ON courses;
CREATE POLICY "Admins can modify courses" ON courses
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update courses" ON courses
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete courses" ON courses
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- drip_schedules
DROP POLICY IF EXISTS "Admins can manage drip schedules" ON drip_schedules;
CREATE POLICY "Admins can modify drip schedules" ON drip_schedules
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update drip schedules" ON drip_schedules
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete drip schedules" ON drip_schedules
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- email_templates
DROP POLICY IF EXISTS "Admins can manage email templates" ON email_templates;
CREATE POLICY "Admins can modify email templates" ON email_templates
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update email templates" ON email_templates
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete email templates" ON email_templates
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- groups
DROP POLICY IF EXISTS "Admins can manage groups" ON groups;
CREATE POLICY "Admins can modify groups" ON groups
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update groups" ON groups
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete groups" ON groups
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- invitations
DROP POLICY IF EXISTS "Admins can manage invitations" ON invitations;
CREATE POLICY "Admins can modify invitations" ON invitations
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update invitations" ON invitations
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete invitations" ON invitations
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- journal_tool_types
DROP POLICY IF EXISTS "Admins can manage tool types" ON journal_tool_types;
CREATE POLICY "Admins can modify tool types" ON journal_tool_types
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update tool types" ON journal_tool_types
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete tool types" ON journal_tool_types
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- journal_tools
DROP POLICY IF EXISTS "Admins can manage tools" ON journal_tools;
CREATE POLICY "Admins can modify tools" ON journal_tools
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update tools" ON journal_tools
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete tools" ON journal_tools
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- lesson_content
DROP POLICY IF EXISTS "Admins can manage lesson content" ON lesson_content;
CREATE POLICY "Admins can modify lesson content" ON lesson_content
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update lesson content" ON lesson_content
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete lesson content" ON lesson_content
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- lesson_prerequisites
DROP POLICY IF EXISTS "Admins can manage prerequisites" ON lesson_prerequisites;
CREATE POLICY "Admins can modify prerequisites" ON lesson_prerequisites
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update prerequisites" ON lesson_prerequisites
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete prerequisites" ON lesson_prerequisites
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- lessons
DROP POLICY IF EXISTS "Admins can manage lessons" ON lessons;
CREATE POLICY "Admins can modify lessons" ON lessons
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update lessons" ON lessons
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete lessons" ON lessons
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- course_modules
DROP POLICY IF EXISTS "Admins can manage modules" ON course_modules;
CREATE POLICY "Admins can modify modules" ON course_modules
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update modules" ON course_modules
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete modules" ON course_modules
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- quiz_answer_options
DROP POLICY IF EXISTS "Admins can manage answers" ON quiz_answer_options;
CREATE POLICY "Admins can modify answers" ON quiz_answer_options
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update answers" ON quiz_answer_options
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete answers" ON quiz_answer_options
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- quiz_questions
DROP POLICY IF EXISTS "Admins can manage questions" ON quiz_questions;
CREATE POLICY "Admins can modify quiz questions" ON quiz_questions
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update quiz questions" ON quiz_questions
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete quiz questions" ON quiz_questions
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- tags
DROP POLICY IF EXISTS "Admins can manage tags" ON tags;
CREATE POLICY "Admins can modify tags" ON tags
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update tags" ON tags
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete tags" ON tags
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- GRUPPE 2: Additional tables from warnings
-- ============================================================================

-- quizzes
DROP POLICY IF EXISTS "Admins can manage quizzes" ON quizzes;
CREATE POLICY "Admins can modify quizzes" ON quizzes
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update quizzes" ON quizzes
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete quizzes" ON quizzes
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- quiz_short_answer_responses
DROP POLICY IF EXISTS "Admins can manage responses" ON quiz_short_answer_responses;
DROP POLICY IF EXISTS "Students can insert own responses" ON quiz_short_answer_responses;
DROP POLICY IF EXISTS "Students can view own responses" ON quiz_short_answer_responses;

CREATE POLICY "Users can manage own short answer responses" ON quiz_short_answer_responses
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM quiz_attempts qa
            WHERE qa.id = quiz_short_answer_responses.attempt_id
            AND qa.user_id = (select auth.uid())
        )
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM quiz_attempts qa
            WHERE qa.id = quiz_short_answer_responses.attempt_id
            AND qa.user_id = (select auth.uid())
        )
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- user_categories: Consolidate 3 overlapping SELECT policies
DROP POLICY IF EXISTS "Admins can manage category assignments" ON user_categories;
DROP POLICY IF EXISTS "Admins can view all category assignments" ON user_categories;
DROP POLICY IF EXISTS "Users can view their own category assignments" ON user_categories;

CREATE POLICY "View user categories" ON user_categories
    FOR SELECT USING (
        user_id = (select auth.uid())
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

CREATE POLICY "Admins can modify user categories" ON user_categories
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can update user categories" ON user_categories
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Admins can delete user categories" ON user_categories
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- user_groups: Consolidate SELECT and INSERT policies
DROP POLICY IF EXISTS "Admins can manage all user groups" ON user_groups;
DROP POLICY IF EXISTS "Users can view own groups" ON user_groups;
DROP POLICY IF EXISTS "System can insert user groups" ON user_groups;

CREATE POLICY "View user groups" ON user_groups
    FOR SELECT USING (
        user_id = (select auth.uid())
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

CREATE POLICY "Manage user groups" ON user_groups
    FOR INSERT WITH CHECK (
        user_id = (select auth.uid())
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Update user groups" ON user_groups
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );
CREATE POLICY "Delete user groups" ON user_groups
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- user_progress: Consolidate SELECT policies
DROP POLICY IF EXISTS "Admins can view all progress" ON user_progress;
DROP POLICY IF EXISTS "Users manage their own progress" ON user_progress;

CREATE POLICY "Users manage own progress" ON user_progress
    FOR ALL USING (
        user_id = (select auth.uid())
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    )
    WITH CHECK (
        user_id = (select auth.uid())
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- GRUPPE 3: Fix lesson_comments auth_rls_initplan
-- ============================================================================

DROP POLICY IF EXISTS "Users can create comments" ON lesson_comments;
CREATE POLICY "Users can create comments" ON lesson_comments
    FOR INSERT WITH CHECK (
        (select auth.uid()) IS NOT NULL
    );

-- ============================================================================
-- GRUPPE 4: Remove duplicate indexes
-- ============================================================================

DROP INDEX IF EXISTS idx_comments_lesson;
-- unique_user_lesson is tied to a constraint, drop the duplicate constraint instead
ALTER TABLE lesson_completion DROP CONSTRAINT IF EXISTS lesson_completion_user_id_lesson_id_key;
DROP INDEX IF EXISTS idx_lessons_order;
DROP INDEX IF EXISTS idx_quiz_answer_options_question;
DROP INDEX IF EXISTS idx_quiz_questions_quiz;
DROP INDEX IF EXISTS idx_activity_user_created;

-- End of migration
