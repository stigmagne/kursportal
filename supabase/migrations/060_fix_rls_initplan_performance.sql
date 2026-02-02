-- Migration: Fix RLS InitPlan Performance Issues
-- Description: Wraps auth.<function>() calls with (select auth.<function>()) 
--              to prevent per-row re-evaluation, improving query performance.
-- See: https://supabase.com/docs/guides/database/postgres/row-level-security#call-functions-with-select

-- ============================================================================
-- PROFILES TABLE
-- ============================================================================

DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
CREATE POLICY "Users can insert their own profile" ON profiles
    FOR INSERT WITH CHECK (id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can update own profile except role" ON profiles;
CREATE POLICY "Users can update own profile except role" ON profiles
    FOR UPDATE USING (id = (select auth.uid()))
    WITH CHECK (id = (select auth.uid()) AND role = (SELECT role FROM profiles WHERE id = (select auth.uid())));

-- ============================================================================
-- COURSES TABLE
-- ============================================================================

DROP POLICY IF EXISTS "Admins can manage courses" ON courses;
CREATE POLICY "Admins can manage courses" ON courses
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage all courses" ON courses;
CREATE POLICY "Admins can manage all courses" ON courses
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can view all courses" ON courses;
CREATE POLICY "Admins can view all courses" ON courses
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Users can view accessible published courses" ON courses;
CREATE POLICY "Users can view accessible published courses" ON courses
    FOR SELECT USING (
        published = true
        AND EXISTS (
            SELECT 1 FROM course_groups cg
            JOIN profiles p ON p.group_id = cg.group_id
            WHERE cg.course_id = courses.id AND p.id = (select auth.uid())
        )
    );

-- ============================================================================
-- ASSESSMENT TABLES
-- ============================================================================

DROP POLICY IF EXISTS "Users can manage own sessions" ON assessment_sessions;
CREATE POLICY "Users can manage own sessions" ON assessment_sessions
    FOR ALL USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can manage own responses" ON assessment_responses;
CREATE POLICY "Users can manage own responses" ON assessment_responses
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM assessment_sessions 
            WHERE id = assessment_responses.session_id 
            AND user_id = (select auth.uid())
        )
    );

DROP POLICY IF EXISTS "Users can view own results" ON assessment_results;
CREATE POLICY "Users can view own results" ON assessment_results
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM assessment_sessions 
            WHERE id = assessment_results.session_id 
            AND user_id = (select auth.uid())
        )
    );

DROP POLICY IF EXISTS "Users can view own recommendations" ON assessment_recommendations;
CREATE POLICY "Users can view own recommendations" ON assessment_recommendations
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM assessment_results ar WHERE ar.id = assessment_recommendations.result_id AND ar.user_id = (select auth.uid()))
    );

DROP POLICY IF EXISTS "Admins can manage all assessment data" ON assessment_types;
CREATE POLICY "Admins can manage all assessment data" ON assessment_types
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage dimensions" ON assessment_dimensions;
CREATE POLICY "Admins can manage dimensions" ON assessment_dimensions
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage questions" ON assessment_questions;
CREATE POLICY "Admins can manage questions" ON assessment_questions
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- USER PROGRESS TABLE
-- ============================================================================

DROP POLICY IF EXISTS "Users manage their own progress" ON user_progress;
CREATE POLICY "Users manage their own progress" ON user_progress
    FOR ALL USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Admins can view all progress" ON user_progress;
CREATE POLICY "Admins can view all progress" ON user_progress
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- JOURNALS TABLE
-- ============================================================================

DROP POLICY IF EXISTS "Users can only access own journals" ON journals;
CREATE POLICY "Users can only access own journals" ON journals
    FOR ALL USING (user_id = (select auth.uid()));

-- ============================================================================
-- CATEGORIES TABLES
-- ============================================================================

DROP POLICY IF EXISTS "Admins can manage categories" ON categories;
CREATE POLICY "Admins can manage categories" ON categories
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage course categories" ON course_categories;
CREATE POLICY "Admins can manage course categories" ON course_categories
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Users can view their own category assignments" ON user_categories;
CREATE POLICY "Users can view their own category assignments" ON user_categories
    FOR SELECT USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Admins can view all category assignments" ON user_categories;
CREATE POLICY "Admins can view all category assignments" ON user_categories
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage category assignments" ON user_categories;
CREATE POLICY "Admins can manage category assignments" ON user_categories
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage course category assignments" ON course_user_categories;
CREATE POLICY "Admins can manage course category assignments" ON course_user_categories
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- BADGES TABLE
-- ============================================================================

DROP POLICY IF EXISTS "Users can view own badges" ON user_badges;
CREATE POLICY "Users can view own badges" ON user_badges
    FOR SELECT USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "System can award badges" ON user_badges;
CREATE POLICY "System can award badges" ON user_badges
    FOR INSERT WITH CHECK (user_id = (select auth.uid()));

-- ============================================================================
-- COURSE MODULES & LESSONS
-- ============================================================================

