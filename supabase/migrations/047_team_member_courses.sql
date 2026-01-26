-- Migration: 047_team_member_courses.sql
-- Purpose: 6 courses for team members on workplace psychological safety

-- Create category for workplace courses
INSERT INTO categories (name, description, color)
VALUES ('Arbeidsmiljø', 'Kurs om psykologisk trygghet og psykososialt arbeidsmiljø', '#0EA5E9')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- COURSE 1: Trygg på Jobb
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Trygg på Jobb',
    'Forstå hva psykologisk trygghet betyr og hvordan du kan bidra til og oppleve mer trygghet på arbeidsplassen.',
    'trygg-pa-jobb',
    TRUE, NULL, 'team-member'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'trygg-pa-jobb');

WITH course AS (SELECT id FROM courses WHERE slug = 'trygg-pa-jobb')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Hva er Psykologisk Trygghet?', 'Forstå begrepet og hvorfor det er viktig for deg og teamet.', 1),
    ('Tørre å Si Fra', 'Lær å dele meninger, stille spørsmål og utfordre ideer.', 2),
    ('Håndtere Usikkerhet og Feil', 'Hvordan forholde deg til feil og usikkerhet på en konstruktiv måte.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'trygg-pa-jobb' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Amy Edmondsons Forskning', 
     '## Psykologisk Trygghet - Fundamentet

Psykologisk trygghet ble definert av Harvard-professor Amy Edmondson som:

> "En delt tro i teamet om at det er trygt å ta mellommenneskelig risiko."

### Hva betyr det i praksis?
- Du kan stille spørsmål uten å føle deg dum
- Du kan innrømme feil uten frykt for straff
- Du kan være uenig uten å frykte konsekvenser
- Du kan be om hjelp uten å miste status

### Hvorfor er det viktig?
Googles Project Aristotle fant at psykologisk trygghet var den viktigste faktoren for høytytende team.', 
     1, 12),
    ('Tegn på Trygghet og Utrygghet', 
     '## Kjenn Igjen Signalene

### Tegn på et TRYGT miljø:
- Folk stiller spørsmål i møter
- Feil diskuteres åpent
- Alle stemmer høres
- Det er rom for humor og sårbarhet

### Tegn på et UTRYGT miljø:
- Stillhet i møter
- Skylding og fingerpeking ved feil
- Noen dominerer alltid
- Folk sier én ting i møte, annet i gangen

### Refleksjon
Hvor trygt er ditt arbeidsmiljø på en skala fra 1-10? Hva er det viktigste tegnet?', 
     2, 10),
    ('Din Rolle i Tryggheten', 
     '## Du Påvirker Kulturen

Psykologisk trygghet er ikke bare lederens ansvar - alle bidrar.

### Det du KAN gjøre:
- Still spørsmål (det gir andre tillatelse til det samme)
- Anerkjenn kollegaers bidrag
- Reager positivt når andre deler
- Del dine egne feil og lærdommer

### Det du bør UNNGÅ:
- Himle med øynene eller sukke
- Avbryte eller overse
- Kritisere uten å komme med løsning
- Snakke negativt om folk bak ryggen deres

> "Hver interaksjon er en mulighet til å øke eller redusere tryggheten."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 2: Min Plass i Teamet
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Min Plass i Teamet',
    'Finn din plass og verdi i teamet. Lær forskjellen på tilhørighet og tilpasning, og hvordan du kan bidra autentisk.',
    'min-plass-i-teamet',
    TRUE, NULL, 'team-member'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'min-plass-i-teamet');

WITH course AS (SELECT id FROM courses WHERE slug = 'min-plass-i-teamet')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Tilhørighet vs. Tilpasning', 'Forstå forskjellen og hvorfor det betyr noe.', 1),
    ('Ditt Unike Bidrag', 'Finn og verdsett det du bringer til teamet.', 2),
    ('Håndtere Utenforskap', 'Strategier når du føler deg på utsiden.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'min-plass-i-teamet' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Tilhørighet og Tilpasning', 
     '## To Veier Inn i Gruppa

### Tilpasning:
- Endre deg for å passe inn
- Skjule deler av deg selv
- Si det andre vil høre
- Føle deg aldri helt "ekte"

### Tilhørighet:
- Bli akseptert som du er
- Dele både styrker og svakheter
- Være uenig når du mener det
- Føle deg hjemme

> "Tilhørighet betyr å være der du er velkommen som den du er." - Brené Brown', 
     1, 10),
    ('Hvorfor Tilpasning Føles Tryggere', 
     '## Beskyttelsesmekanismen

Tilpasning kan føles tryggere på kort sikt:
- Unngår avvisning
- Slipper konflikt
- Føler seg "inne"

### Prisen vi betaler:
- Utmatting fra å "spille en rolle"
- Aldri føle seg virkelig sett
- Miste kontakt med egne verdier
- Bygger relasjoner på falskt grunnlag

### Refleksjon
På hvilke måter tilpasser du deg på jobb? Hva holder du tilbake?', 
     2, 12),
    ('Mot å Tilhøre', 
     '## Veien til Ekte Tilhørighet

### Steg for Steg:
1. **Selvbevissthet**: Kjenn dine verdier og grenser
2. **Små eksperimenter**: Del litt mer av deg selv
3. **Finn allierte**: De som setter pris på ekte deg
4. **Aksepter at ikke alle vil like deg**: Og det er OK

> "Å høre til krever at vi viser hvem vi virkelig er."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 3: Kommunikasjon på Jobb
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Kommunikasjon på Jobb',
    'Bli en bedre kommunikator på jobben. Lær å lytte aktivt, gi tydelige beskjeder og ta vanskelige samtaler.',
    'kommunikasjon-pa-jobb',
    TRUE, NULL, 'team-member'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'kommunikasjon-pa-jobb');

