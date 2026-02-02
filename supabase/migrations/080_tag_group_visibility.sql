-- Migration: 080_tag_group_visibility.sql
-- Purpose: Add group-based visibility to tags
-- Some tags are universal (visible to all), others are group-specific

-- 1. Add target_groups column to tags
-- NULL or empty array means visible to everyone
-- Specific groups = visible only to users in those groups
ALTER TABLE tags ADD COLUMN IF NOT EXISTS target_groups TEXT[] DEFAULT '{}';

-- 2. Add description column for better admin UX
ALTER TABLE tags ADD COLUMN IF NOT EXISTS description TEXT;

-- 3. Drop existing SELECT policy
DROP POLICY IF EXISTS "Tags are viewable by everyone" ON tags;

-- 4. Create new policy that respects target_groups
CREATE POLICY "Tags visible based on user group or public" ON tags
    FOR SELECT USING (
        -- Universal tags (null or empty target_groups)
        target_groups = '{}' OR target_groups IS NULL
        -- Or user belongs to one of the tag's target groups
        OR EXISTS (
            SELECT 1 FROM user_groups ug
            WHERE ug.user_id = auth.uid()
            AND ug.target_group = ANY(tags.target_groups)
        )
        -- Or admin can see all
        OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- 5. Seed some useful tags with group visibility
INSERT INTO tags (name, slug, target_groups, description) VALUES
-- Universal tags (visible to all)
('Psykologisk trygghet', 'psykologisk-trygghet', '{}', 'Kurs om psykologisk trygghet på arbeidsplassen eller i familien'),
('Kommunikasjon', 'kommunikasjon', '{}', 'Kurs om effektiv kommunikasjon'),
('Mestring', 'mestring', '{}', 'Kurs om mestringsstrategier'),
('Selvutvikling', 'selvutvikling', '{}', 'Kurs for personlig vekst og utvikling'),

-- Construction/workplace specific tags
('Kvalitetssikring', 'kvalitetssikring', ARRAY['construction_worker', 'site_manager'], 'Kurs om kvalitetskontroll i byggebransjen'),
('Feilforebygging', 'feilforebygging', ARRAY['construction_worker', 'site_manager'], 'Kurs om å forebygge feil og reklamasjoner'),
('Teamledelse', 'teamledelse', ARRAY['team-leader', 'site_manager'], 'Kurs for ledere og mellomledere'),

-- Family/sibling specific tags  
('Familiedynamikk', 'familiedynamikk', ARRAY['sibling', 'parent'], 'Kurs om familieforhold og dynamikk'),
('Søskenrelasjoner', 'soskenrelasjoner', ARRAY['sibling', 'parent'], 'Kurs spesifikt for søsken-tematikk'),
('Foreldrerolle', 'foreldrerolle', ARRAY['parent'], 'Kurs om å være foreldre med spesielle utfordringer')
ON CONFLICT (name) DO UPDATE SET
    target_groups = EXCLUDED.target_groups,
    description = EXCLUDED.description;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Migration 080 completed: Added target_groups visibility to tags table';
END $$;
