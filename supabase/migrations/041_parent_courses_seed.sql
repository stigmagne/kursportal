-- Migration: 040_parent_courses_seed.sql
-- Purpose: Seed course content for parents of children with chronic illness who also have healthy children

-- Create category for parent courses
INSERT INTO categories (name, description, color)
VALUES ('Foreldre', 'Kurs for foreldre med barn med kronisk sykdom/diagnose og friske barn', '#059669')
ON CONFLICT (name) DO NOTHING;

-- Course 4: Å Se Alle Barna
INSERT INTO courses (title, description, slug, published, cover_image)
SELECT 'Å Se Alle Barna',
    'Dette kurset hjelper deg å balansere oppmerksomhet mellom alle barna dine. Lær strategier for å se og ivareta det friske barnets behov, samtidig som du tar vare på barnet med diagnose.',
    'a-se-alle-barna',
    TRUE,
    NULL
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'a-se-alle-barna');

-- Course 4 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'a-se-alle-barna')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Det Friske Barnets Behov', 'Forstå hvordan familiesituasjonen påvirker det friske barnet. Lær å gjenkjenne tegn på at søsken sliter.', 1),
    ('Kvalitetstid i Hverdagen', 'Praktiske strategier for å skape individuell tid med hvert barn, selv med en travel hverdag.', 2),
    ('Allianse Uten Ekskludering', 'Bygg en familiekultur der alle føler tilhørighet og ingen føler seg utenfor.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 4, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'a-se-alle-barna' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Det Usynlige Barnet', 
     '## Fenomenet "Glass Children"

Forskning viser at søsken av barn med kronisk sykdom eller funksjonshemming har økt risiko for:
- Emosjonelle vansker
- Atferdsproblemer
- Lavere livskvalitet
- Følelse av å være "usynlig"

### Hvorfor Dette Skjer:
- Foreldrenes oppmerksomhet trekkes naturlig mot barnet som trenger mest
- Det friske barnet kan "dempe" egne behov for å ikke belaste
- Hverdagen preges av sykehusbesøk, behandling og bekymring

### Viktig Å Forstå:
Dette er ikke din feil. Det er en naturlig konsekvens av en vanskelig situasjon. Men med bevissthet kan du gjøre en forskjell.

> "Å anerkjenne utfordringen er første steg mot endring."', 
     1, 12),
    ('Tegn på at Søsken Sliter', 
     '## Hva Du Bør Se Etter

Søsken viser sjelden tydelig at de sliter. De har ofte lært å "ikke være til bry".

### Interne Tegn (ofte oversett):
- Tilsynelatende "for perfekt" oppførsel
- Unngår å snakke om egne problemer
- Tar på seg voksenansvar
- Bekymrer seg overdrevent for familien
- Distanserer seg fra situasjonen

### Eksterne Tegn:
- Akademiske problemer
- Sosial tilbaketrekning
- Fysiske symptomer (hodepine, magesmerter)
- Søvnproblemer
- Endringer i atferd

### Spør Aktivt
Ikke vent på at de skal komme til deg. Sjekk inn regelmessig:
"Hvordan har du det egentlig? Jeg vil gjerne høre om ditt liv."', 
     2, 15),
    ('Søskenintervensjoner', 
     '## Forskningsbaserte Tiltak

### Ting Som Hjelper Søsken:
1. **Aldersriktig informasjon** om diagnosen
2. **Individuell oppmerksomhet** fra foreldre
3. **Mulighet til å uttrykke** vanskelige følelser
4. **Kontakt med andre søsken** i samme situasjon
5. **Anerkjennelse av deres bidrag** til familien

### Praktiske Tiltak:
- Faste "en-til-en" aktiviteter med hvert barn
- Åpne samtaler om hvordan familiesituasjonen påvirker alle
- Feire det friske barnets prestasjoner og milepæler
- Tillate negat ive følelser uten dømmekraft

### Ressurser:
- Søskengrupper (mange sykehus tilbyr dette)
- Terapi for søsken
- Bøker og nettressurser for søsken', 
     3, 18)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 4, Module 2 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'a-se-alle-barna' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Tid vs. Kvalitet', 
     '## Det Handler Ikke Om Antall Timer

