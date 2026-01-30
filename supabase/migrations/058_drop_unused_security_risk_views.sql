-- Migration: 058_drop_unused_security_risk_views.sql
-- Purpose: Fix Supabase security linter warnings by dropping unused views
--
-- Issues fixed:
--   1. auth_users_exposed: user_learning_stats materialized view references auth.users,
--      exposing user data to anon role via PostgREST.
--   2. security_definer_view: accessible_courses, user_accessible_courses,
--      and user_accessible_courses_with_category all use SECURITY DEFINER,
--      meaning they run with the view creator's permissions instead of the
--      querying user's permissions.
--
-- All four views are unused by the application (no references in src/).
-- The app queries the courses table directly with RLS policies and
-- the getUserGroups() utility for access control.

-- =====================================================
-- 1. Drop user_learning_stats (auth_users_exposed)
--    References auth.users, exposed to anon via PostgREST
-- =====================================================
DROP MATERIALIZED VIEW IF EXISTS public.user_learning_stats CASCADE;

-- Drop the associated refresh function (no longer needed)
DROP FUNCTION IF EXISTS public.refresh_user_stats();

-- =====================================================
-- 2. Drop accessible_courses (security_definer_view)
--    Uses SECURITY DEFINER, runs as view creator
-- =====================================================
DROP VIEW IF EXISTS public.accessible_courses CASCADE;

-- =====================================================
-- 3. Drop user_accessible_courses_with_category (security_definer_view)
--    Uses SECURITY DEFINER, runs as view creator
-- =====================================================
DROP VIEW IF EXISTS public.user_accessible_courses_with_category CASCADE;

-- =====================================================
-- 4. Drop user_accessible_courses (security_definer_view)
--    Uses SECURITY DEFINER, runs as view creator
-- =====================================================
DROP VIEW IF EXISTS public.user_accessible_courses CASCADE;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Migration 058 completed: Dropped 4 unused views to fix security linter warnings';
  RAISE NOTICE '  - user_learning_stats (materialized view, exposed auth.users to anon)';
  RAISE NOTICE '  - accessible_courses (SECURITY DEFINER view)';
  RAISE NOTICE '  - user_accessible_courses_with_category (SECURITY DEFINER view)';
  RAISE NOTICE '  - user_accessible_courses (SECURITY DEFINER view)';
  RAISE NOTICE '  - refresh_user_stats() function (no longer needed)';
END $$;
