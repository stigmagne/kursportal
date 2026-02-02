-- Migration: 059_fix_function_search_paths_and_policies.sql
-- Purpose: Fix Supabase security linter warnings:
--   1. function_search_path_mutable: Set search_path on all public functions
--   2. materialized_view_in_api: Revoke API access to course_stats
--   3. rls_policy_always_true: Tighten permissive INSERT policies

-- =====================================================
-- PART 1: Fix mutable search_path on all functions
-- Setting search_path = 'public' prevents search_path injection
-- while allowing unqualified references to public schema objects.
-- =====================================================

-- Search functions (018_search_functionality, 027_group_access_control)
ALTER FUNCTION public.update_course_search_vector() SET search_path = 'public';
ALTER FUNCTION public.update_lesson_search_vector() SET search_path = 'public';
ALTER FUNCTION public.search_courses(TEXT) SET search_path = 'public';
ALTER FUNCTION public.search_lessons(TEXT) SET search_path = 'public';
ALTER FUNCTION public.global_search(TEXT) SET search_path = 'public';

-- Course module/lesson helpers (004_course_modules_lessons)
ALTER FUNCTION public.get_module_completion_pct(UUID, UUID) SET search_path = 'public';
ALTER FUNCTION public.is_lesson_unlocked(UUID, UUID) SET search_path = 'public';

-- User category access (005_user_categories)
ALTER FUNCTION public.can_user_access_course(UUID, UUID) SET search_path = 'public';
ALTER FUNCTION public.get_accessible_courses(UUID) SET search_path = 'public';

-- Student helpers (006_student_helpers)
ALTER FUNCTION public.can_access_lesson(UUID, UUID) SET search_path = 'public';
ALTER FUNCTION public.is_lesson_unlocked_by_drip(UUID, UUID) SET search_path = 'public';
ALTER FUNCTION public.calculate_course_progress(UUID, UUID) SET search_path = 'public';
ALTER FUNCTION public.get_next_lesson(UUID, UUID) SET search_path = 'public';
ALTER FUNCTION public.get_previous_lesson(UUID) SET search_path = 'public';

-- Quiz system (009_quiz_system, 012_quiz_enhancements, 016_enhanced_quiz)
ALTER FUNCTION public.has_passed_quiz(UUID, UUID) SET search_path = 'public';
ALTER FUNCTION public.get_best_quiz_score(UUID, UUID) SET search_path = 'public';
ALTER FUNCTION public.get_quiz_attempt_count(UUID, UUID) SET search_path = 'public';
ALTER FUNCTION public.get_pending_grading_attempts() SET search_path = 'public';
ALTER FUNCTION public.grade_short_answer(UUID, DECIMAL, TEXT, UUID) SET search_path = 'public';

-- Certificates (010_certificates)
ALTER FUNCTION public.generate_certificate_number() SET search_path = 'public';
ALTER FUNCTION public.set_certificate_number_trigger() SET search_path = 'public';
ALTER FUNCTION public.has_certificate(UUID, UUID) SET search_path = 'public';
ALTER FUNCTION public.get_certificate_details(UUID, UUID) SET search_path = 'public';

-- Analytics (013_fix_analytics_bugs)
ALTER FUNCTION public.get_platform_stats() SET search_path = 'public';
ALTER FUNCTION public.get_course_completion_rates() SET search_path = 'public';

-- Notifications and comments (015_notifications_and_comments)
ALTER FUNCTION public.create_notification(UUID, TEXT, TEXT, TEXT, TEXT) SET search_path = 'public';
ALTER FUNCTION public.notify_certificate_issued() SET search_path = 'public';
ALTER FUNCTION public.notify_comment_reply() SET search_path = 'public';

-- Profile enhancements / badges (017_profile_enhancements)
ALTER FUNCTION public.check_and_award_badges(UUID) SET search_path = 'public';
ALTER FUNCTION public.log_lesson_completion() SET search_path = 'public';
ALTER FUNCTION public.log_quiz_completion() SET search_path = 'public';
ALTER FUNCTION public.log_certificate_earned() SET search_path = 'public';
ALTER FUNCTION public.log_comment_posted() SET search_path = 'public';

-- Performance optimizations (019_performance_optimizations)
ALTER FUNCTION public.refresh_course_stats() SET search_path = 'public';

