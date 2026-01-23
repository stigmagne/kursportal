-- Migration 005: User Categories & Course Access Control (SAFE VERSION)
-- Implements user segmentation (søsken, foreldre, helsepersonell) with course access restrictions

-- ============================================
-- 1. USER CATEGORY ENUM
-- ============================================
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_category') THEN
        CREATE TYPE user_category AS ENUM ('søsken', 'foreldre', 'helsepersonell');
    END IF;
END $$;

-- Add category to profiles table
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS user_category user_category;

-- Drop existing constraint if it exists
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS user_category_required;

-- Make it required for non-admin users
ALTER TABLE public.profiles
ADD CONSTRAINT user_category_required 
CHECK (role = 'admin' OR user_category IS NOT NULL);

COMMENT ON COLUMN public.profiles.user_category IS 'User type: søsken (siblings), foreldre (parents), helsepersonell (healthcare professionals)';

-- ============================================
-- 2. COURSE CATEGORY ASSIGNMENTS
-- ============================================
-- Track which user categories can access each course
CREATE TABLE IF NOT EXISTS public.course_user_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    user_category user_category NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(course_id, user_category)
);

CREATE INDEX IF NOT EXISTS idx_course_user_categories_course ON public.course_user_categories(course_id);
CREATE INDEX IF NOT EXISTS idx_course_user_categories_category ON public.course_user_categories(user_category);

COMMENT ON TABLE public.course_user_categories IS 'Maps courses to user categories that can access them';

-- ============================================
-- 3. RLS POLICIES
-- ============================================
ALTER TABLE public.course_user_categories ENABLE ROW LEVEL SECURITY;

-- Drop and recreate policies safely
DROP POLICY IF EXISTS "Admins can manage course category assignments" ON public.course_user_categories;
DROP POLICY IF EXISTS "Users can view course categories" ON public.course_user_categories;

CREATE POLICY "Admins can manage course category assignments" ON public.course_user_categories
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

CREATE POLICY "Users can view course categories" ON public.course_user_categories
    FOR SELECT USING (true);

-- ============================================
-- 4. UPDATE COURSES RLS FOR CATEGORY FILTERING
-- ============================================
-- Drop all existing course viewing policies
DROP POLICY IF EXISTS "Users can view published courses" ON public.courses;
DROP POLICY IF EXISTS "Users can view courses for their category" ON public.courses;
DROP POLICY IF EXISTS "Admins can manage all courses" ON public.courses;
DROP POLICY IF EXISTS "Admins can do anything with courses" ON public.courses;

-- Recreate policies with category filtering
CREATE POLICY "Admins can manage all courses" ON public.courses
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
    );

-- Users only see published courses for their category
CREATE POLICY "Users can view courses for their category" ON public.courses
    FOR SELECT USING (
        published = true AND (
            -- Course has no category restrictions (accessible to all)
            NOT EXISTS (
                SELECT 1 FROM public.course_user_categories
                WHERE course_user_categories.course_id = courses.id
            )
            OR
            -- Course is available to user's category
            EXISTS (
                SELECT 1 FROM public.course_user_categories cuc
                JOIN public.profiles p ON p.user_category = cuc.user_category
                WHERE cuc.course_id = courses.id
                AND p.id = auth.uid()
            )
        )
    );

-- ============================================
-- 5. HELPER FUNCTIONS
-- ============================================

-- Function to check if user can access a course
CREATE OR REPLACE FUNCTION can_user_access_course(p_user_id UUID, p_course_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    user_cat user_category;
    user_is_admin BOOLEAN;
    has_restrictions BOOLEAN;
BEGIN
    -- Get user category and role
    SELECT user_category, (role = 'admin') INTO user_cat, user_is_admin
    FROM public.profiles
    WHERE id = p_user_id;
    
    -- Admins can access all
    IF user_is_admin THEN
        RETURN true;
    END IF;
    
    -- Check if course has category restrictions
    SELECT EXISTS (
        SELECT 1 FROM public.course_user_categories
        WHERE course_id = p_course_id
    ) INTO has_restrictions;
    
    -- No restrictions = everyone can access
    IF NOT has_restrictions THEN
        RETURN true;
    END IF;
    
    -- Check if user's category is allowed
    RETURN EXISTS (
        SELECT 1 FROM public.course_user_categories
        WHERE course_id = p_course_id
        AND user_category = user_cat
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user-accessible courses
CREATE OR REPLACE FUNCTION get_accessible_courses(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    published BOOLEAN,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id, c.title, c.description, c.published, c.created_at
    FROM public.courses c
    WHERE can_user_access_course(p_user_id, c.id)
    AND c.published = true
    ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 6. CREATE VIEW FOR EASY QUERYING
-- ============================================
CREATE OR REPLACE VIEW user_accessible_courses_with_category AS
SELECT 
    c.*,
    array_agg(DISTINCT cuc.user_category) FILTER (WHERE cuc.user_category IS NOT NULL) as allowed_categories
FROM public.courses c
LEFT JOIN public.course_user_categories cuc ON c.id = cuc.course_id
GROUP BY c.id;

COMMENT ON VIEW user_accessible_courses_with_category IS 'Courses with their allowed user categories';

-- ============================================
-- 7. DATA MIGRATION: SET DEFAULT CATEGORY FOR EXISTING USERS
-- ============================================
-- For existing non-admin users without a category, set a default
-- You may want to manually review and update these
UPDATE public.profiles
SET user_category = 'søsken' -- Default to siblings
WHERE role != 'admin' 
AND user_category IS NULL;
