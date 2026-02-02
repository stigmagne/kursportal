-- Migration: 048_team_leader_courses.sql
-- Purpose: 6 courses for team leaders on psychological safety and leadership

-- =====================================================
-- COURSE 7: Lederen som Trygghetsskaper
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Lederen som Trygghetsskaper',
    'Lær å skape et miljø der folk tør å feile, lære og si ifra. Psykologisk trygghet er lederens viktigste verktøy.',
    'lederen-som-trygghetsskaper',
    TRUE, NULL, 'team-leader'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'lederen-som-trygghetsskaper');

WITH course AS (SELECT id FROM courses WHERE slug = 'lederen-som-trygghetsskaper')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Lederens Ansvar', 'Forstå din rolle i å bygge trygghet.', 1),
    ('Romme Feil og Usikkerhet', 'Skap en kultur der feil er læring.', 2),
    ('Modellere Sårbarhet', 'Led med eksempel.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'lederen-som-trygghetsskaper' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Lederens Skygge', 
     '## Du Setter Tonen

Som leder kaster du en lang skygge. Alt du gjør og sier (og ikke gjør og sier) påvirker teamet.

### Din innflytelse:
- Hvordan du reagerer på feil setter standarden
- Hvem du inkluderer viser hvem som teller
- Hvordan du håndterer stress smitter
- Din sårbarhet gir tillatelse til andres

> "Folk ser ikke hva du sier, de ser hva du gjør."

### Refleksjon
Hva slags skygge kaster du? Hva ser teamet ditt?', 
     1, 12),
    ('Trygghet vs. Komfort', 
     '## Ikke Unngå Ubehag

Psykologisk trygghet handler IKKE om:
- Å unngå vanskelige samtaler
- Å aldri utfordre
- Å være snill hele tiden
- Fravær av konflikt

Det handler OM:
- Trygghet til å ta opp vanskelige ting
- Ærlige tilbakemeldinger
- Konstruktiv uenighet
- Læring fra feil

> "Høy trygghet + høye forventninger = høy ytelse"', 
     2, 12),
    ('De Fire Pilarene', 
     '## Edmondsons Rammeverk

### 1. Sett scenen
- Forklar hvorfor input er viktig
- Del usikkerheten i situasjonen

### 2. Inviter til deltakelse
- Still åpne spørsmål
- Oppsøk aktivt ulike perspektiver

### 3. Responder produktivt
- Takk for innspill (også kritiske)
- Vis at du tar det på alvor

### 4. Normaliser kontinuerlig læring
- Del egne feil og lærdommer
- Feir læring, ikke bare suksess', 
     3, 15)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 8: Inkluderende Ledelse
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Inkluderende Ledelse',
    'Led med mangfold og inkludering i fokus. Sørg for at alle stemmer høres og alle føler tilhørighet.',
    'inkluderende-ledelse',
    TRUE, NULL, 'team-leader'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'inkluderende-ledelse');

WITH course AS (SELECT id FROM courses WHERE slug = 'inkluderende-ledelse')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Ubevisste Fordommer', 'Kjenn igjen og håndter bias.', 1),
    ('Inkludere Alle Stemmer', 'Praktiske teknikker for inkludering.', 2),
    ('Håndtere Ekskludering', 'Grip inn når noen holdes utenfor.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'inkluderende-ledelse' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hva Er Bias?', 
     '## Vi Har Alle Bias

Ubevisste fordommer er snarveier hjernen tar basert på erfaring.

### Vanlige typer:
- **Likhets-bias**: Foretrekker folk som ligner oss
- **Bekreftelses-bias**: Søker info som bekrefter det vi tror
- **Halo-effekt**: Én positiv ting farger alt
- **Horn-effekt**: Én negativ ting farger alt

### Det viktige:
Bias gjør deg ikke til et dårlig menneske. Å ikke adressere det, gjør organisasjonen dårligere.', 
     1, 12),
    ('Sjekk Deg Selv', 
     '## Praktisk Selvrefleksjon

### Spørsmål å stille seg selv:
- Hvem gir jeg mest oppmerksomhet i møter?
- Hvem får de interessante oppgavene?
- Hvem ser jeg opp til og hvorfor?
- Hvem overser jeg uten å merke det?

### Tiltak:
- Ha en "inclusions-buddy" som gir deg feedback
- Roter hvem som får ordet først i møter
- Vær bevisst på hvem som får prestisjeoppgaver', 
     2, 12),
    ('Mikrohandlinger', 
     '## Små Ting Betyr Mye

### Inkluderende mikro-handlinger:
- Hils på alle, ikke bare de nærmeste
- Bruk folks navn (og uttale riktig)
- Inviter til møter - ikke anta folk ikke vil
- Gi kreditt - offentlig
- Følg opp etter at noen har delt noe sårbart

### Ekskluderende mikro-handlinger:
- Avbryte
- Ikke se på når noen snakker
- Gjenta andres ideer som dine
- Ha interne spøker folk ikke forstår', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 9: Tilbakemeldingskultur
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Tilbakemeldingskultur',
    'Bygg en kultur av ærlig og støttende feedback. Lær å gi og motta tilbakemeldinger som fremmer vekst.',
    'tilbakemeldingskultur',
    TRUE, NULL, 'team-leader'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'tilbakemeldingskultur');

