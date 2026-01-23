-- Migration 018: Search Functionality
-- Adds full-text search capabilities for courses and lessons

-- Add search vector columns
ALTER TABLE courses
ADD COLUMN IF NOT EXISTS search_vector tsvector;

ALTER TABLE lessons
ADD COLUMN IF NOT EXISTS search_vector tsvector;

-- Function to update course search vector
CREATE OR REPLACE FUNCTION update_course_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector := 
    setweight(to_tsvector('english', coalesce(NEW.title,'')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.description,'')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update lesson search vector
CREATE OR REPLACE FUNCTION update_lesson_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector := 
    setweight(to_tsvector('english', coalesce(NEW.title,'')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.description,'')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to automatically update search vectors
DROP TRIGGER IF EXISTS trigger_update_course_search ON courses;
CREATE TRIGGER trigger_update_course_search
  BEFORE INSERT OR UPDATE ON courses
  FOR EACH ROW
  EXECUTE FUNCTION update_course_search_vector();

DROP TRIGGER IF EXISTS trigger_update_lesson_search ON lessons;
CREATE TRIGGER trigger_update_lesson_search
  BEFORE INSERT OR UPDATE ON lessons
  FOR EACH ROW
  EXECUTE FUNCTION update_lesson_search_vector();

-- Update existing records
UPDATE courses SET search_vector = 
  setweight(to_tsvector('english', coalesce(title,'')), 'A') ||
  setweight(to_tsvector('english', coalesce(description,'')), 'B');

UPDATE lessons SET search_vector = 
  setweight(to_tsvector('english', coalesce(title,'')), 'A') ||
  setweight(to_tsvector('english', coalesce(description,'')), 'B');

-- Create GIN indexes for fast full-text search
CREATE INDEX IF NOT EXISTS idx_courses_search ON courses USING gin(search_vector);
CREATE INDEX IF NOT EXISTS idx_lessons_search ON lessons USING gin(search_vector);

-- Search function for courses
CREATE OR REPLACE FUNCTION search_courses(search_query TEXT)
RETURNS TABLE (
  id UUID,
  title TEXT,
  description TEXT,
  thumbnail_url TEXT,
  rank REAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.title,
    c.description,
    c.thumbnail_url,
    ts_rank(c.search_vector, plainto_tsquery('english', search_query)) as rank
  FROM courses c
  WHERE c.search_vector @@ plainto_tsquery('english', search_query)
    AND c.published = true
  ORDER BY rank DESC, c.created_at DESC
  LIMIT 20;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Search function for lessons
CREATE OR REPLACE FUNCTION search_lessons(search_query TEXT)
RETURNS TABLE (
  id UUID,
  title TEXT,
  description TEXT,
  course_id UUID,
  course_title TEXT,
  rank REAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.title,
    l.content,
    m.course_id,
    c.title as course_title,
    ts_rank(l.search_vector, plainto_tsquery('english', search_query)) as rank
  FROM lessons l
  JOIN course_modules m ON l.module_id = m.id
  JOIN courses c ON m.course_id = c.id
  WHERE l.search_vector @@ plainto_tsquery('english', search_query)
    AND c.published = true
  ORDER BY rank DESC, l.created_at DESC
  LIMIT 20;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Combined search function
CREATE OR REPLACE FUNCTION global_search(search_query TEXT)
RETURNS TABLE (
  result_type TEXT,
  id UUID,
  title TEXT,
  description TEXT,
  url TEXT,
  rank REAL
) AS $$
BEGIN
  RETURN QUERY
  -- Search courses
  SELECT 
    'course'::TEXT as result_type,
    c.id,
    c.title,
    c.description,
    '/courses/' || c.id::TEXT as url,
    ts_rank(c.search_vector, plainto_tsquery('english', search_query)) as rank
  FROM courses c
  WHERE c.search_vector @@ plainto_tsquery('english', search_query)
    AND c.published = true
  
  UNION ALL
  
  -- Search lessons
  SELECT 
    'lesson'::TEXT as result_type,
    l.id,
    l.title,
    substring(l.description, 1, 200) as description,
    '/courses/' || m.course_id::TEXT || '/learn/' || l.id::TEXT as url,
    ts_rank(l.search_vector, plainto_tsquery('english', search_query)) as rank
  FROM lessons l
  JOIN course_modules m ON l.module_id = m.id
  JOIN courses c ON m.course_id = c.id
  WHERE l.search_vector @@ plainto_tsquery('english', search_query)
    AND c.published = true
  
  ORDER BY rank DESC
  LIMIT 20;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Table for storing recent searches (optional, for analytics)
CREATE TABLE IF NOT EXISTS search_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  query TEXT NOT NULL,
  results_count INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_search_history_user ON search_history(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_search_history_query ON search_history(query);

-- Enable RLS
ALTER TABLE search_history ENABLE ROW LEVEL SECURITY;

-- Users can view own search history
CREATE POLICY "Users can view own search history"
  ON search_history FOR SELECT
  USING (auth.uid() = user_id);

-- Users can create own search history
CREATE POLICY "Users can create own search history"
  ON search_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Migration 018 completed: Search functionality with full-text search';
END $$;
