-- Migration: 057_assessment_onboarding.sql
-- Purpose: Add assessment tracking columns to profiles for onboarding and re-assessment

-- Add columns to track assessment completion and scheduling
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS initial_assessment_completed_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS last_assessment_prompt_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS next_assessment_due_at TIMESTAMPTZ;

-- Create index for efficient querying of users due for re-assessment
CREATE INDEX IF NOT EXISTS idx_profiles_next_assessment_due
ON profiles(next_assessment_due_at)
WHERE next_assessment_due_at IS NOT NULL;

-- Function to update assessment tracking after completing a session
CREATE OR REPLACE FUNCTION update_assessment_tracking()
RETURNS TRIGGER AS $$
BEGIN
    -- Only run when status changes to 'completed'
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        UPDATE profiles
        SET 
            initial_assessment_completed_at = COALESCE(initial_assessment_completed_at, NOW()),
            next_assessment_due_at = NOW() + INTERVAL '3 months'
        WHERE id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-update tracking when assessment is completed
DROP TRIGGER IF EXISTS on_assessment_completed ON assessment_sessions;
CREATE TRIGGER on_assessment_completed
    AFTER INSERT OR UPDATE ON assessment_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_assessment_tracking();

-- Backfill existing users who have completed assessments
UPDATE profiles p
SET 
    initial_assessment_completed_at = (
        SELECT MIN(s.completed_at)
        FROM assessment_sessions s
        WHERE s.user_id = p.id AND s.status = 'completed'
    ),
    next_assessment_due_at = (
        SELECT MAX(s.completed_at) + INTERVAL '3 months'
        FROM assessment_sessions s
        WHERE s.user_id = p.id AND s.status = 'completed'
    )
WHERE EXISTS (
    SELECT 1 FROM assessment_sessions s
    WHERE s.user_id = p.id AND s.status = 'completed'
);

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION update_assessment_tracking() TO authenticated;