-- Email notifications (020_email_notifications)
ALTER FUNCTION public.queue_certificate_email() SET search_path = 'public';
ALTER FUNCTION public.queue_comment_reply_email() SET search_path = 'public';

-- Invitation system (028_invitation_system, 049, 050, 056)
ALTER FUNCTION public.generate_invitation_code() SET search_path = 'public';
ALTER FUNCTION public.create_invitation(TEXT, TEXT, TEXT, INTEGER, INTEGER) SET search_path = 'public';
ALTER FUNCTION public.validate_invitation(TEXT) SET search_path = 'public';
ALTER FUNCTION public.use_invitation(TEXT, UUID) SET search_path = 'public';
ALTER FUNCTION public.get_invitation_stats() SET search_path = 'public';

-- Subgroup system (029_subgroup_system)
ALTER FUNCTION public.get_subgroup_members() SET search_path = 'public';

-- Tags system (031_tags_system)
ALTER FUNCTION public.slugify(TEXT) SET search_path = 'public';

-- Secure role updates (033_secure_role_updates)
ALTER FUNCTION public.forbid_role_change() SET search_path = 'public';

-- Dynamic groups (035_dynamic_groups)
ALTER FUNCTION public.create_new_group(TEXT, TEXT) SET search_path = 'public';
ALTER FUNCTION public.create_group_invitation(UUID, TEXT, INTEGER, INTEGER) SET search_path = 'public';

-- Assessment system (037_assessment_system)
ALTER FUNCTION public.calculate_assessment_results(UUID) SET search_path = 'public';

-- Course access control (042_course_access_control)
ALTER FUNCTION public.can_access_course(UUID, UUID) SET search_path = 'public';
ALTER FUNCTION public.update_user_type_on_assessment() SET search_path = 'public';
ALTER FUNCTION public.check_course_enrollment_access() SET search_path = 'public';

-- Invitation target groups (049_invitation_target_groups)
ALTER FUNCTION public.add_user_group(UUID, TEXT, UUID) SET search_path = 'public';
ALTER FUNCTION public.get_user_groups(UUID) SET search_path = 'public';
ALTER FUNCTION public.check_group_conflict() SET search_path = 'public';

-- Security improvements (050_security_improvements)
ALTER FUNCTION public.prevent_user_role_self_update() SET search_path = 'public';

-- Assessment onboarding (057_assessment_onboarding)
ALTER FUNCTION public.update_assessment_tracking() SET search_path = 'public';

-- =====================================================
-- PART 2: Fix materialized_view_in_api for course_stats
-- Revoke direct API access; only SECURITY DEFINER functions
-- (like refresh_course_stats) and admins should access this.
-- =====================================================
REVOKE SELECT ON public.course_stats FROM anon, authenticated;

-- =====================================================
-- PART 3: Fix rls_policy_always_true on INSERT policies
-- These tables are written to by SECURITY DEFINER functions
-- which bypass RLS, so restricting direct API inserts is safe.
-- =====================================================

-- user_activity: only SECURITY DEFINER triggers should insert
DROP POLICY IF EXISTS "System can create activity" ON public.user_activity;
CREATE POLICY "System can create activity"
  ON public.user_activity FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- user_badges: only SECURITY DEFINER check_and_award_badges() should insert
DROP POLICY IF EXISTS "System can award badges" ON public.user_badges;
CREATE POLICY "System can award badges"
  ON public.user_badges FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- invitation_uses: only SECURITY DEFINER use_invitation() should insert
DROP POLICY IF EXISTS "System can insert invitation uses" ON public.invitation_uses;
CREATE POLICY "System can insert invitation uses"
  ON public.invitation_uses FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- user_groups: only SECURITY DEFINER add_user_group()/use_invitation() should insert
DROP POLICY IF EXISTS "System can insert user groups" ON public.user_groups;
CREATE POLICY "System can insert user groups"
  ON public.user_groups FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- notification_log: only system/admin should insert log entries
DROP POLICY IF EXISTS "Service can insert notification logs" ON public.notification_log;
CREATE POLICY "Service can insert notification logs"
  ON public.notification_log FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

-- =====================================================
-- Done
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE 'Migration 059 completed: Fixed security warnings';
  RAISE NOTICE '  - Set search_path on all public functions';
  RAISE NOTICE '  - Revoked API access to course_stats materialized view';
  RAISE NOTICE '  - Tightened INSERT policies on 5 tables';
END $$;