WITH course AS (SELECT id FROM courses WHERE slug = 'tilbakemeldingskultur')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Gi Feedback Som Virker', 'Teknikker for konstruktiv tilbakemelding.', 1),
    ('Motta Feedback Som Leder', 'Åpne for tilbakemeldinger på din ledelse.', 2),
    ('1:1 Samtaler', 'Strukturer for regelmessige utviklingssamtaler.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'tilbakemeldingskultur' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('SBI-Modellen', 
     '## Situation - Behavior - Impact

### Struktur:
1. **Situasjon**: "I møtet i går..."
2. **Atferd**: "...da du avbrøt Anders midtsetning..."
3. **Effekt**: "...opplevde jeg at han lukket seg."

### Hvorfor det virker:
- Konkret, ikke generelt
- Fokuserer på atferd, ikke person
- Beskriver virkning, ikke intensjon

### Eksempel:
✗ "Du er alltid så dominant i møter"
✓ "I standup i dag, da du svarte for Kari tre ganger, la jeg merke til at hun sluttet å bidra."', 
     1, 12),
    ('Positiv Feedback Først', 
     '## Bygg Relasjonen

### Forskning viser:
5:1 ratio - Fem positive for hver korrigerende

### Hvorfor?
- Bygger tillit
- Gjør korrigerende lettere å ta imot
- Folk vet at du ser dem

### Praktisk:
- Start uken med å notere én ting per teammedlem å rose
- Gi positiv feedback offentlig (hvis passende)
- Vær spesifikk - "Bra jobba" er ikke feedback', 
     2, 10),
    ('Den Vanskelige Samtalen', 
     '## Når Du Må Korrigere

### Forberedelse:
- Samle fakta
- Tenk gjennom timing
- Velg privat setting
- Ha mål for samtalen

### Gjennomføring:
1. Start med intensjon: "Jeg vil at du skal lykkes, og det er derfor jeg..."
2. Bruk SBI
3. Lytt til perspektivet
4. Avtal vei videre
5. Følg opp

> "Feedback er en gave. Pakker du den dårlig, vil ingen åpne den."', 
     3, 15)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 10: Delegering og Tillit
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Delegering og Tillit',
    'Mester kunsten å delegere med tillit. Gi teamet ansvar og rom til å vokse uten å miste oversikt.',
    'delegering-og-tillit',
    TRUE, NULL, 'team-leader'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'delegering-og-tillit');

WITH course AS (SELECT id FROM courses WHERE slug = 'delegering-og-tillit')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Delegere Riktig', 'Hva, til hvem, og hvordan.', 1),
    ('Oppfølging Uten Mikro', 'Balanse mellom oversikt og kontroll.', 2),
    ('Bygge Autonome Team', 'Fra avhengighet til selvstendighet.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'delegering-og-tillit' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hvorfor Vi Ikke Delegerer', 
     '## Vanlige Blokkere

### "Det er raskere å gjøre det selv"
- Sant på kort sikt
- Usant på lang sikt
- Du blir flaskehalsen

### "Ingen kan gjøre det like bra"
- Kanskje ikke første gang
- Investering i læring
- 80% bra er ofte bra nok

### "Jeg liker å ha kontroll"
- Utforsk hva du frykter
- Kontroll ≠ kvalitet
- Tillit bygger kapasitet', 
     1, 12),
    ('Delegeringsmatrisen', 
     '## Hva Kan Delegeres?

### Deleger:
- Repetitive oppgaver
- Utviklingsmuligheter
- Ting andre kan gjøre minst 80% så bra

### Behold:
- Strategiske beslutninger
- Personalansvar
- Det som krever din unike kompetanse

### For hver oppgave, spør:
1. Må det være meg?
2. Hvem kan vokse på dette?
3. Hva trenger de for å lykkes?', 
     2, 12),
    ('Tydelige Forventninger', 
     '## Deleger Riktig

### Spesifiser:
- **Hva** skal leveres?
- **Når** trengs det?
- **Hvorfor** er det viktig?
- **Hvor mye** autonomi har de?

### Clarify sjekkpunkter:
- Når vil du ha oppdatering?
- Hva kan de bestemme selv?
- Når må de konsultere deg?

> "Utydelige forventninger er urettferdig mot alle."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 11: Lederens Konflikthåndtering
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Lederens Konflikthåndtering',
    'Håndter konflikter i teamet og organisasjonen. Lær meklerrollen og forebyggende strategier.',
    'lederens-konflikthandtering',
    TRUE, NULL, 'team-leader'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'lederens-konflikthandtering');

