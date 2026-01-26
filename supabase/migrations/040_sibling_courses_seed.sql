-- Migration: 039_sibling_courses_seed.sql
-- Purpose: Seed course content for adult siblings (18+) of children with chronic illness

-- Create category for sibling courses
INSERT INTO categories (name, description, color)
VALUES ('Søsken', 'Kurs for voksne søsken av personer med kronisk sykdom eller diagnose', '#7C3AED')
ON CONFLICT (name) DO NOTHING;

-- Course 1: Å Forstå Mine Følelser
INSERT INTO courses (title, description, slug, published, cover_image)
SELECT 'Å Forstå Mine Følelser',
    'Dette kurset hjelper deg å utforske og forstå de komplekse følelsene som kan oppstå når du har et søsken med kronisk sykdom eller diagnose. Gjennom NLP-teknikker og refleksjonsøvelser lærer du å gjenkjenne, akseptere og håndtere dine følelser på en sunn måte.',
    'a-forsta-mine-folelser',
    TRUE,
    NULL
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'a-forsta-mine-folelser');

-- Course 1 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'a-forsta-mine-folelser')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Følelseskartet', 'Lær å identifisere og navngi følelsene dine. Utforsk hvorfor det er normalt å føle motstridende følelser som kjærlighet, frustrasjon, skyld og sinne samtidig.', 1),
    ('Kroppen Forteller', 'Oppdag hvordan følelser manifesterer seg i kroppen. Lær grounding-teknikker og øvelser for å regulere nervesystemet når følelsene blir overveldende.', 2),
    ('Mitt Indre Team', 'Bruk NLP-basert "parts work" for å forstå at ulike deler av deg har ulike behov. Lær å lytte til og balansere disse indre stemmene.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 1, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'a-forsta-mine-folelser' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Introduksjon: Hvorfor Følelser er Viktige', 
     '## Velkommen til Følelseskartet

Som søsken av noen med kronisk sykdom eller diagnose har du kanskje opplevd at dine egne følelser kommer i skyggen. Dette kurset handler om å ta plass for dine følelser.

### Det er normalt å føle...
- Kjærlighet og frustrasjon samtidig
- Skyldfølelse for å ha det bra
- Sinne som du ikke "burde" føle
- Sorg over en barndom som var annerledes
- Stolthet over din motstandsdyktighet

> "Alle følelser er gyldige. Ingen følelse er feil."

### Øvelse: Følelseshjulet
Ta et øyeblikk og kjenn etter: Hvilke følelser er tilstede akkurat nå? Ikke døm dem, bare observer.', 
     1, 10),
    ('Navngi For å Temme', 
     '## Kraften i å Sette Ord på Følelser

Forskning viser at det å navngi følelser aktiverer prefrontal cortex og roer ned amygdala. Med andre ord: Å si "jeg er frustrert" hjelper hjernen å regulere følelsen.

### Utvid Følelsesordforrådet
I stedet for bare "sint" eller "lei seg", prøv mer nyanserte ord:
- Frustrert, irritert, opprørt, rasende
- Trist, melankolsk, skuffet, sorgfull
- Bekymret, urolig, engstelig, redd

### Øvelse: Følelsesdagbok
De neste tre dagene, noter hvilke følelser du opplever. Prøv å bruke minst tre ulike ord per dag.', 
     2, 12),
    ('Ambivalens er Normalt', 
     '## Å Holde To Sannheter Samtidig

En av de vanligste opplevelsene for søsken er **ambivalens** – å føle motstridende følelser på samme tid.

### Eksempler på Ambivalens:
- "Jeg elsker søsteren min, OG jeg er sliten av situasjonen"
- "Jeg er takknemlig for hva jeg har lært, OG jeg skulle ønske barndommen var annerledes"
- "Jeg vil hjelpe, OG jeg trenger tid for meg selv"

### NLP-teknikk: "Og" i Stedet for "Men"
Prøv å erstatte "men" med "og" når du beskriver følelsene dine. Dette tillater begge sannhetene å eksistere.

> "Jeg elsker familien min, OG noen ganger er det vanskelig."

### Refleksjon
Hvilke motstridende følelser kjenner du på? Kan du tillate begge å eksistere?', 
     3, 15)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 1, Module 2 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'a-forsta-mine-folelser' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Følelser i Kroppen', 
     '## Hvor Bor Følelsene Dine?

Følelser er ikke bare tanker – de er kroppslige opplevelser. Å bli bevisst på hvor du kjenner følelser kan hjelpe deg å regulere dem.

### Vanlige Kroppslige Signaler:
- **Angst/uro**: Knuter i magen, rask puls, grunt pust
- **Tristhet**: Tyngde i brystet, tårer bak øynene
- **Sinne**: Varme i ansiktet, spent kjeve, knyttede never
- **Glede**: Letthet i kroppen, energi, smil

