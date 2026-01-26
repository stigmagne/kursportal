-- Migration: 041_course_access_control.sql
-- Purpose: Restrict course access based on user type (sibling vs parent)

-- Add target_group column to courses
ALTER TABLE courses ADD COLUMN IF NOT EXISTS target_group TEXT;

-- Add user_type to profiles to track which assessment path they've taken
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS user_type TEXT CHECK (user_type IN ('sibling', 'parent', 'both'));

-- Update existing courses with target groups
UPDATE courses SET target_group = 'sibling' 
WHERE slug IN ('a-forsta-mine-folelser', 'min-stemme-mine-grenser', 'hvem-er-jeg');

UPDATE courses SET target_group = 'parent' 
WHERE slug IN ('a-se-alle-barna', 'kommunikasjon-i-familien', 'egen-mestring-som-forelder');

-- Function to check if user can access a course
CREATE OR REPLACE FUNCTION can_access_course(p_user_id UUID, p_course_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_target_group TEXT;
    v_user_type TEXT;
    v_has_completed_assessment BOOLEAN;
BEGIN
    -- Get course target group
    SELECT target_group INTO v_target_group 
    FROM courses WHERE id = p_course_id;
    
    -- If no target group restriction, allow access
    IF v_target_group IS NULL THEN
        RETURN TRUE;
    END IF;
    
    -- Get user type from profile
    SELECT user_type INTO v_user_type
    FROM profiles WHERE id = p_user_id;
    
    -- Check if user has completed the appropriate assessment
    SELECT EXISTS (
        SELECT 1 
        FROM assessment_sessions s
        JOIN assessment_types t ON t.id = s.assessment_type_id
        WHERE s.user_id = p_user_id 
        AND s.status = 'completed'
        AND t.target_group = v_target_group
    ) INTO v_has_completed_assessment;
    
    -- Allow access if user_type matches OR has completed appropriate assessment
    RETURN (v_user_type = v_target_group) 
        OR (v_user_type = 'both') 
        OR v_has_completed_assessment;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update user_type when assessment is completed
CREATE OR REPLACE FUNCTION update_user_type_on_assessment()
RETURNS TRIGGER AS $$
DECLARE
    v_target_group TEXT;
    v_current_type TEXT;
BEGIN
    -- Only run when status changes to 'completed'
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        -- Get assessment target group
        SELECT target_group INTO v_target_group
        FROM assessment_types WHERE id = NEW.assessment_type_id;
        
        -- Get current user type
        SELECT user_type INTO v_current_type
        FROM profiles WHERE id = NEW.user_id;
        
        -- Update user type
        IF v_current_type IS NULL THEN
            UPDATE profiles SET user_type = v_target_group WHERE id = NEW.user_id;
        ELSIF v_current_type != v_target_group AND v_current_type != 'both' THEN
            UPDATE profiles SET user_type = 'both' WHERE id = NEW.user_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for automatic user type update
DROP TRIGGER IF EXISTS trigger_update_user_type ON assessment_sessions;
CREATE TRIGGER trigger_update_user_type
    AFTER INSERT OR UPDATE ON assessment_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_user_type_on_assessment();

-- Create view for accessible courses (for use in queries)
CREATE OR REPLACE VIEW accessible_courses AS
SELECT c.*, 
    CASE 
        WHEN c.target_group IS NULL THEN true
        WHEN auth.uid() IS NULL THEN false
        ELSE can_access_course(auth.uid(), c.id)
    END AS is_accessible
FROM courses c
WHERE c.published = true;

-- RLS policy to restrict course viewing based on target group (optional - depends on how strict you want to be)
-- This allows everyone to see the course exists but can control enrollment
CREATE POLICY "Course visibility based on target group"
    ON courses FOR SELECT
    USING (
        published = true
        AND (
            target_group IS NULL
            OR can_access_course(auth.uid(), id)
            OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
        )
    );

-- Update enrollment to check access
CREATE OR REPLACE FUNCTION check_course_enrollment_access()
RETURNS TRIGGER AS $$
DECLARE
    v_target_group TEXT;
BEGIN
    -- Get course target group
    SELECT target_group INTO v_target_group
    FROM courses WHERE id = NEW.course_id;
    
    -- If restricted course, check access
    IF v_target_group IS NOT NULL THEN
        IF NOT can_access_course(NEW.user_id, NEW.course_id) THEN
            RAISE EXCEPTION 'Du må fullføre vurderingen for å få tilgang til dette kurset.';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for enrollment access check
DROP TRIGGER IF EXISTS trigger_check_enrollment_access ON user_progress;
CREATE TRIGGER trigger_check_enrollment_access
    BEFORE INSERT ON user_progress
    FOR EACH ROW
    EXECUTE FUNCTION check_course_enrollment_access();

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION can_access_course(UUID, UUID) TO authenticated;
