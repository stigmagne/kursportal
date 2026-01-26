-- Migration: 043_additional_sibling_courses.sql
-- Purpose: Add 3 more courses for siblings for better recommendation specificity

-- Course 7: Sorg og Aksept
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Sorg og Aksept',
    'Utforsk sorgen over barndommen som ble annerledes. Lær å bearbeide tap og finne aksept uten å måtte "komme over" opplevelsene dine.',
    'sorg-og-aksept',
    TRUE,
    NULL,
    'sibling'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'sorg-og-aksept');

-- Course 7 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'sorg-og-aksept')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Anerkjenne Sorgen', 'Forstå at sorg ikke bare handler om død. Gi plass til sorgen over det som ble annerledes.', 1),
    ('Bearbeide Tap', 'Verktøy for å prosessere tap av normalitet, oppmerksomhet og barndom.', 2),
    ('Finne Aksept', 'Bevege seg mot aksept uten å fornekte opplevelsene eller følelsene.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 7, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'sorg-og-aksept' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hva Er Sorg?', 
     '## Sorg Handler Ikke Bare Om Død

Sorg er kroppens og sinnets naturlige respons på tap - alle typer tap.

### Som søsken kan du sørge over:
- Barndommen som ble annerledes enn forventet
- Oppmerksomheten du ikke fikk
- Søskenrelasjonen du drømte om
- Friheten til å bare være barn
- Fremtiden du hadde sett for deg

### Viktig Innsikt
Å anerkjenne sorgen er ikke det samme som å være utakknemlig. Du kan elske familien din OG sørge over det som ble vanskelig.

> "Sorg er kjærlighet uten et sted å gå."', 
     1, 12),
    ('Usynlig Sorg', 
     '## Når Ingen Ser Din Smerte

Søskens sorg er ofte usynlig fordi:
- Andre fokuserer på den syke
- Du har lært å ikke klage
- Det føles "feil" å sørge når andre har det verre

### Disenfranchised Grief
Dette begrepet beskriver sorg som ikke blir anerkjent av samfunnet. Din sorg kan føles ugyldig fordi ingen døde.

### Øvelse: Navngi Tapene
Skriv ned alt du føler du mistet eller ikke fikk. Bare å sette ord på det er et steg mot bearbeiding.', 
     2, 15),
    ('Sorgens Faser', 
     '## Ikke Lineært, Men Syklisk

Kübler-Ross sine faser (fornektelse, sinne, forhandling, depresjon, aksept) er nyttige, men sorg er ikke lineær.

### Hva Du Kan Oppleve:
- Dager med aksept fulgt av dager med sinne
- Uventede triggere som bringer sorgen tilbake
- Følelse av å "starte på nytt"

### Viktig
Det finnes ingen tidsfrister for sorg. Din prosess er din egen.

> "Healing skjer ikke i en rett linje."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 8: Karriere og Kall
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Karriere og Kall',
    'Finn din egen vei i livet, uavhengig av søskenrollen. Utforsk dine egne drømmer, styrker og hvordan du kan bygge en fremtid som er din.',
    'karriere-og-kall',
    TRUE,
    NULL,
    'sibling'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'karriere-og-kall');

