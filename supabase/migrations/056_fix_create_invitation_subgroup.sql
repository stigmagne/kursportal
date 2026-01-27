-- Migration: 056_fix_create_invitation_subgroup.sql
-- Purpose: Add subgroup parameter to create_invitation function

-- Drop all existing versions to avoid signature conflicts
DROP FUNCTION IF EXISTS create_invitation(user_category, TEXT, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS create_invitation(user_category, TEXT, TEXT, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS create_invitation(TEXT, TEXT, TEXT, INTEGER, INTEGER);

-- Create updated function with subgroup support
CREATE OR REPLACE FUNCTION create_invitation(
    p_user_category TEXT,
    p_subgroup TEXT DEFAULT NULL,
    p_target_group TEXT DEFAULT NULL,
    p_max_uses INTEGER DEFAULT 1,
    p_expires_in_days INTEGER DEFAULT 30
)
RETURNS TABLE (
    id UUID,
    code TEXT,
    user_category TEXT,
    subgroup TEXT,
    target_group TEXT,
    max_uses INTEGER,
    expires_at TIMESTAMPTZ
) AS $$
DECLARE
    v_code TEXT;
    v_invitation_id UUID;
BEGIN
    -- Check if user is admin
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND role = 'admin') THEN
        RAISE EXCEPTION 'Only admins can create invitations';
    END IF;
    
    -- Validate target_group if provided
    IF p_target_group IS NOT NULL AND p_target_group NOT IN ('sibling', 'parent', 'team-member', 'team-leader') THEN
        RAISE EXCEPTION 'Invalid target_group: %', p_target_group;
    END IF;
    
    -- Generate unique code
    v_code := generate_invitation_code();
    
    -- Insert invitation with subgroup
    INSERT INTO invitations (code, user_category, subgroup, target_group, created_by, max_uses, expires_at)
    VALUES (
        v_code,
        p_user_category,
        p_subgroup,
        p_target_group,
        auth.uid(),
        p_max_uses,
        NOW() + (p_expires_in_days || ' days')::INTERVAL
    )
    RETURNING invitations.id INTO v_invitation_id;
    
    -- Return invitation details
    RETURN QUERY
    SELECT 
        i.id,
        i.code,
        i.user_category,
        i.subgroup,
        i.target_group,
        i.max_uses,
        i.expires_at
    FROM invitations i
    WHERE i.id = v_invitation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION create_invitation(TEXT, TEXT, TEXT, INTEGER, INTEGER) TO authenticated;