### Øvelse: Kroppsskanning
1. Sett deg komfortabelt med lukkede øyne
2. Start ved føttene og beveg oppmerksomheten oppover
3. Legg merke til områder med spenning eller ubehag
4. Bare observer – ikke prøv å endre noe

Denne øvelsen trener deg i å lytte til kroppens signaler.', 
     1, 12),
    ('Grounding-teknikker', 
     '## Når Følelsene Blir For Store

Noen ganger kan følelser føles overveldende. Grounding-teknikker hjelper deg å komme tilbake til øyeblikket.

### 5-4-3-2-1 Teknikken
Navngi:
- **5** ting du kan SE
- **4** ting du kan KJENNE
- **3** ting du kan HØRE
- **2** ting du kan LUKTE
- **1** ting du kan SMAKE

### Dyp Pusting (4-7-8)
1. Pust inn gjennom nesen i 4 sekunder
2. Hold pusten i 7 sekunder
3. Pust ut gjennom munnen i 8 sekunder
4. Gjenta 3-4 ganger

### Når Bruke Disse?
- Før vanskelige samtaler
- Når du føler panikk eller angst
- Når minnene blir for intense
- For å samle deg før viktige avgjørelser', 
     2, 15),
    ('Somatisk Opplevelse', 
     '## Regulere Nervesystemet

Søsken av personer med kronisk sykdom kan ofte ha et nervesystem som er "på vakt". Dette er en naturlig respons på å vokse opp med usikkerhet.

### Nervesystemets Tilstander:
- **Kamp/flukt**: Rask puls, anspent, overvåken
- **Frys**: Nummenhet, avkobling, lammelse
- **Trygt/sosialt**: Avslappet, tilstede, koblet til andre

### Øvelse: Schmetterlingsklapp
1. Kryss armene over brystet
2. Veksle mellom å klappe lett på skuldrene
3. Fortsett i 2-3 minutter mens du puster rolig
4. Denne bilateral stimuleringen kan roe nervesystemet

### Refleksjon
Hvilken tilstand befinner du deg oftest i? Hva hjelper deg å føle deg trygg?', 
     3, 18)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 1, Module 3 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'a-forsta-mine-folelser' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Introduksjon til Parts Work', 
     '## Dine Indre Stemmer

NLP og andre terapiformer bruker konseptet "parts" – ideen om at vi alle har ulike deler av oss selv med ulike behov og perspektiver.

### Vanlige "Deler" hos Søsken:
- **Hjelperen**: Vil alltid stille opp for andre
- **Det Usynlige Barnet**: Føler seg oversett og glemt
- **Den Ansvarlige**: Tar på seg for mye
- **Den Skyldbetyngede**: Føler skyld for egne behov
- **Drømmeren**: Ønsker et annet liv

### Viktig Innsikt
Ingen av disse delene er "feil". De oppsto alle for å hjelpe deg å navigere en vanskelig situasjon.

> "Alle dine deler fortjener å bli hørt."

### Øvelse
Hvilke "deler" kjenner du igjen i deg selv? Gi dem navn.', 
     1, 12),
    ('Å Lytte til Delene', 
     '## Dialog med Dine Indre Deler

Når vi lytter til våre indre deler med nysgjerrighet i stedet for dømmekraft, kan vi forstå hva de prøver å beskytte oss fra.

### Øvelse: Intervju med en Del
1. Velg en "del" du vil utforske (f.eks. "Hjelperen")
2. Still spørsmålene:
   - Hva er din intensjon?
   - Hva er du redd for?
   - Hva trenger du?
3. Lytt uten å dømme

### Eksempel: Hjelperen
- **Intensjon**: Jeg vil at alle skal ha det bra
- **Frykt**: At hvis jeg ikke hjelper, vil ingen elske meg
- **Behov**: Å vite at jeg er verdsatt for den jeg er, ikke bare hva jeg gjør

### Refleksjon
Hva lærte du om denne delen av deg selv?', 
     2, 15),
    ('Integrering og Balanse', 
     '## Å Samarbeide med Alle Delene

Målet med "parts work" er ikke å eliminere deler av deg selv, men å skape harmoni mellom dem.

### Prinsipper for Integrering:
1. **Anerkjennelse**: Alle deler har en positiv intensjon
2. **Dialog**: La delene kommunisere med hverandre
3. **Ledelse**: Ditt voksne, vise selv kan lede
4. **Balanse**: Gi hver del passende plass

### Visualisering: Rundt Bordet
Forestill deg alle dine "deler" sittende rundt et bord. Du sitter som leder. Spør: "Hva trenger hver av dere akkurat nå?"

### Avsluttende Refleksjon
Å forstå følelsene dine er en livslang reise. Du har nå verktøy for å:
- Navngi og validere følelser
- Regulere gjennom kroppen
- Lytte til dine indre deler

Bruk journalen til å fortsette denne utforskningen.', 
     3, 15)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 2: Min Stemme, Mine Grenser
