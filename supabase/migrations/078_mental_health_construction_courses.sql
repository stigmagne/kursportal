-- Migration: 078_mental_health_construction_courses.sql
-- Purpose: Create 3 courses on mental health and colleague support for construction workers
-- Based on workshop "Guttastemning 2.0 – å ha ryggen til hverandre"
-- Applies to both construction workers and site managers
-- Content in Bokmål

-- =====================================================
-- COURSE 1: Guttastemning 2.0
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Guttastemning 2.0',
    'Ha ryggen til hverandre. Lær å se når kolleger ikke har det bra, og hvordan du kan ta kontakt uten at det blir kleint. Dette handler ikke om terapi - det handler om arbeidskultur.',
    'guttastemning-2-0',
    TRUE,
    NULL,
    'construction_worker'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'guttastemning-2-0');

-- Course 1 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'guttastemning-2-0')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Humor Og Harde Tak', 'Hva er bra med guttastemning - og hva skjer når noen faktisk ikke har det bra?', 1),
    ('Se Uten Å Overse', 'Lær å legge merke til signaler og ta kontakt uten å gjøre det til en stor greie.', 2),
    ('Ryggen Til Hverandre', 'Definer hva det betyr i praksis å ha ryggen til hverandre på din arbeidsplass.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 1, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'guttastemning-2-0' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hva Mener Vi Med Guttastemning?', 
     '## Det Gode I Kulturen

Når folk sier "guttastemning" på jobb, mener vi ofte:
- Humor
- Erting
- Direkte prat
- Lite drama
- Samhold

### Det Positive
Dette skaper ofte:
- Godt arbeidsmiljø
- Effektivt samarbeid
- Folk som trives

### Spørsmålet
Men: Hva skjer når noen faktisk ikke har det bra?

Når kulturen sier "vi tuller og har det gøy", kan det være vanskelig å:
- Innrømme at du sliter
- Vise sårbarhet
- Be om hjelp

> "Guttastemning er bra. Men den må ha rom for at folk også kan ha det tøft."', 
     1, 10),
    
    ('Realiteten I Bransjen', 
     '## Hva Folk Faktisk Står I

Dette er ikke synd på oss-snakk. Det er realitetssjekk.

### Vanlige Belastninger
- **Tidspress**: Alltid for lite tid
- **Økonomi**: Usikkerhet, akkordpress
- **Kroppen**: Slitasje, smerter
- **Familie**: Lange dager, lite tid hjemme
- **Ansvar**: Kvalitet, sikkerhet, andre

### Normalt Å Ha Det Tungt
Det er normalt at folk av og til får det tungt. Det er ikke svakhet.

Problemet oppstår når:
- Folk ikke sier noe
- Ingen spør
- Belastningen hoper seg opp

> "Poenget er ikke at vi har det synd. Poenget er at belastning er normalt - og noe vi må ta hensyn til."', 
     2, 12),
    
    ('Når Folk Ikke Sier Fra', 
     '## Stille Signaler

En kollega begynner å bli:
- Mer kort i svara
- Mer fraværende
- Gjør flere småfeil
- Trekker seg tilbake

Men han sier ingenting. Ingen spør.

Så plutselig: sykefravær, konflikt eller oppsigelse.

### Signalene Vi Ser
- Endret humør
- Mindre engasjement
- Mer irritabel
- Trekker seg fra sosiale situasjoner
- Slurv som ikke er typisk

### Hva Gjør Vi Vanligvis?
Ofte: Ingenting. Vi ser det, men vet ikke hva vi skal gjøre.

> "Vi ser det ofte. Men vi vet ikke helt hva vi skal gjøre med det."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 1, Module 2 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'guttastemning-2-0' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hva Er Kollegastøtte?', 
     '## Det Handler Ikke Om Å Fikse

Viktig avklaring:

**Kollegastøtte er IKKE:**
- Terapi
- Løse andres problemer
- Bli noens psykolog
- Ta ansvar for andres liv

**Kollegastøtte ER:**
- Legge merke til
- Ta kontakt
- Ikke late som du ikke ser

### Tre Nivåer

**1. Legge merke til**
"Du virker ikke helt deg selv i dag"

**2. Ta kontakt**
Kort, lavterskel, uten forhør

**3. Ikke la dem stå alene**
Hjelpe videre hvis det trengs

> "Kollegastøtte handler om å åpne døra, ikke om å gå hele veien for dem."', 
     1, 12),
    
    ('Ta Praten Uten Å Gjøre Det Kleint', 
     '## Konkrete Formuleringer

Det viktigste er ikke hva du sier. Det viktigste er at du ikke lar det passere.

### Lavterskel-innganger
- "Du, alt greit om dagen?"
- "Du virker litt sliten, bare så du vet at jeg ser det."
- "Hva skjer a? Virker som noe er på gang."

### Hvis Noe Faktisk Er Galt
- "Vil du snakke litt, eller vil du bare ha litt ro nå?"
- "Skal vi ta en kaffe etter jobb?"
- "Jeg vet ikke hva som skjer, men hvis du trenger en å prate med..."

### Timing
- Ikke midt i full fart
- Helst en-til-en
- Kan være uformelt (i bilen, pause)

### Husk
Du trenger ikke ha svar. Du trenger bare vise at du bryr deg.

> "Det trenger ikke være perfekt. Det trenger bare å være ekte."', 
     2, 12),
    
    ('Når Du Blir Avvist', 
     '## Ikke Alle Vil Snakke

Og det er greit. Folk håndterer ting forskjellig.

### Typiske Reaksjoner
- "Nei, alt er fint" (selv om det åpenbart ikke er det)
- Vitsing for å avlede
- Endrer tema
- Blir irritert

### Hvordan Håndtere
- Ikke press
- La døra stå åpen: "Greit, men si fra hvis du vil snakke"
- Sjekk inn igjen senere
- Respekter grenser

### Du Har Gjort Din Jobb
Bare det å spørre sender et signal:
- Jeg ser deg
- Jeg bryr meg
- Du er ikke alene

Det kan bety mer enn du tror, selv om de ikke tar imot akkurat da.

> "Å bli sett er verdifullt - selv når man ikke er klar til å snakke."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 1, Module 3 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'guttastemning-2-0' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Guttastemning 2.0 - Ny Definisjon', 
     '## Vi Blir Ikke Et Kontor Med Dagbøker

La oss være ærlige: Vi kommer ikke til å sitte i ring og dele følelser.

(Og det trenger vi ikke.)

### Men Vi Kan Være
Et sted der vi:
- Kan tulle og ha det gøy
- OG tar vare på hverandre når det trengs

### Hva Betyr Det I Praksis?
- Vi sier fra hvis noen virker på felgen
- Vi lar ikke folk stå alene
- Vi snakker ikke dritt om folk som sliter
- Vi respekterer at folk har tunge perioder

### Nye Kjøreregler
"Hos oss betyr guttastemning 2.0 at..."
- Vi har humor, men ikke på bekostning av de som sliter
- Vi spør hvordan det går - og mener det
- Vi baksnakker ikke folk som har det tøft

> "Vi kan kødde - men vi lar ikke folk falle gjennom."', 
     1, 12),
    
    ('Når Kollegastøtte Ikke Er Nok', 
     '## Å Vite Når Det Trengs Mer

Noen ganger er ikke en prat med kollega nok. Og det er ikke svakhet å trenge mer hjelp.

### Tegn På At Det Trengs Mer
- Vedvarende endring over tid
- Snakk om håpløshet
- Alvorlige livshendelser
- Du er bekymret på alvor

### Hvem Kan Hjelpe
- Bedriftshelsetjeneste
- Fastlege
- Psykolog
- Evt. interne ressurser (HR, verneombud)

### Hvordan Hjelpe Videre
- "Har du snakket med noen om dette?"
- "Vil du at jeg skal hjelpe deg finne noen å snakke med?"
- "Bedriftshelsetjenesten er der for akkurat slike ting"

### Viktig
Det å be om hjelp er ikke å gi opp. Det er å ta ansvar.

> "Å koble noen til profesjonell hjelp er også kollegastøtte."', 
     2, 12),
    
    ('Sterkere Sammen', 
     '## Hva Tar Vi Med Oss?

### For Deg Personlig
Neste gang du ser at en kollega ikke har det bra:
- Ikke la det passere
- Si noe - selv om det føles kleint
- Du trenger ikke ha svar

### For Teamet
Hva kan dere gjøre for å være mer påkoblet hverandre?
- Korte check-ins
- Sosiale pauser
- Passe på de som trekker seg tilbake

### Den Nye Standarden
Guttastemning 2.0 betyr:
- Vi har ryggen til hverandre
- Vi ser når folk sliter
- Vi handler på det vi ser

> "Dette handler ikke om å bli mykere. Det handler om å være sterkere sammen."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 2: Press Og Belastning
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Press Og Belastning',
    'Forstå hva som tærer på folk i bransjen, og hvordan du kan kjenne igjen belastning hos deg selv og andre. Ikke stressmestring - men realitetssjekk.',
    'press-og-belastning',
    TRUE,
    NULL,
    'construction_worker'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'press-og-belastning');