WITH course AS (SELECT id FROM courses WHERE slug = 'karriere-og-kall')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Skille Kall fra Plikt', 'Undersøk om karrierevalg er drevet av genuine interesser eller søskenrollens forventninger.', 1),
    ('Tillate Egne Drømmer', 'Gi deg selv tillatelse til å ha ambisjoner som ikke handler om omsorg eller hjelp.', 2),
    ('Planlegge Fremtiden', 'Praktiske verktøy for å sette mål og bygge en karriere som gir mening for DEG.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'karriere-og-kall' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hjelperens Felle', 
     '## Valgte Du, Eller Ble Du Valgt?

Mange søsken trekkes mot omsorgsyrker. Det kan være genuint - eller en fortsettelse av rollen.

### Refleksjonsspørsmål:
- Ville jeg valgt dette yrket om jeg hadde en helt annen barndom?
- Føler jeg meg skyldig når jeg gjør noe som ikke hjelper andre?
- Er jeg redd for å prioritere meg selv?

### Viktig
Det er ingenting galt med omsorgsyrker! Men valget bør være DITT, ikke rollens.', 
     1, 12),
    ('Finne Din Genuine Interesse', 
     '## Hva Liker DU?

Mange søsken har undertrykt egne interesser så lenge at de ikke vet hva de liker.

### Øvelse: Interesse-arkeologi
1. Tenk tilbake til barndommen: Hva likte du før du tok på deg ansvar?
2. Hva gjør du når du har helt fri og ingen forpliktelser?
3. Hva ville du gjort om penger ikke var et tema?

### NLP-teknikk: Verdier-klargjøring
Ranger disse: Frihet, Sikkerhet, Kreativitet, Hjelpe andre, Anerkjennelse, Læring, Ledelse', 
     2, 15),
    ('Tillatelse til Ambisjoner', 
     '## Du Har Lov Til Å Ville Lykkes

Noen søsken føler skyld over å ha ambisjoner eller drømmer når søskenet kanskje ikke kan.

### Sannheten:
- Din suksess skader ikke søskenet ditt
- Du fortjener å bruke dine evner fullt ut
- Dine prestasjoner kan inspirere hele familien

> "Å holde deg selv tilbake hjelper ingen."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 9: Finne Min Stamme
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Finne Min Stamme',
    'Bygg et støttenettverk utenfor familien. Lær å finne, skape og vedlikeholde relasjoner som gir deg støtte og fellesskap.',
    'finne-min-stamme',
    TRUE,
    NULL,
    'sibling'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'finne-min-stamme');

WITH course AS (SELECT id FROM courses WHERE slug = 'finne-min-stamme')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Hvorfor Støtte Utenfor', 'Forstå verdien av relasjoner utenfor familiesystemet.', 1),
    ('Finne Likesinnede', 'Hvor og hvordan finne mennesker som forstår eller støtter deg.', 2),
    ('Vedlikeholde Relasjoner', 'Lær å investere i vennskap og nettverk over tid.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'finne-min-stamme' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Isolasjonsfellen', 
     '## Når Familien Blir Alt

Mange søsken har:
- Lært at behov utenfor familien ikke teller
- Følt seg annerledes enn jevnaldrende
- Prioritert familiens behov over sosiale aktiviteter

### Konsekvenser:
- Få nære vennskap
- Vansker med å be om hjelp
- Ensomhet selv i en travel hverdag', 
     1, 10),
    ('Søskenfellesskap', 
     '## Du Er Ikke Alene

Det finnes mange som deler din erfaring:
- Søskengrupper (online og offline)
- Organisasjoner for pårørende
- Støttegrupper ved sykehus

### Verdien av Å Bli Forstått
Å møte andre som "bare skjønner" kan være transformerende.

### Ressurser:
- Facebook-grupper for søsken
- Pårørendesentre
- Terapeutiske grupper', 
     2, 12),
    ('Ulike Typer Støtte', 
     '## Ikke Alle Trenger Å Forstå Alt

Du trenger ulike mennesker for ulike behov:
- **Emosjonell støtte**: Noen som lytter
- **Praktisk støtte**: Noen som hjelper med hverdagen
- **Inspirerende støtte**: Noen som utfordrer deg
- **Sosial støtte**: Noen å ha det gøy med

### Øvelse
Hvem i livet ditt gir hvilken type støtte? Hvor er hullene?', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Link courses to sibling category
WITH sibling_cat AS (SELECT id FROM categories WHERE name = 'Søsken')
UPDATE courses SET category_id = sibling_cat.id
FROM sibling_cat
WHERE courses.slug IN ('sorg-og-aksept', 'karriere-og-kall', 'finne-min-stamme')
AND courses.category_id IS NULL;

-- Update assessment dimension recommendations
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug IN ('a-forsta-mine-folelser', 'sorg-og-aksept')
)
WHERE slug = 'emotional-regulation' 
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'sibling-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug IN ('hvem-er-jeg', 'karriere-og-kall')
)
WHERE slug = 'future-orientation'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'sibling-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug IN ('hvem-er-jeg', 'finne-min-stamme')
)
WHERE slug = 'social-support'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'sibling-assessment');
