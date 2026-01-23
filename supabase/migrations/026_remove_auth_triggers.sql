-- Migration 026: Remove all custom triggers on auth.users
-- This will allow user signup to work

-- Drop our custom triggers
DROP TRIGGER IF EXISTS trigger_create_email_preferences ON auth.users CASCADE;
DROP TRIGGER IF EXISTS trigger_queue_welcome_email ON auth.users CASCADE;

-- Drop the functions too (they might be causing issues)
DROP FUNCTION IF EXISTS create_default_email_preferences() CASCADE;
DROP FUNCTION IF EXISTS queue_welcome_email() CASCADE;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'All custom auth triggers removed.';
  RAISE NOTICE 'User signup should now work.';
  RAISE NOTICE 'You will need to manually create email preferences for new users.';
END $$;
