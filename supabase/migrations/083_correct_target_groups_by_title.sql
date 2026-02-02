-- Migration 083: Correct target_groups assignment based on actual course titles
-- Uses course titles from the production database

-- TEAMLEDER (team-leader) - Alle lederkurs
UPDATE courses SET target_groups = ARRAY['team-leader']
WHERE title IN (
    'Lederen Som Trygghetsskaper',
    'Lederen som Trygghetsskaper',
    'Fra Innsikt Til Tiltak',
    'Si Fra Før Det Blir Dyrt',
    'Stolthet Og Kvalitet',
    'Feilreisen',
    'Lederens Konflikthåndtering',
    'Tilbakemeldingskultur',
    'Inkluderende Ledelse',
    'Lederens Egenomsorg',
    'Delegering og Tillit'
);

-- TEAMMEDLEM (team-member) - Generelle arbeidslivskurs
UPDATE courses SET target_groups = ARRAY['team-member']
WHERE title IN (
    'Trygg på Jobb',
    'Kommunikasjon på Jobb',
    'Min Plass i Teamet',
    'Sunne Grenser på Jobb',
    'Håndtere Konflikt',
    'Vekst og Mestring'
);

-- FORELDRE (parent)
UPDATE courses SET target_groups = ARRAY['parent']
WHERE title IN (
    'Praktisk Hverdag',
    'Søsken som Ressurs',
    'Foreldres Sorg',
    'Egen Mestring som Forelder',
    'Å Se Alle Barna',
    'Kommunikasjon i Familien'
);

-- SØSKEN (sibling)
UPDATE courses SET target_groups = ARRAY['sibling']
WHERE title IN (
    'Karriere og Kall',
    'Sorg og Aksept',
    'Finne Min Stamme',
    'Min Stemme, Mine Grenser',
    'Å Forstå Mine Følelser',
    'Hvem Er Jeg?'
);

-- BAS/BYGGELEDER (site_manager)
UPDATE courses SET target_groups = ARRAY['site_manager']
WHERE title IN (
    'Feil Koster - Ditt Ansvar'
);

-- Set remaining null to empty to prevent issues
UPDATE courses SET target_groups = ARRAY[]::TEXT[] WHERE target_groups IS NULL;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Migration 083 completed: Assigned target_groups based on actual course titles';
END $$;