WITH course AS (SELECT id FROM courses WHERE slug = 'lederens-konflikthandtering')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Meklerrollen', 'Fasilitere løsning mellom parter.', 1),
    ('Strukturelle Konflikter', 'Når problemet er systemet, ikke personene.', 2),
    ('Forebygge Konflikter', 'Bygg et miljø med færre gnisninger.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'lederens-konflikthandtering' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Leder som Mekler', 
     '## Din Rolle i Konflikter

Som leder må du ofte:
- Høre begge sider
- Fasilitere samtale
- Ikke ta parti (med mindre det er påkrevd)
- Finne vei videre

### Når gripe inn?
- Når det påvirker arbeidet
- Når det eskalerer
- Når en part ber om hjelp
- Når det påvirker andre i teamet', 
     1, 12),
    ('Meklingssamtalen', 
     '## Strukturert Gjennomføring

### Steg 1: Forberedelse
- Snakk med begge parter separat først
- Forstå perspektivene
- Vurder om fellesmøte er riktig

### Steg 2: Fellesmøte
1. Sett rammen (trygghet, regler)
2. La hver part forklare sitt perspektiv
3. Speil og oppsummer
4. Fokuser på interesser, ikke posisjoner
5. Brainstorm løsninger sammen
6. Avtal konkrete steg

### Steg 3: Oppfølging
- Følg opp etter avtalt tid
- Anerkjenn fremgang
- Juster om nødvendig', 
     2, 15),
    ('Når Du Ikke Er Nøytral', 
     '## Noen Konflikter Krever Beslutning

### Du MÅ ta parti når:
- Det handler om verdier/etikk
- Én part trakasserer
- Det er klart regelbrudd
- Noen trenger beskyttelse

### Hvordan:
- Vær tydelig på at dette er din beslutning
- Forklar begrunnelsen
- Vær klar om konsekvenser
- Støtt opp om den som trenger det', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 12: Lederens Egenomsorg
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Lederens Egenomsorg',
    'Ta vare på deg selv som leder. Håndter stress, sett grenser og bygg et støttenettverk.',
    'lederens-egenomsorg',
    TRUE, NULL, 'team-leader'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'lederens-egenomsorg');

WITH course AS (SELECT id FROM courses WHERE slug = 'lederens-egenomsorg')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Lederens Stress', 'Forstå og håndtere presset som følger med rollen.', 1),
    ('Grenser Som Leder', 'Tilgjengelighet vs. egenomsorg.', 2),
    ('Støtte og Mentoring', 'Bygg nettverk for din egen utvikling.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'lederens-egenomsorg' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Ensomheten på Toppen', 
     '## Lederroller Er Ensomt

### Vanlige opplevelser:
- Kan ikke dele alt med teamet
- Må være "sterk" for andre
- Bærer byrder alene
- Føler seg mellom barken og veden

### Konsekvenser:
- Økt stress
- Dårligere beslutninger
- Utbrenthet
- Påvirker hjemmeliv

> "Du kan ikke helle fra en tom kopp."', 
     1, 12),
    ('Stressmestring for Ledere', 
     '## Praktiske Verktøy

### Daglige ritualer:
- Morgenrutine før e-post
- Pauser mellom møter
- Debriefing med deg selv

### Ukentlige praksiser:
- Refleksjonstid (45 min, blokkert)
- Fysisk aktivitet
- Tid uten jobb-tanker

### Månedlige:
- Mentor/coach-samtale
- Status på egen tilstand
- Justering av prioriteringer', 
     2, 12),
    ('Søke Støtte', 
     '## Du Trenger Andre

### Hvem kan støtte deg?
- **Mentor**: Erfaren leder du kan lære av
- **Coach**: Profesjonell utvikling
- **Ledernettverk**: Likesinnede i samme situasjon
- **Privat nettverk**: Partner, venner, familie

### Hva kan du dele hvor?
- Frustrasjoner om team → Coach/mentor (aldri team)
- Strategiske dilemmaer → Mentor/ledernettverk
- Personlige utfordringer → Privat nettverk
- Alt det tunge → Profesjonell (terapeut)

> "Å be om hjelp er styrke, ikke svakhet."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Link courses to workplace category
WITH work_cat AS (SELECT id FROM categories WHERE name = 'Arbeidsmiljø')
UPDATE courses SET category_id = work_cat.id
FROM work_cat
WHERE courses.slug IN (
    'lederen-som-trygghetsskaper', 'inkluderende-ledelse', 'tilbakemeldingskultur',
    'delegering-og-tillit', 'lederens-konflikthandtering', 'lederens-egenomsorg'
)
AND courses.category_id IS NULL;

-- Update assessment dimension recommendations
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'lederen-som-trygghetsskaper')
WHERE slug = 'creating-safety'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'team-leader-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'inkluderende-ledelse')
WHERE slug = 'inclusive-leadership'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'team-leader-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'tilbakemeldingskultur')
WHERE slug = 'feedback-culture'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'team-leader-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'delegering-og-tillit')
WHERE slug = 'delegation-trust'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'team-leader-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'lederens-konflikthandtering')
WHERE slug = 'leader-conflict'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'team-leader-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'lederens-egenomsorg')
WHERE slug = 'leader-wellbeing'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'team-leader-assessment');