WITH course AS (SELECT id FROM courses WHERE slug = 'kommunikasjon-pa-jobb')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Aktiv Lytting på Jobb', 'Teknikker for å virkelig høre hva kollegaer sier.', 1),
    ('Tydelig Kommunikasjon', 'Gi og motta beskjeder effektivt.', 2),
    ('Vanskelige Samtaler', 'Ta opp det som er ubehagelig.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'kommunikasjon-pa-jobb' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hva Er Aktiv Lytting?', 
     '## Mer Enn Å Høre

Aktiv lytting handler om å:
- Gi full oppmerksomhet
- Forstå, ikke bare vente på din tur
- Vise at du lytter
- Respondere relevant

### Barrierer:
- Multitasking (sjekke telefon)
- Forberede svar mens den andre snakker
- Avbryte
- Gjøre antakelser', 
     1, 10),
    ('Lytteteknikker', 
     '## Praktiske Verktøy

### 1. Speiling
Gjenta essensen med egne ord:
"Så det du sier er at..."

### 2. Åpne spørsmål
"Kan du fortelle mer om...?"
"Hva tenker du om...?"

### 3. Pause
Tål stillhet. La den andre tenke.

### 4. Non-verbal
- Øyekontakt
- Nikk
- Åpent kroppsspråk', 
     2, 12),
    ('Øvelse: Lyttesamtale', 
     '## Prøv Det Ut

### Oppgave:
Finn en kollega og ha en 5-minutters samtale der:
1. Du kun lytter (ingen råd, ingen historier om deg selv)
2. Du stiller åpne spørsmål
3. Du oppsummerer til slutt

### Debrief:
- Hvordan føltes det?
- Hva lærte du?
- Hva var vanskelig?', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 4: Sunne Grenser på Jobb
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Sunne Grenser på Jobb',
    'Lær å sette og holde grenser for tid, energi og arbeidsoppgaver uten dårlig samvittighet.',
    'sunne-grenser-pa-jobb',
    TRUE, NULL, 'team-member'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'sunne-grenser-pa-jobb');

WITH course AS (SELECT id FROM courses WHERE slug = 'sunne-grenser-pa-jobb')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Gjenkjenne Overbelastning', 'Tidlige tegn på at du tar på deg for mye.', 1),
    ('Si Nei Uten Skyldfølelse', 'Praktiske teknikker for grensesetting.', 2),
    ('Work-Life Balance', 'Skille jobb og fritid i en always-on verden.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'sunne-grenser-pa-jobb' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Tegn på Overbelastning', 
     '## Lytter Kroppen, Ignorer Ikke

### Fysiske tegn:
- Konstant tretthet
- Hodepine, muskelspenninger
- Søvnproblemer
- Hyppigere sykdom

### Mentale tegn:
- Irritabilitet
- Konsentrasjonsvansker
- Kynisme eller apati
- Følelse av utilstrekkelighet', 
     1, 10),
    ('Når Nei Er Kjærlighet', 
     '## Hvorfor Si Nei?

Et nei til én ting er et ja til noe annet:
- Ja til kvalitet over kvantitet
- Ja til din helse
- Ja til det som faktisk er viktig

### Formuler Mykt Nei:
- "Jeg kan gjøre dette, men da må X vente. Hva prioriterer vi?"
- "Jeg har ikke kapasitet denne uken. Kan vi se på neste uke?"
- "Det ligger utenfor mitt område, men kanskje Y kan hjelpe?"', 
     2, 12),
    ('Sett Dine Grenser', 
     '## Øvelse: Definér Grensene

Skriv ned dine grenser:

### Tidsgrenser:
- Når slutter arbeidsdagen?
- Sjekker du epost etter jobb?

### Energigrenser:
- Hvor mange møter tåler du per dag?
- Når trenger du pause?

### Oppgavegrenser:
- Hva er ikke din jobb?
- Når sier du nei?

> "Grenser er ikke murer. De er gjerder med dør."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 5: Håndtere Konflikt
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Håndtere Konflikt',
    'Lær konstruktive måter å håndtere uenigheter og konflikter med kollegaer på.',
    'handtere-konflikt',
    TRUE, NULL, 'team-member'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'handtere-konflikt');