Forskning viser at kvaliteten på tid er viktigere enn mengden.

### Hva Er Kvalitetstid?
- Uforstyrret oppmerksomhet (legg bort telefonen)
- Aktivitet barnet velger
- Emosjonell tilstedeværelse
- Ingen diskusjon om søskenets sykdom

### 15-minutters Regelen
Bare 15 minutter med ekte, fokusert oppmerksomhet daglig kan gjøre en stor forskjell.

### Ideer til Korte Kvalitetsstunder:
- Morgenstund med frokost sammen (bare dere to)
- Gå en runde rundt kvartalet etter middag
- Les én bok sammen før leggetid
- Ha en "bil-samtale" på vei til aktiviteter

> "Det er ikke om du har tid, det er om du tar deg tid."', 
     1, 12),
    ('Rutiner for Individuell Tid', 
     '## Bygg Det Inn i Hverdagen

For at kvalitetstid skal skje konsistent, må det være planlagt.

### Praktiske Strategier:
1. **Kalenderblokker**: Sett av fast tid i kalenderen
2. **Rotasjon**: Hvis to foreldre - roter hvem som er med hvem
3. **"Spesialdager"**: Én gang i måneden gjør noe ekstra med hvert barn
4. **Hverdagsrutiner**: Legg inn "quality time" i eksisterende rutiner

### Eksempel Ukeplan:
| Dag | Aktivitet | Hvem |
|-----|-----------|------|
| Man | Morgenbading sammen | Pappa + friskt barn |
| Ons | Kjøre til trening (samtale) | Mamma + friskt barn |
| Lør | Kino/aktivitet | Ett barn om gangen |

### Når Ting Avlyses
Det vil skje at planer kanselleres. Kommuniser åpent og lag en ny plan umiddelbart.', 
     2, 15),
    ('Inkluder Friskt Barn Passende', 
     '## Del av Familien, Ikke Liten Omsorgsgiver

Det friske barnet vil ofte hjelpe. Det er bra, men det må balanseres.

### Sunne Måter å Inkludere:
- Fortell om sykdommen/diagnosen aldersriktig
- La dem være med på sykehusbesøk (hvis de vil)
- Gi dem små, aldersriktige oppgaver
- Anerkjenn bidraget deres

### Unngå:
- For mye ansvar for omsorg
- Forventning om at de alltid skal være fleksible
- Bruke dem som støtte for egen bekymring
- Gjøre dem til "reserve-voksen"

### Sjekk Inn Regelmessig:
"Føler du at du må hjelpe for mye?"
"Er det noe du gjerne skulle gjort mer av for deg selv?"', 
     3, 15)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 4, Module 3 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'a-se-alle-barna' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Familieidentitet', 
     '## Vi Er Mer Enn Sykdommen

En viktig beskyttende faktor for alle familiemedlemmer er en familieidentitet som ikke kun handler om diagnosen.

### Bygg Felles Opplevelser:
- Familietradisjoner som alle kan delta i
- Samtaleemner utenom sykdom
- Feire alle barnas prestasjoner likt
- Ha morsomme aktiviteter sammen

### "Sykdomsfrie" Soner:
- Middagsbordet: Prat om dagen, ikke behandling
- Helgeaktiviteter: Fokus på glede og fellesskap
- Ferieturer: Så langt det er mulig, fokus på normalitet

