-- Migration 035: Dynamic Groups System
-- Replaces hardcoded user_categories with a dynamic groups table

-- 1. Create groups table
CREATE TABLE IF NOT EXISTS public.groups (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable RLS
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;

-- 3. Policies
-- Admins can do everything
CREATE POLICY "Admins can manage groups" ON public.groups
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Everyone can read groups (needed for signup/invitation validation)
CREATE POLICY "Everyone can view groups" ON public.groups
  FOR SELECT USING (true);


-- 4. Seed initial groups from existing enum logic
INSERT INTO public.groups (name, description) VALUES 
  ('søsken', 'For søsken av pasienter'),
  ('foreldre', 'For foreldre og foresatte'),
  ('helsepersonell', 'For helsepersonell og fagfolk')
ON CONFLICT (name) DO NOTHING;


-- 5. Add group_id to profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS group_id UUID REFERENCES public.groups(id);

-- 6. Migrate existing profiles to groups
DO $$
DECLARE
  g_record RECORD;
BEGIN
  FOR g_record IN SELECT * FROM public.groups LOOP
    UPDATE public.profiles 
    SET group_id = g_record.id 
    WHERE user_category::text = g_record.name;
  END LOOP;
END $$;


-- 7. Add group_id to invitations
ALTER TABLE public.invitations 
ADD COLUMN IF NOT EXISTS group_id UUID REFERENCES public.groups(id);

-- 8. Migrate existing invitations
DO $$
DECLARE
  g_record RECORD;
BEGIN
  FOR g_record IN SELECT * FROM public.groups LOOP
    UPDATE public.invitations 
    SET group_id = g_record.id 
    WHERE user_category::text = g_record.name;
  END LOOP;
END $$;


-- 9. Create course_groups junction table
CREATE TABLE IF NOT EXISTS public.course_groups (
  course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
  group_id UUID REFERENCES public.groups(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (course_id, group_id)
);

ALTER TABLE public.course_groups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage course groups" ON public.course_groups
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Public view course groups" ON public.course_groups
  FOR SELECT USING (true);

-- 10. Migrate existing course target_groups to course_groups
DO $$
DECLARE
  c_record RECORD;
  g_name TEXT;
  g_id UUID;
BEGIN
  FOR c_record IN SELECT id, target_groups FROM public.courses WHERE target_groups IS NOT NULL LOOP
    IF array_length(c_record.target_groups, 1) > 0 THEN
      FOREACH g_name IN ARRAY c_record.target_groups LOOP
        -- Find group id
        SELECT id INTO g_id FROM public.groups WHERE name = g_name;
        
        IF g_id IS NOT NULL THEN
          INSERT INTO public.course_groups (course_id, group_id)
          VALUES (c_record.id, g_id)
          ON CONFLICT DO NOTHING;
        END IF;
      END LOOP;
    END IF;
  END LOOP;
END $$;


-- 11. Update RLS policies for Courses to use new table
-- We keep 'target_groups' column for now as backup/legacy but use the new table for logic

DROP POLICY IF EXISTS "Courses visible to matching groups" ON courses;
DROP POLICY IF EXISTS "Courses visible to matching groups" ON courses; -- Duplicate drop to be safe

-- IMPORTANT: Access Control Policy fix
-- We need to drop ANY policy that relies on user_category enum before altering table columns.
-- DROP specific legacy policies if they exist (based on user feedback)
DROP POLICY IF EXISTS "Users can view courses for their category" ON courses; 


CREATE POLICY "Courses visible to matching groups"
  ON courses FOR SELECT
  USING (
    published = true 
    AND (
      -- Admin
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
      OR
      -- Subscription (Paywall bypass - Netflix model)
      EXISTS (
        SELECT 1 FROM subscriptions 
        WHERE user_id = auth.uid() 
        AND status IN ('active', 'trialing')
      )
      OR
      -- User in allowed group
      EXISTS (
        SELECT 1 FROM course_groups cg
        JOIN profiles p ON p.group_id = cg.group_id
        WHERE cg.course_id = courses.id
        AND p.id = auth.uid()
      )
    )
  );

-- 12. Helper function to create a new group
CREATE OR REPLACE FUNCTION create_new_group(
  p_name TEXT, 
  p_description TEXT
)
RETURNS UUID AS $$
DECLARE
  v_id UUID;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin') THEN
    RAISE EXCEPTION 'Only admins can create groups';
  END IF;

  INSERT INTO public.groups (name, description)
  VALUES (p_name, p_description)
  RETURNING id INTO v_id;
  
  RETURN v_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 13. Update create_invitation to use group_id
-- We overload or replace the function. Let's create a NEW one 'create_group_invitation'
-- and keep the old one but modifying it to lookup group_id?
-- Better to create a new robust one.

CREATE OR REPLACE FUNCTION create_group_invitation(
  p_group_id UUID,
  p_subgroup TEXT,
  p_max_uses INTEGER DEFAULT 1,
  p_expires_in_days INTEGER DEFAULT 30
)
RETURNS TABLE (
  id UUID,
  code TEXT,
  group_id UUID,
  subgroup TEXT,
  max_uses INTEGER,
  expires_at TIMESTAMPTZ
) AS $$
DECLARE
  v_code TEXT;
  v_invitation_id UUID;
  v_cat_name TEXT;
BEGIN
  -- Check admin
  IF NOT EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND role = 'admin') THEN
    RAISE EXCEPTION 'Only admins can create invitations';
  END IF;
  
  -- Get group name to populate legacy 'user_category' column (schema requires it NOT NULL currently)
  SELECT name INTO v_cat_name FROM public.groups WHERE id = p_group_id;
  
  IF v_cat_name IS NULL THEN
     RAISE EXCEPTION 'Invalid group ID';
  END IF;

  v_code := generate_invitation_code();
  
  -- Insert (populating both new group_id and legacy user_category)
  INSERT INTO invitations (code, user_category, group_id, subgroup, created_by, max_uses, expires_at)
  VALUES (
    v_code,
    -- We can't cast to enum here anymore because we are about to change the column to TEXT.
    -- But at this point in the script execution, the column might still be ENUM?
    -- Actually, this function is created now but executed later. Any PLPGSQL syntax check might complain if we use 'text' before ALTER?
    -- No, usually it's runtime check.
    v_cat_name, 
    p_group_id,
    p_subgroup,
    auth.uid(),
    p_max_uses,
    NOW() + (p_expires_in_days || ' days')::INTERVAL
  )
  RETURNING invitations.id INTO v_invitation_id;
  
  RETURN QUERY
  SELECT 
    i.id,
    i.code,
    i.group_id,
    i.subgroup,
    i.max_uses,
    i.expires_at
  FROM invitations i
  WHERE i.id = v_invitation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- IMPORTANT Fix for user_category enum limitation:
-- We need to allow custom values or bypass the enum constraint.
-- Best approach: Change the column type to TEXT to support any group name.

-- Before altering policies, we MUST drop policies that depend on the column being an enum.
-- Some legacy policies might be hanging around.
-- We'll try to drop common potential blockers on profiles.

DROP POLICY IF EXISTS "Courses visible to matching groups" ON courses; -- Already dropped above
DROP POLICY IF EXISTS "Members can view published courses" ON courses; -- Legacy?

-- Now alter the columns
-- Drop conflicting policies on lessons
DROP POLICY IF EXISTS "Lessons visible to course-authorized users" ON lessons;
-- Drop conflicting policies on other tables dependent on user_category
DROP POLICY IF EXISTS "Users can view comments in their subgroup" ON lesson_comments;
DROP POLICY IF EXISTS "Users can view quiz attempts in their subgroup" ON quiz_attempts;
DROP POLICY IF EXISTS "Users can view activity in their subgroup" ON user_activity;

-- Now alter the columns
ALTER TABLE invitations ALTER COLUMN user_category TYPE TEXT;
ALTER TABLE profiles ALTER COLUMN user_category TYPE TEXT;

-- Re-create the lessons policy using the new course_groups table
CREATE POLICY "Lessons visible to course-authorized users"
  ON lessons FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      JOIN course_modules cm ON c.id = cm.course_id
      WHERE cm.id = lessons.module_id
      AND c.published = true
      AND (
        -- Admin
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
        OR
        -- Subscription (Paywall bypass)
        EXISTS (
          SELECT 1 FROM subscriptions 
          WHERE user_id = auth.uid() 
          AND status IN ('active', 'trialing')
        )
        OR
        -- User in allowed group
        EXISTS (
          SELECT 1 FROM course_groups cg
          JOIN profiles p ON p.group_id = cg.group_id
          WHERE cg.course_id = c.id
          AND p.id = auth.uid()
        )
      )
    )
  );

