-- Migration 084: Correct target_groups based on original course migrations
-- Uses correct assignments from migrations 075 and 076

-- CONSTRUCTION WORKER (håndverker) - From migration 075
UPDATE courses SET target_groups = ARRAY['construction_worker']
WHERE title IN (
    'Si Fra Før Det Blir Dyrt',
    'Feilreisen',
    'Stolthet Og Kvalitet'
);

-- SITE MANAGER (bas/byggeleder) - From migration 076
UPDATE courses SET target_groups = ARRAY['site_manager']
WHERE title IN (
    'Lederen Som Trygghetsskaper',
    'Feil Koster - Ditt Ansvar',
    'Fra Innsikt Til Tiltak'
);

-- TEAMLEDER (team-leader) - General leadership courses (NOT construction)
UPDATE courses SET target_groups = ARRAY['team-leader']
WHERE title IN (
    'Lederens Konflikthåndtering',
    'Tilbakemeldingskultur',
    'Inkluderende Ledelse',
    'Lederen som Trygghetsskaper',  -- Note: lowercase 's' - different course
    'Lederens Egenomsorg',
    'Delegering og Tillit'
);

-- TEAMMEDLEM (team-member) - General workplace courses
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

-- Set any remaining null to empty array
UPDATE courses SET target_groups = ARRAY[]::TEXT[] WHERE target_groups IS NULL;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Migration 084 completed: Corrected target_groups based on original migrations';
END $$;
