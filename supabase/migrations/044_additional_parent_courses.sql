-- Migration: 044_additional_parent_courses.sql
-- Purpose: Add 3 more courses for parents for better recommendation specificity

-- Course 10: Praktisk Hverdag
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Praktisk Hverdag',
    'Konkrete verktøy for å organisere en travel hverdag med flere barns ulike behov. Få praktiske strategier for tidsplanlegging, delegering og prioritering.',
    'praktisk-hverdag',
    TRUE,
    NULL,
    'parent'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'praktisk-hverdag');

WITH course AS (SELECT id FROM courses WHERE slug = 'praktisk-hverdag')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Tidsplanlegging', 'Strukturer for å balansere sykehusbesøk, aktiviteter og hverdagsrutiner.', 1),
    ('Delegering og Hjelp', 'Lær å akseptere og be om hjelp fra nettverket rundt deg.', 2),
    ('Prioritering i Kaos', 'Når alt haster - hvordan velge hva som faktisk er viktigst.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'praktisk-hverdag' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Familiekalender', 
     '## Én Oversikt For Alle

En delt kalender kan være livredder i en travel familie.

### Tips:
- Bruk farger per familiemedlem
- Inkluder alle typer avtaler
- Planlegg inn "buffer-tid"
- Ha ukentlig gjennomgang

### Digitale Verktøy:
- Google Kalender (delt)
- Cozi Family Organizer
- Papirkalender på kjøkkenet

### Viktig
Inkluder også det FRISKE barnets aktiviteter og avtaler like fremtredende.', 
     1, 10),
    ('Rutiner Som Redder', 
     '## Autopilot For Hverdagen

Når mye er uforutsigbart, gir rutiner trygghet.

### Morgenrutine:
- Forbered kvelden før
- Samme rekkefølge hver dag
- Visuelle påminnelser for barn

### Kveldsrutine:
- Fast leggetid (så godt det lar seg gjøre)
- Individuell "god natt"-tid med hvert barn
- Forbered neste dag

### Fleksibilitet
Rutiner må kunne tilpasses når det smeller. Det viktige er å ha noe å komme tilbake til.', 
     2, 12),
    ('Ukeplanlegging', 
     '## 15 Minutter Som Endrer Uken

Sett av tid hver søndag til å planlegge uken.

### Sjekkliste:
- [ ] Sykehusavtaler og behandlinger
- [ ] Barnas aktiviteter
- [ ] Hvem gjør hva (fordeling)
- [ ] Måltidsplanlegging
- [ ] "En-til-en"-tid med hvert barn
- [ ] Egen pausetid (!)

### Involver Familien
La barna (som er gamle nok) være med på planleggingen.', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 11: Foreldres Sorg
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Foreldres Sorg',
    'Bearbeid sorgen over diagnosen og drømmen som ble annerledes. Lær å håndtere kronisk sorg og finne rom for glede midt i det vanskelige.',
    'foreldres-sorg',
    TRUE,
    NULL,
    'parent'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'foreldres-sorg');