-- Re-create Comments Policy (Group-based)
CREATE POLICY "Users can view comments in their subgroup"
  ON lesson_comments FOR SELECT
  USING (
    -- Admin can see all
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    OR
    -- Users can see comments from same group AND subgroup
    EXISTS (
      SELECT 1 FROM profiles p1
      JOIN profiles p2 ON p1.group_id = p2.group_id AND p1.subgroup = p2.subgroup
      WHERE p1.id = auth.uid()
      AND p2.id = lesson_comments.user_id
      AND p1.subgroup IS NOT NULL
    )
  );

-- Re-create Quiz Attempts Policy (Group-based)
CREATE POLICY "Users can view quiz attempts in their subgroup"
  ON quiz_attempts FOR SELECT
  USING (
    -- Own attempts
    user_id = auth.uid()
    OR
    -- Admin can see all
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    OR
    -- Users can see attempts from same group AND subgroup
    EXISTS (
      SELECT 1 FROM profiles p1
      JOIN profiles p2 ON p1.group_id = p2.group_id AND p1.subgroup = p2.subgroup
      WHERE p1.id = auth.uid()
      AND p2.id = quiz_attempts.user_id
      AND p1.subgroup IS NOT NULL
    )
  );

-- Re-create User Activity Policy (Group-based)
CREATE POLICY "Users can view activity in their subgroup"
  ON user_activity FOR SELECT
  USING (
    -- Own activity
    user_id = auth.uid()
    OR
    -- Admin can see all
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    OR
    -- Users can see activity from same group AND subgroup
    EXISTS (
      SELECT 1 FROM profiles p1
      JOIN profiles p2 ON p1.group_id = p2.group_id AND p1.subgroup = p2.subgroup
      WHERE p1.id = auth.uid()
      AND p2.id = user_activity.user_id
      AND p1.subgroup IS NOT NULL
    )
  );

-- Now we can insert any string into user_category as a fallback name.
