-- Migration 031: Tags System
-- Replaces fixed categories with dynamic tags

-- 1. Create tags table
CREATE TABLE IF NOT EXISTS tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create course_tags junction table
CREATE TABLE IF NOT EXISTS course_tags (
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (course_id, tag_id)
);

-- 3. Create indexes
CREATE INDEX IF NOT EXISTS idx_tags_slug ON tags(slug);
CREATE INDEX IF NOT EXISTS idx_course_tags_course ON course_tags(course_id);
CREATE INDEX IF NOT EXISTS idx_course_tags_tag ON course_tags(tag_id);

-- 4. Enable RLS
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_tags ENABLE ROW LEVEL SECURITY;

-- Tags are viewable by everyone (authenticated)
CREATE POLICY "Tags are viewable by everyone" ON tags
    FOR SELECT USING (true);

-- Only admins can manage tags
CREATE POLICY "Admins can manage tags" ON tags
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- Course tags are viewable by everyone
CREATE POLICY "Course tags are viewable by everyone" ON course_tags
    FOR SELECT USING (true);

-- Only admins can manage course tags
CREATE POLICY "Admins can manage course tags" ON course_tags
    FOR ALL USING (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- 5. Helper function to slugify text (if not exists)
CREATE OR REPLACE FUNCTION slugify(value TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN lower(
    regexp_replace(
      regexp_replace(
        translate(value, 'åäöÅÄÖ', 'aaoAAO'), -- Simple transliteration
        '[^a-zA-Z0-9\s-]', '', 'g' -- Remove special chars
      ),
      '\s+', '-', 'g' -- Replace spaces with hyphens
    )
  );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 6. Migrate existing categories to tags
DO $$
DECLARE
    r RECORD;
    v_tag_id UUID;
    v_category_name TEXT;
BEGIN
    -- Loop through all existing course categories
    -- Join with categories table to get the name
    -- Only run this if the tables exist (safe check)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'course_categories') THEN
        FOR r IN 
            SELECT cc.course_id, c.name as category_name
            FROM course_categories cc
            JOIN categories c ON cc.category_id = c.id
        LOOP
            v_category_name := r.category_name;
            
            -- Insert tag if not exists
            INSERT INTO tags (name, slug)
            VALUES (v_category_name, slugify(v_category_name))
            ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name -- Dummy update to get ID
            RETURNING id INTO v_tag_id;
            
            -- If returning failed, get the id
            IF v_tag_id IS NULL THEN
                SELECT id INTO v_tag_id FROM tags WHERE name = v_category_name;
            END IF;

            -- Link course to tag
            INSERT INTO course_tags (course_id, tag_id)
            VALUES (r.course_id, v_tag_id)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END IF;
END $$;

-- 7. Add some default tags
INSERT INTO tags (name, slug) VALUES
('Psykisk helse', 'psykisk-helse'),
('Mestring', 'mestring'),
('Kommunikasjon', 'kommunikasjon'),
('Lovverk', 'lovverk'),
('Ernæring', 'ernaering')
ON CONFLICT DO NOTHING;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Migration 031 completed: Tags system created and categories migrated';
END $$;