DROP POLICY IF EXISTS "Admins can manage modules" ON course_modules;
CREATE POLICY "Admins can manage modules" ON course_modules
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage lessons" ON lessons;
CREATE POLICY "Admins can manage lessons" ON lessons
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Lessons visible to course-authorized users" ON lessons;
CREATE POLICY "Lessons visible to course-authorized users" ON lessons
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM course_modules cm
            JOIN course_groups cg ON cm.course_id = cg.course_id
            JOIN profiles p ON p.group_id = cg.group_id
            WHERE cm.id = lessons.module_id AND p.id = (select auth.uid())
        )
    );

DROP POLICY IF EXISTS "Admins can manage lesson content" ON lesson_content;
CREATE POLICY "Admins can manage lesson content" ON lesson_content
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage prerequisites" ON lesson_prerequisites;
CREATE POLICY "Admins can manage prerequisites" ON lesson_prerequisites
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Users can manage own completions" ON lesson_completion;
CREATE POLICY "Users can manage own completions" ON lesson_completion
    FOR ALL USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Admins can view all completions" ON lesson_completion;
CREATE POLICY "Admins can view all completions" ON lesson_completion
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- LESSON COMMENTS
-- ============================================================================

DROP POLICY IF EXISTS "Users can delete own comments" ON lesson_comments;
CREATE POLICY "Users can delete own comments" ON lesson_comments
    FOR DELETE USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Authenticated users can create comments" ON lesson_comments;
CREATE POLICY "Authenticated users can create comments" ON lesson_comments
    FOR INSERT WITH CHECK ((select auth.uid()) IS NOT NULL);

DROP POLICY IF EXISTS "Users can create comments" ON lesson_comments;
CREATE POLICY "Users can create comments" ON lesson_comments
    FOR INSERT WITH CHECK (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can update own comments" ON lesson_comments;
CREATE POLICY "Users can update own comments" ON lesson_comments
    FOR UPDATE USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can view comments in their subgroup" ON lesson_comments;
CREATE POLICY "Users can view comments in their subgroup" ON lesson_comments
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM profiles p1
            JOIN profiles p2 ON p1.subgroup = p2.subgroup
            WHERE p1.id = (select auth.uid()) AND p2.id = lesson_comments.user_id
        )
    );

-- ============================================================================
-- USER ACTIVITY
-- ============================================================================

DROP POLICY IF EXISTS "System can create activity" ON user_activity;
CREATE POLICY "System can create activity" ON user_activity
    FOR INSERT WITH CHECK (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can view activity in their subgroup" ON user_activity;
CREATE POLICY "Users can view activity in their subgroup" ON user_activity
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM profiles p1
            JOIN profiles p2 ON p1.subgroup = p2.subgroup
            WHERE p1.id = (select auth.uid()) AND p2.id = user_activity.user_id
        )
    );

-- ============================================================================
-- INVITATIONS
-- ============================================================================

DROP POLICY IF EXISTS "System can insert invitation uses" ON invitation_uses;
CREATE POLICY "System can insert invitation uses" ON invitation_uses
    FOR INSERT WITH CHECK ((select auth.uid()) IS NOT NULL);

DROP POLICY IF EXISTS "Admins can manage invitations" ON invitations;
CREATE POLICY "Admins can manage invitations" ON invitations
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can view invitation uses" ON invitation_uses;
CREATE POLICY "Admins can view invitation uses" ON invitation_uses
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- DRIP SCHEDULES
-- ============================================================================

DROP POLICY IF EXISTS "Admins can manage drip schedules" ON drip_schedules;
CREATE POLICY "Admins can manage drip schedules" ON drip_schedules
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- SEARCH HISTORY
-- ============================================================================

DROP POLICY IF EXISTS "Users can view own search history" ON search_history;
CREATE POLICY "Users can view own search history" ON search_history
    FOR SELECT USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can create own search history" ON search_history;
CREATE POLICY "Users can create own search history" ON search_history
    FOR INSERT WITH CHECK (user_id = (select auth.uid()));

-- ============================================================================
-- QUIZZES
-- ============================================================================

DROP POLICY IF EXISTS "Admins can manage quizzes" ON quizzes;
CREATE POLICY "Admins can manage quizzes" ON quizzes
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage questions" ON quiz_questions;
CREATE POLICY "Admins can manage questions" ON quiz_questions
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage answers" ON quiz_answer_options;
CREATE POLICY "Admins can manage answers" ON quiz_answer_options
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Users can create own attempts" ON quiz_attempts;
CREATE POLICY "Users can create own attempts" ON quiz_attempts
    FOR INSERT WITH CHECK (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can view own quiz attempts" ON quiz_attempts;
CREATE POLICY "Users can view own quiz attempts" ON quiz_attempts
    FOR SELECT USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can create own quiz attempts" ON quiz_attempts;
CREATE POLICY "Users can create own quiz attempts" ON quiz_attempts
    FOR INSERT WITH CHECK (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Admins can view all attempts" ON quiz_attempts;
CREATE POLICY "Admins can view all attempts" ON quiz_attempts
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can view all quiz attempts" ON quiz_attempts;
CREATE POLICY "Admins can view all quiz attempts" ON quiz_attempts
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Users can view quiz attempts in their subgroup" ON quiz_attempts;
CREATE POLICY "Users can view quiz attempts in their subgroup" ON quiz_attempts
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM profiles p1
            JOIN profiles p2 ON p1.subgroup = p2.subgroup
            WHERE p1.id = (select auth.uid()) AND p2.id = quiz_attempts.user_id
        )
    );