INSERT INTO courses (title, description, slug, published, cover_image)
SELECT 'Min Stemme, Mine Grenser',
    'Lær å kommunisere dine behov og sette sunne grenser uten skyldfølelse. Dette kurset gir deg praktiske verktøy for selvhevdelse og åpen kommunikasjon i familien, basert på NLP-prinsipper.',
    'min-stemme-mine-grenser',
    TRUE,
    NULL
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'min-stemme-mine-grenser');

-- Course 2 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'min-stemme-mine-grenser')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Å Bli Hørt', 'Utvikle ferdigheter for å uttrykke dine behov og bli hørt i familien. Lær teknikker for klar og tydelig kommunikasjon.', 1),
    ('Grensesetting Uten Skyld', 'Forstå hvorfor grenser er kjærlighet, ikke egoisme. Praktiske øvelser for å sette og opprettholde sunne grenser.', 2),
    ('Vanskelige Samtaler', 'Strategier for å ta opp sensitive temaer med foreldre og søsken. Hvordan navigere konfl ikt og uenighet konstruktivt.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 2, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'min-stemme-mine-grenser' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Dine Behov Er Gyldige', 
     '## Du Har Rett til Å Ha Behov

Som søsken har du kanskje lært å sette egne behov til side. Dette kurset handler om å ta tilbake stemmen din.

### Vanlige Myter hos Søsken:
- ❌ "Mine problemer er ingenting sammenlignet med..."
- ❌ "Det er ikke plass til mine behov"
- ❌ "Jeg burde bare være takknemlig"

### Sannheten:
- ✓ Dine behov er like gyldige som andres
- ✓ Å ta vare på deg selv er ikke egoistisk
- ✓ Du fortjener å bli hørt

### NLP-teknikk: Reframing
I stedet for: "Jeg er egoistisk som vil ha oppmerksomhet"
Prøv: "Å ønske oppmerksomhet er et grunnleggende menneskelig behov"

### Øvelse
Skriv ned tre behov du har som du ikke har uttrykt. Bare å anerkjenne dem er første steg.', 
     1, 12),
    ('Jeg-budskap', 
     '## Kommuniser Uten Å Anklage

"Jeg-budskap" er en teknikk for å uttrykke følelser uten å få den andre i forsvar.

### Formelen:
"Når [situasjon], føler jeg [følelse], fordi [grunn]. Jeg trenger/ønsker [behov]."

### Eksempler:
❌ "Du bryr deg aldri om meg!"
✓ "Når alle samtaler handler om Marias behandling, føler jeg meg usynlig, fordi jeg også har ting jeg trenger å snakke om. Jeg skulle ønske vi hadde tid til å snakke om mitt liv også."

❌ "Du forventer alltid at jeg skal hjelpe!"
✓ "Når jeg blir bedt om å hjelpe uten å bli spurt først, føler jeg meg tatt for gitt. Jeg trenger å bli spurt, ikke fortalt."

### Øvelse
Tenk på en situasjon der du følte deg frustrert. Omformuler til et jeg-budskap.', 
     2, 15),
    ('Aktiv Lytting', 
     '## Å Bli Hørt Starter med Å Høre

God kommunikasjon går begge veier. Når du lytter aktivt, skaper du et fundament for at andre også lytter til deg.

### Teknikker for Aktiv Lytting:
1. **Speiling**: Gjenta det den andre sa med egne ord
2. **Validering**: "Det høres ut som du føler..."
3. **Åpne spørsmål**: "Kan du fortelle mer om...?"
4. **Pause**: Gi rom for stillhet

### NLP-konsept: Rapport
Rapport handler om å skape forbindelse gjennom:
- Matchende kroppsspråk
- Samme tempo i stemmen
- Vise genuin interesse

### Øvelse: Lytte-utfordring
I din neste samtale med et familiemedlem, fokuser kun på å lytte i 5 minutter uten å planlegge ditt svar.', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 2, Module 2-3 (abbreviated for length)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'min-stemme-mine-grenser' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hvorfor Grenser er Kjærlighet', 
     '## Grenser Beskytter Relasjoner

Mange tror at grenser handler om å holde folk ute. I virkeligheten handler de om å bevare relasjoner.

### Grenser = Selvrespekt
- Grenser kommuniserer hva du trenger for å ha det bra
- Uten grenser, risikerer du utbrenthet og bitterhet
- Med grenser, kan du gi av overskudd, ikke underskudd

### Vanlige Grense-utfordringer for Søsken:
- Føler du må alltid være tilgjengelig
- Tar på deg emosjonelt arbeid for hele familien
- Sier ja når du mener nei
- Føler skyld for egentid

> "Et nei til andre er et ja til deg selv."', 
     1, 12),
    ('Å Sette Grenser i Praksis', 
     '## Praktisk Grensesetting

### De Fire Stegene:
1. **Identifiser**: Hva trenger jeg?
2. **Kommuniser**: Si det tydelig og rolig
3. **Oppretthold**: Vær konsistent
4. **Aksepter følelsene**: Andres reaksjoner er ikke ditt ansvar

### Eksempler på Grenser:
- "Jeg kan ikke komme på sykehuset hver dag, men jeg kan komme onsdager."
- "Jeg trenger at vi snakker om andre ting enn sykdommen iblant."
- "Jeg setter pris på at du vil dele, men jeg har ikke kapasitet akkurat nå."

### Når Andre Reagerer Negativt
Det er normalt at andre ikke liker nye grenser. Din jobb er ikke å kontrollere deres reaksjon.', 
     2, 15),
    ('Selvmedfølelse når Grenser Brytes', 
     '## Når Du Ikke Klarer å Holde Grensene

Ingen er perfekt. Du vil noen ganger si ja når du mente nei.

### Selvmedfølelsesmantra:
"Jeg gjorde så godt jeg kunne med de ressursene jeg hadde i øyeblikket."

### Lær av Situasjonen:
1. Hva trigget meg til å bryte grensen?
2. Hva kan jeg gjøre annerledes neste gang?
3. Hvordan kan jeg reparere nå?

> "Perfeksjon er ikke målet. Progresjon er."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 3: Hvem Er Jeg?
INSERT INTO courses (title, description, slug, published, cover_image)
SELECT 'Hvem Er Jeg?',
    'Utforsk din identitet utenfor rollen som søsken. Dette kurset hjelper deg å finne og styrke din egen identitet, dine drømmer og ditt støttenettverk.',
    'hvem-er-jeg',
    TRUE,
    NULL
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'hvem-er-jeg');

