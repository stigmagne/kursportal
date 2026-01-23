-- Migration 027: Group-based access control for courses
-- Add target_groups to courses and update RLS policies

-- 1. Add target_groups column to courses
ALTER TABLE courses 
ADD COLUMN IF NOT EXISTS target_groups TEXT[] DEFAULT '{}';

-- 2. Update existing courses to have all groups (backward compatibility)
UPDATE courses 
SET target_groups = ARRAY['søsken', 'foreldre', 'helsepersonell']::TEXT[]
WHERE target_groups = '{}' OR target_groups IS NULL;

-- 3. Drop old public access policy
DROP POLICY IF EXISTS "Published courses are viewable by everyone" ON courses;
DROP POLICY IF EXISTS "Anyone can view published courses" ON courses;

-- 4. Create new group-based access policy
CREATE POLICY "Courses visible to matching groups"
  ON courses FOR SELECT
  USING (
    published = true 
    AND (
      -- Admin can see all courses
      EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = auth.uid() 
        AND role = 'admin'
      )
      OR
      -- Authenticated users can see courses matching their category
      EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = auth.uid() 
        AND user_category::TEXT = ANY(target_groups)
      )
    )
  );

-- 5. Update lessons policy to require authentication
DROP POLICY IF EXISTS "Published lessons are viewable by everyone" ON lessons;

CREATE POLICY "Lessons visible to course-authorized users"
  ON lessons FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      JOIN course_modules cm ON c.id = cm.course_id
      WHERE cm.id = lessons.module_id
      AND c.published = true
      AND (
        -- Admin can see all
        EXISTS (
          SELECT 1 FROM profiles 
          WHERE id = auth.uid() 
          AND role = 'admin'
        )
        OR
        -- User's category matches course target groups
        EXISTS (
          SELECT 1 FROM profiles 
          WHERE id = auth.uid() 
          AND user_category::TEXT = ANY(c.target_groups)
        )
      )
    )
  );

-- 6. Update search functions to respect group access
DROP FUNCTION IF EXISTS search_courses(TEXT);

CREATE OR REPLACE FUNCTION search_courses(search_query TEXT)
RETURNS TABLE (
  id UUID,
  title TEXT,
  description TEXT,
  slug TEXT,
  rank REAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.title,
    c.description,
    c.slug,
    ts_rank(c.search_vector, websearch_to_tsquery('norwegian', search_query)) as rank
  FROM courses c
  WHERE 
    c.published = true
    AND c.search_vector @@ websearch_to_tsquery('norwegian', search_query)
    AND (
      -- Admin can see all
      EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = auth.uid() 
        AND role = 'admin'
      )
      OR
      -- User's category matches
      EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = auth.uid() 
        AND user_category::TEXT = ANY(c.target_groups)
      )
    )
  ORDER BY rank DESC
  LIMIT 10;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Update global_search to respect access control
DROP FUNCTION IF EXISTS global_search(TEXT);

CREATE OR REPLACE FUNCTION global_search(search_query TEXT)
RETURNS TABLE (
  id UUID,
  title TEXT,
  description TEXT,
  slug TEXT,
  type TEXT,
  rank REAL
) AS $$
BEGIN
  RETURN QUERY
  -- Search courses
  SELECT 
    c.id,
    c.title,
    c.description,
    c.slug,
    'course'::TEXT as type,
    ts_rank(c.search_vector, websearch_to_tsquery('norwegian', search_query)) as rank
  FROM courses c
  WHERE 
    c.published = true
    AND c.search_vector @@ websearch_to_tsquery('norwegian', search_query)
    AND (
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
      OR
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND user_category::TEXT = ANY(c.target_groups))
    )
  
  UNION ALL
  
  -- Search lessons (only from accessible courses)
  SELECT 
    l.id,
    l.title,
    l.content as description,
    l.slug,
    'lesson'::TEXT as type,
    ts_rank(l.search_vector, websearch_to_tsquery('norwegian', search_query)) as rank
  FROM lessons l
  JOIN course_modules cm ON l.module_id = cm.id
  JOIN courses c ON cm.course_id = c.id
  WHERE 
    c.published = true
    AND l.search_vector @@ websearch_to_tsquery('norwegian', search_query)
    AND (
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
      OR
      EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND user_category::TEXT = ANY(c.target_groups))
    )
  
  ORDER BY rank DESC
  LIMIT 20;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Group-based access control implemented successfully';
  RAISE NOTICE 'Courses now require authentication and group membership';
END $$;
