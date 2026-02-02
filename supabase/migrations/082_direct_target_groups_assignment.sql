-- Migration 082: Direct target_groups assignment based on course slugs
-- Maps courses to target groups based on their original assignment patterns

-- Team Member courses (7 courses)
UPDATE courses SET target_groups = ARRAY['team-member']
WHERE slug IN (
    'trygg-pa-jobb',
    'min-plass-i-teamet', 
    'kommunikasjon-pa-jobb',
    'selvledelse-pa-jobb',
    'stressmestring-i-arbeidslivet',
    'samarbeid-og-konflikter',
    'balanse-jobb-og-privatliv'
);

-- Team Leader courses (7 courses)  
UPDATE courses SET target_groups = ARRAY['team-leader']
WHERE slug IN (
    'lederrollen-og-deg',
    'lede-psykologisk-trygghet',
    'vanskelige-samtaler-som-leder',
    'motivasjon-og-engasjement',
    'konflikthåndtering-for-ledere',
    'teamutvikling',
    'forebyggende-helse-som-leder'
);

-- Parent courses (6 courses)
UPDATE courses SET target_groups = ARRAY['parent']
WHERE slug IN (
    'foreldrerolle-og-sykdom',
    'kommunikasjon-i-familien',
    'stotte-barnet-ditt',
    'egenomsorg-for-foreldre',
    'soknadsguide-foreldre',
    'familiehverdag-med-sykdom'
);

-- Sibling courses (6 courses)
UPDATE courses SET target_groups = ARRAY['sibling']
WHERE slug IN (
    'soskenrollen',
    'forstå-situasjonen',
    'kommunikasjon-med-familie',
    'egenomsorg-for-sosken',
    'sosiale-utfordringer',
    'fremtiden-og-bekymringer'
);

-- Construction Worker courses (6 courses)
UPDATE courses SET target_groups = ARRAY['construction_worker']
WHERE slug IN (
    'grunnkurs-psykisk-helse-i-bygg',
    'stressmestring-i-bygg',
    'arbeidsmiljo-og-trivsel',
    'rusforebygging',
    'ergonomi-og-helse',
    'konflikthåndtering-på-byggeplass'
);

-- Site Manager courses (6 courses)
UPDATE courses SET target_groups = ARRAY['site_manager']
WHERE slug IN (
    'ledelse-i-byggebransjen',
    'personalledelse-byggeprosjekt',
    'konflikthåndtering-for-ledere-bygg',
    'hms-ledelse',
    'kommunikasjon-og-samspill',
    'psykososialt-arbeidsmiljo'
);

-- Mental Health courses for construction (3 courses) - both groups
UPDATE courses SET target_groups = ARRAY['construction_worker', 'site_manager']
WHERE slug IN (
    'angst-og-bekymring-i-bygg',
    'depresjon-i-bygg',
    'sovn-og-hvile-i-bygg'
);

-- Legacy/general courses - set to all groups if published and no group yet
UPDATE courses 
SET target_groups = ARRAY['sibling', 'parent', 'team-member', 'team-leader']
WHERE target_groups IS NULL 
  AND published = true
  AND slug NOT LIKE '%-bygg%';

-- Introductory course - available to all
UPDATE courses SET target_groups = ARRAY['sibling', 'parent', 'team-member', 'team-leader', 'construction_worker', 'site_manager']
WHERE slug = 'introductory' OR title ILIKE '%introduksjon%' OR title ILIKE '%introductory%';

-- Update any remaining null target_groups to empty array to avoid issues
UPDATE courses SET target_groups = ARRAY[]::TEXT[] WHERE target_groups IS NULL;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Migration 082 completed: Assigned target_groups to all courses based on their slugs';
END $$;
