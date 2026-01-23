-- Migration 014: Cleanup Accidental Tables
-- Drops tables that were created by mistake: onboarding_progress, meetings system

-- Drop tables with CASCADE to remove dependent objects (policies, indexes, constraints)
DROP TABLE IF EXISTS public.onboarding_progress CASCADE;
DROP TABLE IF EXISTS public.meeting_minutes CASCADE;
DROP TABLE IF EXISTS public.meeting_attendees CASCADE;
DROP TABLE IF EXISTS public.meetings CASCADE;

-- Also try to drop organizations if it was created and is not part of the core schema
-- (Be careful here, checking if it was part of the invalid set. The user output showed references to it. 
-- If it doesn't exist, this does nothing. If it uses 'profiles' etc, it might be safe to keep checking user intent, 
-- but usually 'organizations' goes with the other enterprise features.)
-- DROP TABLE IF EXISTS public.organizations CASCADE; 
-- Commented out organizations drop to be safe, as it might be a core table depending on other context not fully visible. 
-- But based on the "En Helt Syk Oppvekst" project context, it seems like a B2C/Content platform, not B2B.
-- If you are sure organizations is not needed:
-- DROP TABLE IF EXISTS public.organizations CASCADE;

DO $$
BEGIN
  RAISE NOTICE 'Cleanup completed: Dropped onboarding_progress and meetings tables.';
END $$;
