-- Migration: 039_add_course_slug.sql
-- Purpose: Add slug column to courses table for URL-friendly identifiers

-- Add slug column to courses
ALTER TABLE courses ADD COLUMN IF NOT EXISTS slug TEXT;

-- Add category_id to courses if not exists (for linking to categories)
ALTER TABLE courses ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES categories(id);

-- Create index on category_id
CREATE INDEX IF NOT EXISTS idx_courses_category ON courses(category_id);

-- Generate unique slugs for existing courses
-- First, create a function to generate slugs with uniqueness
DO $$
DECLARE
    course_rec RECORD;
    base_slug TEXT;
    final_slug TEXT;
    counter INTEGER;
BEGIN
    FOR course_rec IN SELECT id, title FROM courses WHERE slug IS NULL ORDER BY created_at LOOP
        -- Generate base slug from title
        base_slug := LOWER(course_rec.title);
        -- Replace Norwegian characters
        base_slug := REGEXP_REPLACE(base_slug, '[æÆ]', 'ae', 'g');
        base_slug := REGEXP_REPLACE(base_slug, '[øØ]', 'o', 'g');
        base_slug := REGEXP_REPLACE(base_slug, '[åÅ]', 'a', 'g');
        -- Replace spaces and special chars with hyphens
        base_slug := REGEXP_REPLACE(base_slug, '[^a-z0-9]+', '-', 'g');
        -- Remove leading/trailing hyphens
        base_slug := REGEXP_REPLACE(base_slug, '^-|-$', '', 'g');
        
        -- Check for uniqueness and add suffix if needed
        final_slug := base_slug;
        counter := 1;
        
        WHILE EXISTS (SELECT 1 FROM courses WHERE slug = final_slug AND id != course_rec.id) LOOP
            counter := counter + 1;
            final_slug := base_slug || '-' || counter;
        END LOOP;
        
        -- Update the course
        UPDATE courses SET slug = final_slug WHERE id = course_rec.id;
    END LOOP;
END $$;

-- Now create unique index on slug
CREATE UNIQUE INDEX IF NOT EXISTS idx_courses_slug ON courses(slug) WHERE slug IS NOT NULL;

-- Add content column directly to lessons table for simpler content management
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS content TEXT;

COMMENT ON COLUMN courses.slug IS 'URL-friendly identifier for the course';
COMMENT ON COLUMN lessons.content IS 'Markdown content for the lesson';
