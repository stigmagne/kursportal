-- Migration 025: Disable ALL triggers on auth schema temporarily
-- This should allow user creation via Dashboard

-- List all triggers on auth.users to see what's causing the issue
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN 
    SELECT tgname 
    FROM pg_trigger 
    WHERE tgrelid = 'auth.users'::regclass
  LOOP
    RAISE NOTICE 'Found trigger: %', r.tgname;
    EXECUTE format('DROP TRIGGER IF EXISTS %I ON auth.users', r.tgname);
  END LOOP;
END $$;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'All auth.users triggers have been dropped.';
  RAISE NOTICE 'You can now create users via Supabase Dashboard.';
  RAISE NOTICE 'After creating the user, run migration 026 to restore triggers.';
END $$;
