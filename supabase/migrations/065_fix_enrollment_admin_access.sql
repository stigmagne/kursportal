-- Migration: Fix enrollment access check for admins
-- Problem: The can_access_course function doesn't check for admin role,
-- so admins get blocked when trying to enroll in courses.

-- Update the can_access_course function to allow admins to access any course
CREATE OR REPLACE FUNCTION can_access_course(p_user_id UUID, p_course_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_target_group TEXT;
    v_user_type TEXT;
    v_user_role TEXT;
    v_has_completed_assessment BOOLEAN;
BEGIN
    -- Check if user is admin - admins can access any course
    SELECT role INTO v_user_role
    FROM profiles WHERE id = p_user_id;
    
    IF v_user_role = 'admin' THEN
        RETURN TRUE;
    END IF;
    
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

-- End of migration
