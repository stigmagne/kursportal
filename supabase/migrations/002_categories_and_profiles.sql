-- Migration: Add Categories System and Profile Enhancements
-- Run this in Supabase SQL Editor after the initial schema

-- 1. ADD PROFILE ENHANCEMENTS
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS bio text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url text;

-- ADD COURSE ENHANCEMENTS
ALTER TABLE public.courses ADD COLUMN IF NOT EXISTS cover_image text;

-- 2. CREATE CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS public.categories (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  name text NOT NULL UNIQUE,
  description text,
  color text DEFAULT '#3b82f6', -- Default blue color
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  created_by uuid REFERENCES public.profiles(id)
);

-- Enable RLS for categories
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- Policies for categories
CREATE POLICY "Anyone can view categories"
  ON categories FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage categories"
  ON categories FOR ALL
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- 3. CREATE COURSE_CATEGORIES (Many-to-Many)
CREATE TABLE IF NOT EXISTS public.course_categories (
  course_id uuid REFERENCES public.courses(id) ON DELETE CASCADE,
  category_id uuid REFERENCES public.categories(id) ON DELETE CASCADE,
  PRIMARY KEY (course_id, category_id)
);

-- Enable RLS
ALTER TABLE public.course_categories ENABLE ROW LEVEL SECURITY;

-- Policies for course_categories
CREATE POLICY "Anyone can view course categories"
  ON course_categories FOR SELECT
  USING (true);

CREATE POLICY "Admins can manage course categories"
  ON course_categories FOR ALL
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- 4. CREATE USER_CATEGORIES (Member Assignments)
CREATE TABLE IF NOT EXISTS public.user_categories (
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  category_id uuid REFERENCES public.categories(id) ON DELETE CASCADE,
  assigned_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  assigned_by uuid REFERENCES public.profiles(id),
  PRIMARY KEY (user_id, category_id)
);

-- Enable RLS
ALTER TABLE public.user_categories ENABLE ROW LEVEL SECURITY;

-- Policies for user_categories
CREATE POLICY "Users can view their own category assignments"
  ON user_categories FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all category assignments"
  ON user_categories FOR SELECT
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can manage category assignments"
  ON user_categories FOR ALL
  USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- 5. CREATE HELPFUL VIEW FOR COURSE FILTERING
CREATE OR REPLACE VIEW user_accessible_courses AS
SELECT DISTINCT
  c.id,
  c.title,
  c.description,
  c.content,
  c.published,
  c.created_at,
  c.author_id,
  p.id as user_id
FROM courses c
CROSS JOIN profiles p
WHERE c.published = true
  AND (
    -- User has category assignment that matches course
    EXISTS (
      SELECT 1 FROM user_categories uc
      JOIN course_categories cc ON cc.category_id = uc.category_id
      WHERE uc.user_id = p.id AND cc.course_id = c.id
    )
    -- OR user has no category assignments (show all published)
    OR NOT EXISTS (
      SELECT 1 FROM user_categories uc WHERE uc.user_id = p.id
    )
    -- OR user is admin
    OR EXISTS (
      SELECT 1 FROM profiles WHERE id = p.id AND role = 'admin'
    )
  );

-- 6. ADD SAMPLE CATEGORIES (Optional - for demo purposes)
INSERT INTO public.categories (name, description, color) VALUES
  ('Introductory', 'Getting started and basics', '#3b82f6'),
  ('Coping Strategies', 'Immediate help and techniques', '#10b981'),
  ('Understanding Trauma', 'Education and awareness', '#8b5cf6'),
  ('Advanced Recovery', 'Long-term healing', '#f59e0b')
ON CONFLICT (name) DO NOTHING;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Migration completed successfully!';
  RAISE NOTICE 'Created tables: categories, course_categories, user_categories';
  RAISE NOTICE 'Added columns: profiles.bio, profiles.avatar_url';
  RAISE NOTICE 'Created view: user_accessible_courses';
END $$;