-- Course 2 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'press-og-belastning')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Hva Tærer', 'Kartlegg de typiske belastningene i bransjen - det du og kollegene står i.', 1),
    ('Signaler Hos Deg Selv', 'Lær å kjenne igjen tegnene på at du nærmer deg grensen.', 2),
    ('Signaler Hos Andre', 'Bli bedre til å se når kollegene dine ikke har det bra.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 2, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'press-og-belastning' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Bransjens Belastninger', 
     '## Hva Folk Står I

Dette er ikke klaging. Det er kartlegging.

### Typiske Belastninger

**Fysiske:**
- Lang arbeidstid
- Tungt arbeid
- Slitasje på kroppen
- Værforhold
- Pendling

**Mentale:**
- Tidsfrister
- Kvalitetskrav
- Ansvar
- Koordinering
- Beslutninger under press

**Økonomiske:**
- Usikkerhet
- Akkordpress
- Uforutsigbarhet
- Familieøkonomi

**Relasjonelle:**
- Lite tid hjemme
- Konflikter på jobb
- Vanskelige kunder
- Teamdynamikk

### Normalt, Men Krevende
Alt dette er normalt i bransjen. Men det betyr ikke at det ikke tar på.

> "Å anerkjenne belastning er første steg til å håndtere den."', 
     1, 12),
    
    ('Når Det Hoper Seg Opp', 
     '## Stakkeffekten

En belastning håndterer du. Flere samtidig blir tungt.

### Typisk Stabling
- Stram tidsfrist PÅ JOBBEN
- Samtidig som: konflikt med kollega
- Samtidig som: dårlig økonomi
- Samtidig som: lite søvn
- Samtidig som: vondt i ryggen

Hver for seg: håndterbart.
Sammen: overbelastning.

### Advarselstegn
- Du blir mer sliten enn før
- Ting som pleide å være lett, føles tungt
- Terskelen for irritasjon synker
- Du orker mindre sosialt

### Ikke La Det Vare
Jo lenger det pågår, jo tyngre blir det å komme tilbake.

> "Belastning som ignoreres, forsvinner ikke. Den vokser."', 
     2, 12),
    
    ('Menn Og Belastning', 
     '## Statistikken Lyver Ikke

Menn:
- Går sjeldnere til lege
- Snakker mindre om at de sliter
- Venter lenger før de søker hjelp
- Har høyere risiko for alvorlige konsekvenser

### Hvorfor?
- "Jeg skal klare meg selv"
- "Andre har det verre"
- "Det går over"
- "Svakhet å innrømme det"

### Realiteten
Å vente for lenge gjør problemene større, ikke mindre.

### Ny Tenkning
Å be om hjelp tidlig er ikke svakhet - det er effektivitet. Du kommer raskere tilbake.

> "De tøffeste er de som ber om hjelp før det blir krise."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 2, Module 2 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'press-og-belastning' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Kjenne Igjen Hos Deg Selv', 
     '## Dine Egne Signaler

Alle har ulike signaler på at de nærmer seg grensen.

### Fysiske Tegn
- Dårlig søvn
- Konstant sliten
- Spenninger i kroppen
- Hodepine
- Mageproblemer

### Mentale Tegn
- Vanskelig å konsentrere seg
- Negativ tankegang
- Bekymring som ikke slipper
- Følelse av å ikke strekke til

### Atferdsmessige Tegn
- Snapper lettere
- Trekker deg fra folk
- Økt alkohol/snacks/skjerm
- Slurver med ting du pleier å gjøre bra

### Kartlegging
Hvilke signaler kjenner DU først på kroppen når det blir for mye?

> "Å kjenne dine egne varselsignaler er førstelinje forsvar."', 
     1, 12),
    
    ('Tidligvarsling', 
     '## Fange Det Tidlig

Jo tidligere du kjenner igjen signalene, jo lettere er det å snu.

### Din Personlige Alarm
Tenk tilbake på en periode da du hadde det tøft:
- Hva var det første tegnet?
- Når skjønte du at det var for mye?
- Hva skulle du ønske du hadde gjort tidligere?

### Lag Ditt System
Definer for deg selv:
1. **Gult lys**: Første tegn - øk oppmerksomheten
2. **Rødt lys**: Alvorlig - gjør noe NÅ

### Eksempel
- **Gult**: Dårlig søvn 3 netter på rad → snakk med noen
- **Rødt**: Konstant irritert, unngår alle → be om hjelp

> "Et godt varselsystem redder deg fra unødvendige kriser."', 
     2, 12),
    
    ('Gjøre Noe Med Det', 
     '## Handling Er Alt

Å kjenne signalene hjelper ikke hvis du ikke gjør noe.

### Første Steg (lav terskel)
- Si det til noen: partner, kollega, venn
- Senk tempoet litt
- Prioriter søvn
- Gjør noe som lader deg

### Hvis Det Er Mer Alvorlig
- Snakk med leder om arbeidsbelastning
- Ta kontakt med bedriftshelsetjeneste
- Book time hos fastlege
- Ikke vent til det blir kritisk

### Barrierene
- "Har ikke tid"
- "Det går over"
- "Vil ikke være til bry"

Alle disse er feil. Det er billigere å ta tak tidlig.

> "Å gjøre noe når du kjenner signalene er ikke svakhet. Det er styrke."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 2, Module 3 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'press-og-belastning' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Se Kollegaene Dine', 
     '## Signaler Hos Andre

Du trenger ikke være psykolog for å se at noen ikke har det bra.

### Endringer Å Se Etter

**I Atferd:**
- Mer stille enn vanlig
- Mer irritabel enn vanlig
- Trekker seg fra pauser/lunsj
- Flere feil enn normalt

**I Utseende:**
- Sliten, blek
- Mindre stelt enn vanlig
- Ser ikke ut til å sove

**I Kommunikasjon:**
- Kortere svar
- Mer negativ
- Mindre engasjert
- Unngår blikk

### Viktig
Du trenger ikke vite HVA som er galt for å SE AT noe er galt.

> "Du ser oftere enn du tror. Spørsmålet er om du handler på det."', 
     1, 12),
    
    ('Forskjell På Dag Og Mønster', 
     '## En Dårlig Dag Vs. Noe Mer

Alle har dårlige dager. Det er normalt.

### En Dårlig Dag
- Kortvarig
- Går over
- Spesifikk årsak (ofte kjent)
- Tilbake til normal snart

### Et Mønster
- Flere dager/uker
- Blir verre, ikke bedre
- Uklar eller ukjent årsak
- Påvirker flere områder

### Når Handle
- Ved mønster: Definitivt
- Ved alvorlige signaler: Med en gang
- Ved usikkerhet: Heller en gang for mye enn for lite

### Husk
Du trenger ikke være sikker for å spørre. Å spørre er aldri feil.

> "Bedre å spørre og ta feil enn å la være og angre."', 
     2, 10),
    
    ('Handle På Det Du Ser', 
     '## Fra Observasjon Til Handling

Du har sett noe. Hva gjør du?

### Steg 1: Bestem Deg For Å Handle
Ikke la det gli. Sett en tid for deg selv: "I dag spør jeg."

### Steg 2: Finn Anledningen
- Alene, ikke foran andre
- Uformelt fungerer ofte best
- I bilen, på pause, etter jobb

### Steg 3: Hold Det Enkelt
- "Hei, alt bra med deg? Virker som noe er på gang."
- "Bare så du vet det - jeg ser at du kanskje har det litt tøft."

### Steg 4: Lytt
- Ikke ha løsninger klare
- Ikke sammenlign med egne problemer
- Bare vær der

### Steg 5: Følg Opp
- Sjekk inn igjen senere
- Hold det du lover
- Ikke glem det

> "Det du gjør med det du ser, definerer hva slags kollega du er."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 3: Å Be Om Hjelp
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Å Be Om Hjelp',
    'Hvorfor er det så vanskelig å be om hjelp? Og hvordan kan du gjøre det på en måte som føles OK? Dette kurset handler om å ta ansvar - for deg selv.',
    'a-be-om-hjelp',
    TRUE,
    NULL,
    'construction_worker'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'a-be-om-hjelp');