-- Course 3 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'hvem-er-jeg')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Mer Enn En Rolle', 'Utforsk hvem du er utenom "søskenrollen". Finn tilbake til deg selv og dine unike kvaliteter.', 1),
    ('Mine Drømmer', 'Gi deg selv tillatelse til å ha egne mål og drømmer for fremtiden. Visualiserings- og planleggingsverktøy.', 2),
    ('Mitt Støttenettverk', 'Bygg et støttenettverk utenfor familien. Finn fellesskap og relasjoner som nærer deg.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Add a lesson to each module of Course 3 (abbreviated)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'hvem-er-jeg' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Glass Children', 
     '## Fenomenet "Glass Children"

Begrepet "glass children" beskriver søsken som føler seg usynlige – som om foreldrene ser rett igjennom dem til barnet som trenger mer.

### Typiske Opplevelser:
- Føle at du måtte være "den enkle"
- Undertrykke egne behov for å ikke være en byrde
- Modne raskere enn jevnaldrende
- Ha diffus identitet utenom familierollen

### Viktig Innsikt
Disse erfaringene har formet deg, men de definerer ikke deg.

> "Du er mer enn din rolle i familien."', 
     1, 12),
    ('Dine Unike Styrker', 
     '## Hva Gjør Deg til Deg?

Søsken utvikler ofte bemerkelseverdige styrker:
- Empati og omsorg
- Ansvarlighet
- Fleksibilitet
- Motstandsdyktighet

### Øvelse: Styrkeidentifikasjon
1. Tenk på tre situasjoner der du håndterte noe vanskelig
2. Hvilke egenskaper brukte du?
3. Hvordan kan disse styrkene tjene deg i fremtiden?', 
     2, 15),
    ('Å Skrive Din Egen Historie', 
     '## Fra Offer til Forfatter

NLP-prinsipp: Du kan ikke endre fortiden, men du kan endre fortellingen om den.

### Øvelse: Omskriving
Skriv din livshistorie fra to perspektiver:
1. **Før**: Fokus på det du mistet
2. **Etter**: Fokus på det du lærte og hvordan du vokste

Begge er sanne. Hvilken historie vil du bære med deg videre?', 
     3, 18)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Link courses to sibling category
WITH sibling_cat AS (SELECT id FROM categories WHERE name = 'Søsken')
UPDATE courses SET category_id = sibling_cat.id
FROM sibling_cat
WHERE courses.slug IN ('a-forsta-mine-folelser', 'min-stemme-mine-grenser', 'hvem-er-jeg');
