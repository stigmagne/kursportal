-- Migration 024: Re-enable auth.users triggers
-- Run this after creating users

-- Re-create the triggers
CREATE TRIGGER trigger_create_email_preferences
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_default_email_preferences();

CREATE TRIGGER trigger_queue_welcome_email
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION queue_welcome_email();

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Auth triggers re-enabled.';
END $$;