DROP POLICY IF EXISTS "Students can view own responses" ON quiz_short_answer_responses;
CREATE POLICY "Students can view own responses" ON quiz_short_answer_responses
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM quiz_attempts qa WHERE qa.id = quiz_short_answer_responses.attempt_id AND qa.user_id = (select auth.uid()))
    );

DROP POLICY IF EXISTS "Students can insert own responses" ON quiz_short_answer_responses;
CREATE POLICY "Students can insert own responses" ON quiz_short_answer_responses
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM quiz_attempts qa WHERE qa.id = quiz_short_answer_responses.attempt_id AND qa.user_id = (select auth.uid()))
    );

DROP POLICY IF EXISTS "Admins can manage responses" ON quiz_short_answer_responses;
CREATE POLICY "Admins can manage responses" ON quiz_short_answer_responses
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- EMAIL TABLES
-- ============================================================================

DROP POLICY IF EXISTS "Users can view own email preferences" ON email_preferences;
CREATE POLICY "Users can view own email preferences" ON email_preferences
    FOR SELECT USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can update own email preferences" ON email_preferences;
CREATE POLICY "Users can update own email preferences" ON email_preferences
    FOR UPDATE USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can view own email queue" ON email_queue;
CREATE POLICY "Users can view own email queue" ON email_queue
    FOR SELECT USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Admins can view all email queue" ON email_queue;
CREATE POLICY "Admins can view all email queue" ON email_queue
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage email templates" ON email_templates;
CREATE POLICY "Admins can manage email templates" ON email_templates
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- CERTIFICATES
-- ============================================================================

DROP POLICY IF EXISTS "Users can view own certificates" ON certificates;
CREATE POLICY "Users can view own certificates" ON certificates
    FOR SELECT USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can create own certificates" ON certificates;
CREATE POLICY "Users can create own certificates" ON certificates
    FOR INSERT WITH CHECK (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Admins can manage certificates" ON certificates;
CREATE POLICY "Admins can manage certificates" ON certificates
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================

DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;
CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Admins can view notification settings" ON notification_settings;
CREATE POLICY "Admins can view notification settings" ON notification_settings
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can update notification settings" ON notification_settings;
CREATE POLICY "Admins can update notification settings" ON notification_settings
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can insert notification settings" ON notification_settings;
CREATE POLICY "Admins can insert notification settings" ON notification_settings
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can view notification logs" ON notification_log;
CREATE POLICY "Admins can view notification logs" ON notification_log
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Service can insert notification logs" ON notification_log;
CREATE POLICY "Service can insert notification logs" ON notification_log
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- GROUPS
-- ============================================================================

DROP POLICY IF EXISTS "Admins can manage groups" ON groups;
CREATE POLICY "Admins can manage groups" ON groups
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Users can view own groups" ON user_groups;
CREATE POLICY "Users can view own groups" ON user_groups
    FOR SELECT USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "System can insert user groups" ON user_groups;
CREATE POLICY "System can insert user groups" ON user_groups
    FOR INSERT WITH CHECK (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Admins can manage all user groups" ON user_groups;
CREATE POLICY "Admins can manage all user groups" ON user_groups
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage course groups" ON course_groups;
CREATE POLICY "Admins can manage course groups" ON course_groups
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- JOURNAL TABLES
-- ============================================================================

DROP POLICY IF EXISTS "Users can manage own tool entries" ON journal_tool_entries;
CREATE POLICY "Users can manage own tool entries" ON journal_tool_entries
    FOR ALL USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can manage own measurements" ON journal_measurements;
CREATE POLICY "Users can manage own measurements" ON journal_measurements
    FOR ALL USING (user_id = (select auth.uid()));

DROP POLICY IF EXISTS "Admins can manage tool types" ON journal_tool_types;
CREATE POLICY "Admins can manage tool types" ON journal_tool_types
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage tools" ON journal_tools;
CREATE POLICY "Admins can manage tools" ON journal_tools
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- TAGS
-- ============================================================================

DROP POLICY IF EXISTS "Admins can manage tags" ON tags;
CREATE POLICY "Admins can manage tags" ON tags
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

DROP POLICY IF EXISTS "Admins can manage course tags" ON course_tags;
CREATE POLICY "Admins can manage course tags" ON course_tags
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================================================
-- STRIPE/PAYMENTS
-- ============================================================================

DROP POLICY IF EXISTS "Users can view own customer record" ON customers;
CREATE POLICY "Users can view own customer record" ON customers
    FOR SELECT USING (id = (select auth.uid()));

DROP POLICY IF EXISTS "Users can view own subscriptions" ON subscriptions;
CREATE POLICY "Users can view own subscriptions" ON subscriptions
    FOR SELECT USING (user_id = (select auth.uid()));

-- ============================================================================
-- Done! All auth.<function>() calls are now wrapped with (select ...)
-- ============================================================================