> "Familien vår er sterkere enn utfordringene våre."', 
     1, 12),
    ('Søskenrelasjonen', 
     '## Styrk Båndet Mellom Barna

Søskenrelasjonen påvirkes av familiesituasjonen, men kan også være en kilde til styrke.

### Utfordringer:
- Misunnelse (over oppmerksomhet)
- Skyldfølelse (hos begge søsken)
- Ubalanse i dynamikken
- Ulike roller i familien

### Styrk Relasjonen:
1. **La barna ha tid alene** - uten foreldre som buffer
2. **Normaliser konflikter** - søsken krangler, det er OK
3. **Unngå sammenligning** - hvert barn er unikt
4. **Støtt deres egen relasjon** - ikke vær mellommann

### Samtalestart:
Spør det friske barnet: "Hvordan er det å være søsken til [navn]?"', 
     2, 15),
    ('Langsiktig Perspektiv', 
     '## Investering i Fremtiden

Det du gjør nå påvirker hvordan barna dine har det som voksne.

### Forskning Viser:
- Søsken som føler seg sett, klarer seg bedre
- Åpen kommunikasjon beskytter mot psykiske vansker
- Positive søskenrelasjoner varer livet ut

### Refleksjon:
- Hvordan vil jeg at barna mine skal huske barndommen?
- Hva vil jeg at det friske barnet skal føle om sin plass i familien?
- Hvordan kan jeg investere i søskenrelasjonen nå?

### Avslutning
Du gjør en utrolig innsats i en vanskelig situasjon. At du tar dette kurset viser at du bryr deg om alle barna dine.', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 5: Kommunikasjon i Familien
INSERT INTO courses (title, description, slug, published, cover_image)
SELECT 'Kommunikasjon i Familien',
    'Lær å skape en kultur av åpen og ærlig kommunikasjon i familien. Dette kurset gir deg verktøy for å snakke om sykdom, følelser og utfordringer på en måte som styrker familiens bånd.',
    'kommunikasjon-i-familien',
    TRUE,
    NULL
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'kommunikasjon-i-familien');

-- Course 5 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'kommunikasjon-i-familien')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Aldersriktig Informasjon', 'Hvordan forklare diagnosen/sykdommen til barn i ulike aldre. Balansere ærlighet og beskyttelse.', 1),
    ('Lytte Aktivt', 'Teknikker for å virkelig høre hva barna prøver å si, også det usagte.', 2),
    ('Familiesamtaler', 'Strukturer for regelmessige familiesamtaler som gir alle en stemme.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 5, Module 1-3 Lessons (abbreviated for brevity)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'kommunikasjon-i-familien' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hvorfor Åpenhet Beskytter', 
     '## Barn Vet Mer Enn Du Tror

Forskning viser at barn ofte vet at noe er galt, selv uten å bli fortalt. Mangel på informasjon fører til at de fyller tomrommene selv – ofte med verre antakelser.

### Fordeler med Åpenhet:
- Reduserer angst og usikkerhet
- Bygger tillit mellom foreldre og barn
- Forbereder dem på hva som kan skje
- Gir dem mulighet til å bearbeide

### Myter vs. Realitet:
✗ "Barn bør beskyttes fra sannheten"
✓ "Barn trenger aldersriktig sannhet"

✗ "Det vil bare bekymre dem mer"
✓ "Uvisshet bekymrer mer enn fakta"', 
     1, 12),
    ('Kommunikasjon per Alder', 
     '## Tilpass Informasjonen

### 3-5 år:
- Enkle, konkrete forklaringer
- "Søsteren din er syk i [kroppsdel]"
- Fokuser på at det ikke er deres feil
- Gi trygghet om hva som er likt

### 6-12 år:
- Mer detaljert informasjon
- Svar ærlig på spørsmål
- Forklar behandling og prognose enkelt
- Involver dem i tilpassede oppgaver

### 13+ år:
- Full informasjon (med unntak)
- Diskuter følelser og bekymringer åpent
- Anerkjenn at de kan ha egne spørsmål til leger
- Gi rom for at de prosesserer på sin måte', 
     2, 15),
    ('Når og Hvordan Fortelle', 
     '## Praktiske Tips

### Før Samtalen:
1. Velg et rolig tidspunkt (ikke rett før leggetid)
2. Ha partneren med hvis mulig
3. Forbered enkle ord
4. Vær klar for spørsmål

### Under Samtalen:
- Start med at du har noe viktig å fortelle
- Snakk rolig og enkelt
- Tåle stillhet og følelser
- Spør hva de tenker/føler

### Etter Samtalen:
- Sjekk inn dagene etter
- "Har du tenkt mer på det vi snakket om?"
- Vær tilgjengelig for oppfølgingsspørsmål
- Normaliser at de kan ha mange følelser', 
     3, 15)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 6: Egen Mestring som Forelder
INSERT INTO courses (title, description, slug, published, cover_image)
SELECT 'Egen Mestring som Forelder',
    'Ta vare på deg selv for å kunne ta vare på andre. Dette kurset fokuserer på egenomsorg, håndtering av skyldfølelse, og ivaretakelse av parforholdet i en krevende familiesituasjon.',
    'egen-mestring-som-forelder',
    TRUE,
    NULL
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'egen-mestring-som-forelder');

