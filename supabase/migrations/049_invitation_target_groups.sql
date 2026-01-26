-- Migration: 049_invitation_target_groups.sql
-- Purpose: Add target_group to invitations for role-based access control

-- =====================================================
-- 1. Create user_groups table
-- =====================================================
CREATE TABLE IF NOT EXISTS user_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    target_group TEXT NOT NULL CHECK (target_group IN ('sibling', 'parent', 'team-member', 'team-leader')),
    granted_via_invitation UUID REFERENCES invitations(id),
    granted_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, target_group)
);

CREATE INDEX idx_user_groups_user ON user_groups(user_id);
CREATE INDEX idx_user_groups_target ON user_groups(target_group);

-- =====================================================
-- 2. Add target_group to invitations
-- =====================================================
ALTER TABLE invitations 
ADD COLUMN IF NOT EXISTS target_group TEXT 
CHECK (target_group IS NULL OR target_group IN ('sibling', 'parent', 'team-member', 'team-leader'));

-- =====================================================
-- 3. Enable RLS on user_groups
-- =====================================================
ALTER TABLE user_groups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own groups"
    ON user_groups FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "System can insert user groups"
    ON user_groups FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Admins can manage all user groups"
    ON user_groups FOR ALL
    USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- =====================================================
-- 4. Validation function for group conflicts
-- =====================================================
CREATE OR REPLACE FUNCTION check_group_conflict()
RETURNS TRIGGER AS $$
DECLARE
    v_conflicting_group TEXT;
BEGIN
    -- Define conflicting pairs
    IF NEW.target_group = 'sibling' THEN
        v_conflicting_group := 'parent';
    ELSIF NEW.target_group = 'parent' THEN
        v_conflicting_group := 'sibling';
    ELSIF NEW.target_group = 'team-member' THEN
        v_conflicting_group := 'team-leader';
    ELSIF NEW.target_group = 'team-leader' THEN
        v_conflicting_group := 'team-member';
    END IF;
    
    -- Check if user already has the conflicting group
    IF EXISTS (
        SELECT 1 FROM user_groups 
        WHERE user_id = NEW.user_id 
        AND target_group = v_conflicting_group
    ) THEN
        RAISE EXCEPTION 'Cannot add group "%" because user already has conflicting group "%"', 
            NEW.target_group, v_conflicting_group;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_group_conflict
    BEFORE INSERT ON user_groups
    FOR EACH ROW
    EXECUTE FUNCTION check_group_conflict();

-- =====================================================
-- 5. Update validate_invitation to include target_group
-- =====================================================
DROP FUNCTION IF EXISTS validate_invitation(text);

CREATE OR REPLACE FUNCTION validate_invitation(p_code TEXT)
RETURNS TABLE (
    valid BOOLEAN,
    user_category user_category,
    target_group TEXT,
    message TEXT
) AS $$
DECLARE
    v_invitation RECORD;
BEGIN
    -- Find invitation
    SELECT * INTO v_invitation
    FROM invitations i
    WHERE i.code = p_code;
    
    -- Check if invitation exists
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, NULL::user_category, NULL::TEXT, 'Invalid invitation code';
        RETURN;
    END IF;
    
    -- Check if expired
    IF v_invitation.expires_at < NOW() THEN
        RETURN QUERY SELECT false, NULL::user_category, NULL::TEXT, 'Invitation has expired';
        RETURN;
    END IF;
    
    -- Check if max uses reached
    IF v_invitation.used_count >= v_invitation.max_uses THEN
        RETURN QUERY SELECT false, NULL::user_category, NULL::TEXT, 'Invitation has been fully used';
        RETURN;
    END IF;
    
    -- Valid invitation
    RETURN QUERY SELECT true, v_invitation.user_category, v_invitation.target_group, 'Valid invitation'::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 6. Update use_invitation to assign user_group
