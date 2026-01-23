-- Migration 028: Invitation system for controlled user registration
-- Create invitation codes for group-specific access

-- 1. Create invitations table
CREATE TABLE IF NOT EXISTS invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  user_category user_category NOT NULL,
  created_by UUID REFERENCES profiles(id),
  max_uses INTEGER DEFAULT 1,
  used_count INTEGER DEFAULT 0,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create invitation_uses table to track who used which invitation
CREATE TABLE IF NOT EXISTS invitation_uses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invitation_id UUID REFERENCES invitations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  used_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Enable RLS
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitation_uses ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies for invitations
CREATE POLICY "Admins can manage invitations"
  ON invitations FOR ALL
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Anyone can validate invitations"
  ON invitations FOR SELECT
  USING (true); -- Needed for signup validation

-- 5. RLS Policies for invitation_uses
CREATE POLICY "Admins can view invitation uses"
  ON invitation_uses FOR SELECT
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "System can insert invitation uses"
  ON invitation_uses FOR INSERT
  WITH CHECK (true); -- Needed for signup process

-- 6. Function to generate unique invitation code
CREATE OR REPLACE FUNCTION generate_invitation_code()
RETURNS TEXT AS $$
DECLARE
  v_code TEXT;
  v_exists BOOLEAN;
BEGIN
  LOOP
    -- Generate 8-character code (uppercase letters and numbers)
    v_code := upper(substring(md5(random()::text || clock_timestamp()::text) from 1 for 8));
    
    -- Check if code already exists
    SELECT EXISTS(SELECT 1 FROM invitations WHERE code = v_code) INTO v_exists;
    
    EXIT WHEN NOT v_exists;
  END LOOP;
  
  RETURN v_code;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Function to create invitation
CREATE OR REPLACE FUNCTION create_invitation(
  p_user_category user_category,
  p_max_uses INTEGER DEFAULT 1,
  p_expires_in_days INTEGER DEFAULT 30
)
RETURNS TABLE (
  id UUID,
  code TEXT,
  user_category user_category,
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
  
  -- Generate unique code
  v_code := generate_invitation_code();
  
  -- Insert invitation
  INSERT INTO invitations (code, user_category, created_by, max_uses, expires_at)
  VALUES (
    v_code,
    p_user_category,
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
    i.max_uses,
    i.expires_at
  FROM invitations i
  WHERE i.id = v_invitation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Function to validate invitation
CREATE OR REPLACE FUNCTION validate_invitation(p_code TEXT)
RETURNS TABLE (
  valid BOOLEAN,
  user_category user_category,
  message TEXT
) AS $$
DECLARE
  v_invitation RECORD;
BEGIN
  -- Find invitation
  SELECT * INTO v_invitation
  FROM invitations
  WHERE code = p_code;
  
  -- Check if invitation exists
  IF NOT FOUND THEN
    RETURN QUERY SELECT false, NULL::user_category, 'Invalid invitation code';
    RETURN;
  END IF;
  
  -- Check if expired
  IF v_invitation.expires_at < NOW() THEN
    RETURN QUERY SELECT false, NULL::user_category, 'Invitation has expired';
    RETURN;
  END IF;
  
  -- Check if max uses reached
  IF v_invitation.used_count >= v_invitation.max_uses THEN
    RETURN QUERY SELECT false, NULL::user_category, 'Invitation has been fully used';
    RETURN;
  END IF;
  
  -- Valid invitation
  RETURN QUERY SELECT true, v_invitation.user_category, 'Valid invitation'::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Function to use invitation (called after successful signup)
CREATE OR REPLACE FUNCTION use_invitation(p_code TEXT, p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_invitation_id UUID;
BEGIN
  -- Get invitation ID
  SELECT id INTO v_invitation_id
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
  WHERE id = v_invitation_id;
  
  -- Record usage
  INSERT INTO invitation_uses (invitation_id, user_id)
  VALUES (v_invitation_id, p_user_id);
  
  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Function to get invitation statistics (admin only)
CREATE OR REPLACE FUNCTION get_invitation_stats()
RETURNS TABLE (
  total_invitations BIGINT,
  active_invitations BIGINT,
  expired_invitations BIGINT,
  total_uses BIGINT,
  by_category JSONB
) AS $$
BEGIN
  -- Check if user is admin
  IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin') THEN
    RAISE EXCEPTION 'Only admins can view invitation statistics';
  END IF;
  
  RETURN QUERY
  SELECT 
    COUNT(*)::BIGINT as total_invitations,
    COUNT(*) FILTER (WHERE expires_at > NOW() AND used_count < max_uses)::BIGINT as active_invitations,
    COUNT(*) FILTER (WHERE expires_at <= NOW())::BIGINT as expired_invitations,
    COALESCE(SUM(used_count), 0)::BIGINT as total_uses,
    jsonb_object_agg(
      user_category,
      jsonb_build_object(
        'count', COUNT(*),
        'used', SUM(used_count)
      )
    ) as by_category
  FROM invitations
  GROUP BY ();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. Grant permissions
GRANT EXECUTE ON FUNCTION generate_invitation_code TO authenticated;
GRANT EXECUTE ON FUNCTION create_invitation TO authenticated;
GRANT EXECUTE ON FUNCTION validate_invitation TO anon, authenticated;
GRANT EXECUTE ON FUNCTION use_invitation TO authenticated;
GRANT EXECUTE ON FUNCTION get_invitation_stats TO authenticated;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Invitation system created successfully';
  RAISE NOTICE 'Admins can now create invitation codes for controlled registration';
END $$;