-- Course 3 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'a-be-om-hjelp')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Hvorfor Det Er Vanskelig', 'Forstå hva som holder deg tilbake fra å be om hjelp.', 1),
    ('Hvordan Gjøre Det', 'Praktiske måter å be om hjelp på som føles håndterbart.', 2),
    ('Ressurser Og Veier Videre', 'Hvem kan hjelpe, og hvordan kommer du i kontakt.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 3, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'a-be-om-hjelp' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Barrierene I Hodet', 
     '## Hvorfor Vi Ikke Ber Om Hjelp

Det er mange grunner til at menn spesielt venter for lenge.

### Vanlige Tanker
- "Jeg skal klare meg selv"
- "Andre har det verre"
- "Det går sikkert over"
- "Vil ikke være til bry"
- "Folk vil tenke at jeg er svak"

### Hvor Kommer De Fra?
- Oppdragelse: "Tøffe gutter gråter ikke"
- Kultur: Selvstendighetsnormer
- Frykt: For å bli dømt
- Erfaring: Tidligere dårlige opplevelser

### Kostnaden
- Problemene vokser
- Tar lenger tid å komme tilbake
- Påvirker jobb og relasjoner
- I verste fall: alvorlige konsekvenser

> "Tankene som holder deg fra hjelp, er ofte de som gjør problemene verre."', 
     1, 12),
    
    ('Myten Om Svakhet', 
     '## Å Be Om Hjelp Er Ikke Svakhet

La oss ta en realitetssjekk.

### Hva Krever Mest Mot?
- Lide i stillhet og håpe det går over?
- Eller innrømme at du trenger hjelp og ta grep?

### De Sterkeste
De sterkeste folkene du kjenner, har sannsynligvis bedt om hjelp på et tidspunkt. De snakker bare ikke om det.

### Profesjonelle Gjør Det
- Idrettsutøvere har mentaltrener
- Ledere har coach
- Alle bruker hjelpeapparat når de trenger det

### Ny Definisjon
Styrke = Ta ansvar for å holde deg selv i form
Svakhet = La problemene vokse til de blir uhåndterlige

> "Å be om hjelp er ikke å gi opp. Det er å ta ansvar."', 
     2, 12),
    
    ('Hva Skjer Egentlig', 
     '## Frykten Vs Virkeligheten

Ofte er frykten for å be om hjelp verre enn selve opplevelsen.

### Frykten
- "De vil synes jeg er patetisk"
- "Det blir kleint etterpå"
- "De kan ikke hjelpe uansett"
- "Jeg må fortelle alt"

### Virkeligheten (som regel)
- Folk vil hjelpe
- Det er mindre dramatisk enn du tror
- Du bestemmer hvor mye du deler
- Lettelse etterpå

### Hva De Virkelig Tenker
De fleste tenker: "Modig at han/hun sa noe."

De færreste tenker: "For en taper."

> "Frykten for å be om hjelp er nesten alltid større enn konsekvensen."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 3, Module 2 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'a-be-om-hjelp' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Start Smått', 
     '## Lavterskel Først

Du trenger ikke starte med å fortelle alt til alle.

### Trinn For Trinn

**Nivå 1: Hint**
"Har vært litt tunge tider."
Gir deg en respons å jobbe med.

**Nivå 2: Åpning**
"Jeg sliter litt for tiden, faktisk."
Mer konkret, inviterer til oppfølging.

**Nivå 3: Direkte**
"Jeg trenger å snakke med noen om noe."
Tydelig forespørsel.

### Hvem Å Starte Med
- En du stoler på
- En som ikke dømmer
- Kan være partner, venn, kollega

### Husk
Du bestemmer tempoet. Du bestemmer hvor mye du deler.

> "Start der det føles trygt. Du kan utvide derfra."', 
     1, 12),
    
    ('Hvordan Si Det', 
     '## Konkrete Formuleringer

Noen ganger er det lettere når du har ordene klare.

### Til En Kollega
- "Hei, kan jeg snakke med deg om noe?"
- "Jeg har det litt tøft for tiden. Trenger å lufte litt."

### Til Partneren
- "Jeg trenger å fortelle deg noe."
- "Jeg sliter med noe og trenger at du bare lytter."

### Til Legen
- "Jeg føler meg ikke som meg selv."
- "Jeg har slitt en stund og trenger hjelp."
- "Jeg har problemer med [søvn/humør/energi]."

### Til Bedriftshelsetjenesten
- "Jeg lurer på om jeg kan snakke med noen."
- "Jeg har noen utfordringer jeg ikke får til å løse selv."

> "Det finnes ingen perfekt måte å si det på. Det viktigste er at du sier noe."', 
     2, 12),
    
    ('Hva Du Kan Forvente', 
     '## Etter At Du Har Sagt Noe

Det er normalt å lure på hva som skjer etterpå.

### Vanlige Utfall

**Lettelse:**
De fleste opplever lettelse - bare det å si det høyt hjelper.

**Støtte:**
Folk vil ofte hjelpe mer enn du forventer.

**Praktisk Hjelp:**
Du får ofte konkrete forslag til veien videre.

### Mindre Vanlige Utfall

**Dårlig Respons:**
Noen få reagerer dårlig. Det sier mer om dem enn deg.

**Ubehjelpelig:**
Personen vet ikke hva de skal si. Be dem bare lytte.

### Uansett
Du har tatt et steg. Det er modighet. Og det er starten på endring.

> "Det verste er sjelden det som skjer. Det verste er å ikke prøve."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 3, Module 3 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'a-be-om-hjelp' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hvem Kan Hjelpe', 
     '## Dine Alternativer

Det finnes mange veier til hjelp. Velg den som passer deg.

### Uformelle Ressurser
- **Partner/familie**: De som kjenner deg best
- **Venner**: Noen å snakke med
- **Kolleger**: De som forstår jobbsituasjonen

### Arbeidsplassressurser
- **Leder**: Kan tilpasse arbeidssituasjon
- **Verneombud**: Kan støtte og veilede
- **Bedriftshelsetjeneste**: Profesjonell, konfidensiell hjelp
- **HR**: Kan formidle kontakt

### Profesjonelle
- **Fastlege**: Første steg til behandling
- **Psykolog**: Samtaleterapi
- **Mental Helses hjelpetelefon**: 116 123
- **Kirkens SOS**: 22 40 00 40

### Akutt?
Ved krise: Ring 113 eller oppsøk legevakt.

> "Det finnes alltid noen som kan hjelpe. Du må bare finne riktig dør."', 
     1, 12),
    
    ('Bedriftshelsetjenesten', 
     '## En Undervurdert Ressurs

Mange vet ikke hva bedriftshelsetjenesten (BHT) kan hjelpe med.

### Hva BHT Tilbyr
- Samtaler om psykisk helse
- Hjelp med arbeidsrelatert stress
- Veiledning til andre ressurser
- Konfidensielle tjenester

### Hvorfor Bruke BHT
- Gratis (betalt av arbeidsgiver)
- Forstår arbeidssituasjonen
- Kan hjelpe med tilpasninger
- Konfidensielt (med noen unntak)

### Hvordan Kontakte
- Via HR eller leder
- Direkte kontakt (informasjon på intranettet)
- Be om en uforpliktende samtale først

### Myter
- "De sladrer til ledelsen" → Nei, de har taushetsplikt
- "Det er bare for fysiske ting" → Nei, psykisk helse er like viktig
- "Det er for alvorlige tilfeller" → Nei, alle kan bruke det

> "BHT er der for deg - og det er gratis. Bruk det."', 
     2, 12),
    
    ('Ta Det Første Steget', 
     '## Handling I Dag

Kunnskap uten handling hjelper ikke.

### Din Oppgave
Hvis du kjenner deg igjen i dette kurset:

**I Dag:**
- Bestem deg for hvem du kan snakke med
- Finn kontaktinfo til BHT eller fastlege

**Denne Uken:**
- Ta kontakt med én person
- Si at du trenger å snakke

**Hvis Det Haster:**
- Ring noen nå
- Eller 116 123 (Mental Helses hjelpetelefon)

### For Fremtiden
- Ha en plan for hvem du ringer hvis det blir tøft
- Ikke vent til krise
- Jo tidligere, jo lettere

### Avslutning
Å be om hjelp er ikke å gi opp. Det er å ta ansvar for deg selv.

> "Det viktigste steget er det første. Ta det i dag."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Link mental health courses to Håndverkere category
WITH cat AS (SELECT id FROM categories WHERE name = 'Håndverkere')
UPDATE courses SET category_id = cat.id
FROM cat
WHERE courses.slug IN ('guttastemning-2-0', 'press-og-belastning', 'a-be-om-hjelp')
AND courses.category_id IS NULL;

-- End of migration