WITH course AS (SELECT id FROM courses WHERE slug = 'handtere-konflikt')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Konfliktstiler', 'Forstå din egen og andres stil i konflikt.', 1),
    ('Ta Opp Vanskelige Ting', 'Strategier for den første samtalen.', 2),
    ('Gjenoppbygging', 'Reparere relasjonen etter konflikt.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'handtere-konflikt' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Thomas-Kilmann Modellen', 
     '## Fem Konfliktsstiler

### 1. Konkurrerende
Høy fokus på egne behov, lav på andres. "Jeg vinner."

### 2. Tilpassende
Lav fokus på egne, høy på andres. "Du vinner."

### 3. Unngående
Lav på begge. "La oss ikke snakke om det."

### 4. Kompromiss
Middels på begge. "Vi gir begge litt."

### 5. Samarbeidende
Høy på begge. "Vi finner en løsning sammen."

### Refleksjon
Hvilken stil bruker du oftest? Når fungerer den ikke?', 
     1, 12),
    ('Riktig Stil til Rett Tid', 
     '## Kontekst Avgjør

### Konkurrerende:
✓ Kriser, rask beslutning trengs
✗ Langvarige relasjoner

### Unngående:
✓ Små saker, behov for pause
✗ Viktige problemer

### Samarbeidende:
✓ Komplekse saker, viktig relasjon
✗ Tidspress, lav viktighet', 
     2, 10),
    ('Forberedelse til Samtalen', 
     '## Før Du Tar Det Opp

### Sjekkliste:
- [ ] Hva er fakta vs. tolkninger?
- [ ] Hva er mitt behov?
- [ ] Hva kan være den andres perspektiv?
- [ ] Hva er mitt beste utfall?
- [ ] Hva kan jeg akseptere?

### Formler:
"Jeg opplever... Kan vi snakke om det?"
"Jeg trenger å forstå... Kan du hjelpe meg?"', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 6: Vekst og Mestring
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Vekst og Mestring',
    'Utvikle et growth mindset og håndter utfordringer på jobben som læringsmuligheter.',
    'vekst-og-mestring',
    TRUE, NULL, 'team-member'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'vekst-og-mestring');

WITH course AS (SELECT id FROM courses WHERE slug = 'vekst-og-mestring')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Growth Mindset', 'Forstå forskjellen på fixed og growth mindset.', 1),
    ('Lære av Feil', 'Bruk feil som springbrett for utvikling.', 2),
    ('Din Karriereutvikling', 'Ta eierskap til din egen vekst.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'vekst-og-mestring' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Fixed vs Growth', 
     '## To Måter å Se Evner På

### Fixed Mindset:
- "Jeg er enten flink eller ikke"
- Feil er bevis på begrensning
- Utfordringer er truende
- Innsats er poengløst hvis du ikke har talent

### Growth Mindset:
- "Evner kan utvikles"
- Feil er læring
- Utfordringer er muligheter
- Innsats er veien til mestring

> "Det er ikke om du er smart. Det er hvordan du blir smartere."', 
     1, 12),
    ('Gjenkjenn Din Tankegang', 
     '## Når Er Du i Fixed Mode?

### Triggere:
- Når du sammenligner deg med andre
- Når du får kritikk
- Når du står overfor noe nytt
- Når andre lykkes

### Signaler:
- "Jeg kan ikke..."
- "Slik har jeg alltid vært"
- "De andre er bare flinkere"
- Unngår utfordringer', 
     2, 10),
    ('Shift til Growth', 
     '## Endre Språket

### Fra Fixed til Growth:
- "Jeg kan ikke dette" → "Jeg kan ikke dette ENNÅ"
- "Dette er for vanskelig" → "Dette krever mer innsats"
- "Jeg gjør alltid feil" → "Feil er hvordan jeg lærer"
- "De er så mye flinkere" → "Hva kan jeg lære av dem?"

### Daglig Praksis:
Hver kveld, spør deg selv:
- Hva lærte jeg i dag?
- Hvilke feil gjorde meg bedre?
- Hva vil jeg prøve i morgen?', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Link courses to workplace category
WITH work_cat AS (SELECT id FROM categories WHERE name = 'Arbeidsmiljø')
UPDATE courses SET category_id = work_cat.id
FROM work_cat
WHERE courses.slug IN (
    'trygg-pa-jobb', 'min-plass-i-teamet', 'kommunikasjon-pa-jobb',
    'sunne-grenser-pa-jobb', 'handtere-konflikt', 'vekst-og-mestring'
)
AND courses.category_id IS NULL;

-- Update assessment dimension recommendations
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'trygg-pa-jobb')
WHERE slug = 'psychological-safety'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'team-member-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'min-plass-i-teamet')
WHERE slug = 'belonging'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'team-member-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'kommunikasjon-pa-jobb')
WHERE slug = 'work-communication'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'team-member-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'sunne-grenser-pa-jobb')
WHERE slug = 'work-boundaries'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'team-member-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'handtere-konflikt')
WHERE slug = 'conflict-handling'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'team-member-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'vekst-og-mestring')
WHERE slug = 'growth-mastery'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'team-member-assessment');
