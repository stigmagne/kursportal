-- Migration 023: Temporarily disable auth.users triggers
-- This allows user creation to work

-- Disable the problematic triggers
DROP TRIGGER IF EXISTS trigger_create_email_preferences ON auth.users;
DROP TRIGGER IF EXISTS trigger_queue_welcome_email ON auth.users;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Auth triggers disabled. You can now create users via Dashboard.';
  RAISE NOTICE 'After creating user, run migration 024 to re-enable triggers.';
END $$;