-- Course 6 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'egen-mestring-som-forelder')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Skyld og Skam', 'Bearbeide vanskelige følelser som forelder. Forstå at du gjør så godt du kan.', 1),
    ('Parforholdet Under Press', 'Ivareta relasjonen til partner midt i kaoset. Kommunikasjon og samarbeid.', 2),
    ('Mitt Eget Støttenettverk', 'Bygge støtte utenfor barnas behov. Akseptere hjelp og omsorg.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 6, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'egen-mestring-som-forelder' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Foreldreskyld', 
     '## En Universell Opplevelse

Nesten alle foreldre i din situasjon opplever skyldfølelse. Du er ikke alene.

### Vanlige Tanker:
- "Jeg burde gjøre mer for det friske barnet"
- "Det er min feil at ting er som de er"
- "En god forelder ville håndtert dette bedre"
- "Jeg er ikke nok for noen av barna"

### Viktig Å Forstå:
Skyldfølelse er en følelse, ikke en sannhet. At du føler deg skyldig betyr ikke at du HAR skyld.

### NLP-reframe:
Fra: "Jeg er en dårlig forelder"
Til: "Jeg er en forelder som gjør mitt beste i en vanskelig situasjon"', 
     1, 12),
    ('Selvmedfølelse', 
     '## Snakk Til Deg Selv Som En Venn

Hvordan ville du snakket til en venn i din situasjon? Sannsynligvis mye snillere enn du snakker til deg selv.

### Tre Komponenter av Selvmedfølelse:
1. **Mindfulness**: Anerkjenn smerten uten å overdrive
2. **Felles menneskelighet**: Du er ikke alene
3. **Vennlighet**: Vær snill mot deg selv

### Øvelse: Selvmedfølelsespause
Legg hånden på hjertet og si:
"Dette er vanskelig. Andre foreldre sliter også med dette. Måtte jeg være snill mot meg selv."

### Daglig Praksis:
- Når selvkritikken kommer, stopp opp
- Spør: "Hva ville jeg sagt til en venn?"
- Si dette til deg selv', 
     2, 15),
    ('Bearbeide Sorg', 
     '## Sorg Over Det Uventede

Mange foreldre opplever en form for sorg – sorg over drømmen om "den perfekte familien", sorg over barndommen det friske barnet går glipp av.

### Dette Er Normalt:
- Sorg er ikke bare for dødsfall
- Det er lov å sørge over ting som ikke ble som forventet
- Sorg og kjærlighet kan eksistere samtidig

### Gi Rom for Sorgen:
1. Anerkjenn følelsen
2. Ikke prøv å "fikse" den
3. Del med noen du stoler på
4. Søk profesjonell hjelp om nødvendig

> "Å tillate sorgen er ikke det samme som å gi opp håpet."', 
     3, 15)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Link courses to parent category
WITH parent_cat AS (SELECT id FROM categories WHERE name = 'Foreldre')
UPDATE courses SET category_id = parent_cat.id
FROM parent_cat
WHERE courses.slug IN ('a-se-alle-barna', 'kommunikasjon-i-familien', 'egen-mestring-som-forelder');

-- Link assessment dimensions to courses for recommendations
-- Sibling courses
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'a-forsta-mine-folelser')
WHERE slug = 'emotional-regulation' 
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'sibling-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'min-stemme-mine-grenser')
WHERE slug IN ('communication', 'role-responsibility')
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'sibling-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'hvem-er-jeg')
WHERE slug IN ('identity', 'future-orientation', 'social-support')
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'sibling-assessment');

-- Parent courses
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'a-se-alle-barna')
WHERE slug IN ('attention-balance', 'sibling-awareness')
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'parent-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'kommunikasjon-i-familien')
WHERE slug = 'family-communication'
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'parent-assessment');

UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(SELECT id FROM courses WHERE slug = 'egen-mestring-som-forelder')
WHERE slug IN ('parental-wellbeing', 'partner-relationship', 'guilt-processing')
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'parent-assessment');