-- =====================================================
CREATE OR REPLACE FUNCTION use_invitation(p_code TEXT, p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_invitation RECORD;
BEGIN
    -- Get invitation
    SELECT * INTO v_invitation
    FROM invitations
    WHERE code = p_code
    AND expires_at > NOW()
    AND used_count < max_uses;
    
    IF NOT FOUND THEN
        RETURN false;
    END IF;
    
    -- Increment used_count
    UPDATE invitations
    SET used_count = used_count + 1,
        updated_at = NOW()
    WHERE id = v_invitation.id;
    
    -- Record usage
    INSERT INTO invitation_uses (invitation_id, user_id)
    VALUES (v_invitation.id, p_user_id);
    
    -- Assign target_group to user if specified
    IF v_invitation.target_group IS NOT NULL THEN
        INSERT INTO user_groups (user_id, target_group, granted_via_invitation)
        VALUES (p_user_id, v_invitation.target_group, v_invitation.id)
        ON CONFLICT (user_id, target_group) DO NOTHING;
    END IF;
    
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 7. Function to add group to existing user
-- =====================================================
CREATE OR REPLACE FUNCTION add_user_group(p_user_id UUID, p_target_group TEXT, p_invitation_id UUID DEFAULT NULL)
RETURNS BOOLEAN AS $$
BEGIN
    -- Validate target_group
    IF p_target_group NOT IN ('sibling', 'parent', 'team-member', 'team-leader') THEN
        RAISE EXCEPTION 'Invalid target_group: %', p_target_group;
    END IF;
    
    -- Insert (trigger will check for conflicts)
    INSERT INTO user_groups (user_id, target_group, granted_via_invitation)
    VALUES (p_user_id, p_target_group, p_invitation_id)
    ON CONFLICT (user_id, target_group) DO NOTHING;
    
    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
        RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 8. Function to get user's groups
-- =====================================================
CREATE OR REPLACE FUNCTION get_user_groups(p_user_id UUID DEFAULT NULL)
RETURNS TABLE (
    target_group TEXT,
    granted_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT ug.target_group, ug.granted_at
    FROM user_groups ug
    WHERE ug.user_id = COALESCE(p_user_id, auth.uid())
    ORDER BY ug.granted_at;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 9. Update can_access_course to use user_groups
-- =====================================================
CREATE OR REPLACE FUNCTION can_access_course(p_user_id UUID, p_course_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_course_target_group TEXT;
    v_user_has_group BOOLEAN;
BEGIN
    -- Get course target_group
    SELECT target_group INTO v_course_target_group
    FROM courses
    WHERE id = p_course_id;
    
    -- If course has no target_group, it's public
    IF v_course_target_group IS NULL THEN
        RETURN true;
    END IF;
    
    -- Check if user has the required group
    SELECT EXISTS (
        SELECT 1 FROM user_groups
        WHERE user_id = p_user_id
        AND target_group = v_course_target_group
    ) INTO v_user_has_group;
    
    RETURN v_user_has_group;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 10. Update create_invitation to include target_group
-- =====================================================
DROP FUNCTION IF EXISTS create_invitation(user_category, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS create_invitation(user_category, TEXT, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS create_invitation(user_category, uuid, TEXT, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION create_invitation(
    p_user_category user_category,
    p_target_group TEXT DEFAULT NULL,
    p_max_uses INTEGER DEFAULT 1,
    p_expires_in_days INTEGER DEFAULT 30
)
RETURNS TABLE (
    id UUID,
    code TEXT,
    user_category user_category,
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
    
    -- Insert invitation
    INSERT INTO invitations (code, user_category, target_group, created_by, max_uses, expires_at)
    VALUES (
        v_code,
        p_user_category,
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
        i.target_group,
        i.max_uses,
        i.expires_at
    FROM invitations i
    WHERE i.id = v_invitation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 11. Migrate existing users from user_type to user_groups
-- =====================================================
DO $$
DECLARE
    v_user RECORD;
BEGIN
    FOR v_user IN SELECT id, user_type FROM profiles WHERE user_type IS NOT NULL LOOP
        -- Handle 'sibling' type
        IF v_user.user_type = 'sibling' THEN
            INSERT INTO user_groups (user_id, target_group)
            VALUES (v_user.id, 'sibling')
            ON CONFLICT DO NOTHING;
        -- Handle 'parent' type
        ELSIF v_user.user_type = 'parent' THEN
            INSERT INTO user_groups (user_id, target_group)
            VALUES (v_user.id, 'parent')
            ON CONFLICT DO NOTHING;
        -- Handle 'both' type (was sibling + parent, but now invalid - default to sibling)
        ELSIF v_user.user_type = 'both' THEN
            INSERT INTO user_groups (user_id, target_group)
            VALUES (v_user.id, 'sibling')
            ON CONFLICT DO NOTHING;
        END IF;
    END LOOP;
END $$;

-- =====================================================
-- 12. Grant permissions
-- =====================================================
GRANT EXECUTE ON FUNCTION add_user_group TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_groups TO authenticated;
GRANT SELECT ON user_groups TO authenticated;
