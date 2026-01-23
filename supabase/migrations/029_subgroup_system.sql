-- Migration 029: Subgroup system for isolated communities
-- Allows multiple isolated groups within each main category (søsken, foreldre, helsepersonell)

-- 1. Add subgroup column to profiles
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS subgroup TEXT;

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_profiles_subgroup ON profiles(subgroup);
CREATE INDEX IF NOT EXISTS idx_profiles_category_subgroup ON profiles(user_category, subgroup);

-- 2. Add subgroup column to invitations
ALTER TABLE invitations 
ADD COLUMN IF NOT EXISTS subgroup TEXT;

-- Make subgroup required for new invitations (existing ones can be NULL)
-- We'll update the create_invitation function to require it

-- 3. Update RLS policies for lesson_comments to respect subgroups
DROP POLICY IF EXISTS "Users can view comments" ON lesson_comments;
DROP POLICY IF EXISTS "Anyone can view comments" ON lesson_comments;

CREATE POLICY "Users can view comments in their subgroup"
  ON lesson_comments FOR SELECT
  USING (
    -- Admin can see all
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() 
      AND role = 'admin'
    )
    OR
    -- Users can see comments from same subgroup
    EXISTS (
      SELECT 1 FROM profiles p1
      JOIN profiles p2 ON p1.subgroup = p2.subgroup AND p1.user_category = p2.user_category
      WHERE p1.id = auth.uid()
      AND p2.id = lesson_comments.user_id
      AND p1.subgroup IS NOT NULL  -- Ensure subgroup is set
    )
  );

-- Users can insert comments
DROP POLICY IF EXISTS "Users can create comments" ON lesson_comments;
CREATE POLICY "Users can create comments"
  ON lesson_comments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update own comments
DROP POLICY IF EXISTS "Users can update own comments" ON lesson_comments;
CREATE POLICY "Users can update own comments"
  ON lesson_comments FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can delete own comments
DROP POLICY IF EXISTS "Users can delete own comments" ON lesson_comments;
CREATE POLICY "Users can delete own comments"
  ON lesson_comments FOR DELETE
  USING (auth.uid() = user_id);

-- 4. Update RLS policies for quiz_attempts to respect subgroups
DROP POLICY IF EXISTS "Users can view own attempts" ON quiz_attempts;
DROP POLICY IF EXISTS "Users can view all attempts" ON quiz_attempts;

CREATE POLICY "Users can view quiz attempts in their subgroup"
  ON quiz_attempts FOR SELECT
  USING (
    -- Own attempts
    user_id = auth.uid()
    OR
    -- Admin can see all
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() 
      AND role = 'admin'
    )
    OR
    -- Users can see attempts from same subgroup
    EXISTS (
      SELECT 1 FROM profiles p1
      JOIN profiles p2 ON p1.subgroup = p2.subgroup AND p1.user_category = p2.user_category
      WHERE p1.id = auth.uid()
      AND p2.id = quiz_attempts.user_id
      AND p1.subgroup IS NOT NULL
    )
  );

-- 5. Update validate_invitation function to return subgroup
DROP FUNCTION IF EXISTS validate_invitation(TEXT);

CREATE OR REPLACE FUNCTION validate_invitation(p_code TEXT)
RETURNS TABLE (
  valid BOOLEAN,
  user_category user_category,
  subgroup TEXT,
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
    RETURN QUERY SELECT false, NULL::user_category, NULL::TEXT, 'Invalid invitation code'::TEXT;
    RETURN;
  END IF;
  
  -- Check if expired
  IF v_invitation.expires_at < NOW() THEN
    RETURN QUERY SELECT false, NULL::user_category, NULL::TEXT, 'Invitation has expired'::TEXT;
    RETURN;
  END IF;
  
  -- Check if max uses reached
  IF v_invitation.used_count >= v_invitation.max_uses THEN
    RETURN QUERY SELECT false, NULL::user_category, NULL::TEXT, 'Invitation has been fully used'::TEXT;
    RETURN;
  END IF;
  
  -- Valid invitation - return category and subgroup
  RETURN QUERY SELECT true, v_invitation.user_category, v_invitation.subgroup, 'Valid invitation'::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Update create_invitation function to require subgroup
DROP FUNCTION IF EXISTS create_invitation(user_category, integer, integer);
DROP FUNCTION IF EXISTS create_invitation(user_category, text, integer, integer);

CREATE OR REPLACE FUNCTION create_invitation(
  p_user_category user_category,
  p_subgroup TEXT,
  p_max_uses INTEGER DEFAULT 1,
  p_expires_in_days INTEGER DEFAULT 30
)
RETURNS TABLE (
  id UUID,
  code TEXT,
  user_category user_category,
  subgroup TEXT,
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
  
  -- Validate subgroup
  IF p_subgroup IS NULL OR p_subgroup = '' THEN
    RAISE EXCEPTION 'Subgroup is required';
  END IF;
  
  -- Generate unique code
  v_code := generate_invitation_code();
  
  -- Insert invitation
  INSERT INTO invitations (code, user_category, subgroup, created_by, max_uses, expires_at)
  VALUES (
    v_code,
    p_user_category,
    p_subgroup,
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
    i.max_uses,
    i.expires_at
  FROM invitations i
  WHERE i.id = v_invitation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Update user_activity RLS to respect subgroups
DROP POLICY IF EXISTS "Users can view own activity" ON user_activity;
DROP POLICY IF EXISTS "Users can view all activity" ON user_activity;

CREATE POLICY "Users can view activity in their subgroup"
  ON user_activity FOR SELECT
  USING (
    -- Own activity
    user_id = auth.uid()
    OR
    -- Admin can see all
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE id = auth.uid() 
      AND role = 'admin'
    )
    OR
    -- Users can see activity from same subgroup
    EXISTS (
      SELECT 1 FROM profiles p1
      JOIN profiles p2 ON p1.subgroup = p2.subgroup AND p1.user_category = p2.user_category
      WHERE p1.id = auth.uid()
      AND p2.id = user_activity.user_id
      AND p1.subgroup IS NOT NULL
    )
  );

-- 8. Create helper function to get users in same subgroup
CREATE OR REPLACE FUNCTION get_subgroup_members()
RETURNS TABLE (
  id UUID,
  full_name TEXT,
  user_category user_category,
  subgroup TEXT,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.full_name,
    p.user_category,
    p.subgroup,
    p.created_at
  FROM profiles p
  WHERE p.subgroup = (
    SELECT subgroup FROM profiles WHERE id = auth.uid()
  )
  AND p.user_category = (
    SELECT user_category FROM profiles WHERE id = auth.uid()
  )
  AND p.id != auth.uid()
  ORDER BY p.full_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_subgroup_members TO authenticated;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Subgroup system implemented successfully';
  RAISE NOTICE 'Users are now isolated by subgroup within their main category';
  RAISE NOTICE 'Comments, quiz attempts, and activity are subgroup-specific';
END $$;