WITH course AS (SELECT id FROM courses WHERE slug = 'foreldres-sorg')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Anerkjenne Tapet', 'Gi rom for sorgen over forventningene og drømmene som ikke ble.', 1),
    ('Kronisk Sorg', 'Forstå sorg som kommer i bølger og aldri helt forsvinner.', 2),
    ('Finne Glede', 'Tillate deg selv øyeblikk av glede uten skyldfølelse.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'foreldres-sorg' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Drømmen Som Ble Annerledes', 
     '## Du Hadde En Drøm

Alle foreldre har drømmer for barna sine. Når et barn får en diagnose, sørger man over:
- Drømmen om det "perfekte" barnet
- Fremtiden du så for deg
- Familielivet du hadde forestilt deg
- Friheten du tok for gitt

### Viktig Å Forstå
Å sørge over drømmen betyr IKKE at du ikke elsker barnet ditt som det er.

> "Du kan elske barnet ditt fullstendig og samtidig sørge over det som ble annerledes."', 
     1, 12),
    ('Diagnose-sjokket', 
     '## Når Alt Endret Seg

Øyeblikket du fikk diagnosen kan sitte i kroppen lenge.

### Vanlige Reaksjoner:
- Sjokk og nummenhet
- Fornektelse ("Dette kan ikke stemme")
- Intens søking etter informasjon
- Sinne ("Hvorfor oss?")
- Sorg og gråt

### Prosessering
Disse reaksjonene er normale. De kan komme og gå i lang tid etter diagnosen.

### Øvelse
Skriv ned ditt "diagnose-øyeblikk". Hva husker du? Hvordan føles det nå?', 
     2, 15),
    ('Sorg vs Depresjon', 
     '## Når Trengs Profesjonell Hjelp?

Sorg er normalt. Men noen ganger går det over i depresjon.

### Tegn på at du bør søke hjelp:
- Konstant håpløshet (ikke bare i perioder)
- Vansker med å fungere i hverdagen
- Tanker om at det hadde vært bedre om du ikke var her
- Ikke i stand til å føle glede i det hele tatt

### Ressurser:
- Fastlege
- Pårørendesenteret
- Psykolog
- Krisehjelp

> "Å be om hjelp er styrke, ikke svakhet."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 12: Søsken som Ressurs
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Søsken som Ressurs',
    'Styrk relasjonen mellom barna og hjelp det friske barnet å finne en positiv rolle i familien uten å bli liten omsorgsgiver.',
    'sosken-som-ressurs',
    TRUE,
    NULL,
    'parent'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'sosken-som-ressurs');

WITH course AS (SELECT id FROM courses WHERE slug = 'sosken-som-ressurs')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Sunn Involvering', 'Hvordan inkludere søsken på en måte som styrker, ikke belaster.', 1),
    ('Søskenrelasjonen', 'Bygg opp et positivt og resilient søskenbånd.', 2),
    ('Forebygge Belastning', 'Tegn på at søsken tar for mye ansvar, og hva du kan gjøre.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'sosken-som-ressurs' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Bidrag vs Byrde', 
     '## Den fine balansen

Det er naturlig at søsken bidrar i familien. Men det må være balansert.

### Sunne Bidrag:
- Aldersriktige oppgaver
- Klare forventninger
- Anerkjennelse for innsats
- Frihet til å si nei

### Byrde:
- For mye ansvar
- Emosjonell støtte til foreldre
- Omsorg som fortrenger barndommen
- Skyld for å ikke gjøre nok

### Refleksjon
Hvor på skalaen er ditt søsken?', 
     1, 12),
    ('Det Positive Perspektivet', 
     '## Styrker Som Vokser Frem

Mange søsken utvikler bemerkelseverdige styrker:
- Empati og omsorg
- Modenhet
- Problemløsningsevner
- Takknemlighet

### Din Rolle
Hjelp barnet å se disse styrkene som verdifulle, uten å glorifisere det vanskelige.

### Samtale-start:
"Jeg ser at du har blitt veldig god til å... Hvordan har du det med det?"', 
     2, 12),
    ('Feire Søskenet', 
     '## Anerkjenn Deres Bidrag

Det friske barnet gjør ofte mye som tas for gitt.

### Måter å Anerkjenne:
- Si takk spesifikt ("Takk for at du var tålmodig i dag")
- Fortell andre om deres styrker (så barnet hører)
- Feir deres milepæler like høylytt
- Gi positiv oppmerksomhet når de IKKE hjelper

> "Du er verdifull for den du er, ikke for det du gjør."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Link courses to parent category
WITH parent_cat AS (SELECT id FROM categories WHERE name = 'Foreldre')
UPDATE courses SET category_id = parent_cat.id
FROM parent_cat
WHERE courses.slug IN ('praktisk-hverdag', 'foreldres-sorg', 'sosken-som-ressurs')
AND courses.category_id IS NULL;

-- Update assessment dimension recommendations
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug IN ('a-se-alle-barna', 'praktisk-hverdag')
)
WHERE slug = 'attention-balance'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'parent-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug IN ('a-se-alle-barna', 'sosken-som-ressurs')
)
WHERE slug = 'sibling-awareness'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'parent-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug IN ('egen-mestring-som-forelder', 'foreldres-sorg')
)
WHERE slug IN ('guilt-processing', 'parental-wellbeing')
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'parent-assessment');
