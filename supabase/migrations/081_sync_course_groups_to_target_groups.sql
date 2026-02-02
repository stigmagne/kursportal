-- Migration 081: Sync course_groups to target_groups
-- Populate target_groups column from course_groups junction table

-- First, update groups table to have slug-based names matching our new target_groups values
-- Add a slug column if not exists
ALTER TABLE public.groups ADD COLUMN IF NOT EXISTS slug TEXT;

-- Update slugs for existing groups
UPDATE public.groups SET slug = 'sibling' WHERE name = 'søsken' OR name ILIKE '%søsken%';
UPDATE public.groups SET slug = 'parent' WHERE name = 'foreldre' OR name ILIKE '%foreldre%';
UPDATE public.groups SET slug = 'team-member' WHERE name = 'helsepersonell' OR name ILIKE '%teammedlem%' OR name ILIKE '%team-member%';
UPDATE public.groups SET slug = 'team-leader' WHERE name ILIKE '%teamleder%' OR name ILIKE '%team-leader%';
UPDATE public.groups SET slug = 'construction_worker' WHERE name ILIKE '%håndverker%' OR name ILIKE '%construction%';
UPDATE public.groups SET slug = 'site_manager' WHERE name ILIKE '%bas%' OR name ILIKE '%byggeleder%' OR name ILIKE '%site_manager%';

-- Insert missing groups
INSERT INTO public.groups (name, slug, description) VALUES 
  ('Søsken', 'sibling', 'For voksne søsken'),
  ('Foreldre', 'parent', 'For foreldre og foresatte'),
  ('Teammedlem', 'team-member', 'For ansatte i team'),
  ('Teamleder', 'team-leader', 'For ledere og mellomledere'),
  ('Håndverker', 'construction_worker', 'For fagarbeidere i bygg'),
  ('Bas/Byggeleder', 'site_manager', 'For byggledelse')
ON CONFLICT (name) DO UPDATE SET slug = EXCLUDED.slug, description = EXCLUDED.description;

-- Now sync course_groups to target_groups
-- For each course, aggregate all group slugs into target_groups array
DO $$
DECLARE
  course_rec RECORD;
  group_slugs TEXT[];
BEGIN
  FOR course_rec IN SELECT id FROM courses LOOP
    -- Get all group slugs for this course
    SELECT ARRAY_AGG(DISTINCT g.slug) INTO group_slugs
    FROM course_groups cg
    JOIN groups g ON cg.group_id = g.id
    WHERE cg.course_id = course_rec.id
    AND g.slug IS NOT NULL;
    
    -- Update the course's target_groups
    IF group_slugs IS NOT NULL AND array_length(group_slugs, 1) > 0 THEN
      UPDATE courses SET target_groups = group_slugs WHERE id = course_rec.id;
    END IF;
  END LOOP;
END $$;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Migration 081 completed: Synced course_groups to target_groups column';
END $$;
