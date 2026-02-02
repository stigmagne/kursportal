-- Migration: 075_construction_worker_courses.sql
-- Purpose: Create category and 3 courses for construction workers (håndverkere)
-- Based on workshop "Fra stille feil til smart kvalitet"
-- Content in Bokmål

-- =====================================================
-- CATEGORY: Håndverkere
-- =====================================================
INSERT INTO categories (name, description, color)
VALUES ('Håndverkere', 'Kurs for fagarbeidere i byggebransjen - kvalitet, trygghet og feilforebygging', '#F97316')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- COURSE 1: Si Fra Før Det Blir Dyrt
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Si Fra Før Det Blir Dyrt',
    'Lær å stoppe feil tidlig - før de blir reklamasjoner. Dette kurset gir deg verktøy for å si fra når du ser at noe ikke stemmer, selv under tidspress.',
    'si-fra-for-det-blir-dyrt',
    TRUE,
    NULL,
    'construction_worker'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'si-fra-for-det-blir-dyrt');

-- Course 1 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'si-fra-for-det-blir-dyrt')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Beslutningsøyeblikket', 'Når du ser at noe ikke stemmer - hva skjer i hodet, og hvorfor fortsetter vi ofte likevel?', 1),
    ('Trygghet Er Kvalitet', 'Forstå sammenhengen mellom psykologisk trygghet og kvalitet i arbeidet.', 2),
    ('Ta Det Opp', 'Praktiske teknikker for å si fra til bas, leder eller kolleger på en effektiv måte.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 1, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'si-fra-for-det-blir-dyrt' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Når Du Ser At Noe Ikke Stemmer', 
     '## Øyeblikket Av Tvil

Du kjenner det igjen: Noe ser ikke helt riktig ut. En løsning som ikke stemmer. En tegning som ikke matcher virkeligheten.

### Typisk Situasjon
- Tidsplanen er presset
- Kunden eller byggherre er til stede
- Basen er opptatt med noe annet
- Du vurderer å ringe, men...
- Du gjør ferdig jobben

To uker senere kommer reklamasjonen.

### Gjenkjennelse
Hvem har vært i lignende situasjon? De fleste har det. Du er ikke alene.

### Spørsmål Til Refleksjon
- Når var sist du så noe som ikke stemte?
- Hva gjorde du?
- Hva skulle du ønske du hadde gjort?

> "Øyeblikket av tvil er gull verdt - hvis du handler på det."', 
     1, 10),
    
    ('Hvorfor Vi Fortsetter Likevel', 
     '## Barrierene I Hodet

Det er sjelden slurv eller latskap som gjør at feil får utvikle seg. Det er ofte helt forståelige grunner.

### Vanlige Barrierer

**Tid:**
- "Vi ligger allerede bak"
- "Tar det etterpå"
- "Har ikke tid til å vente på svar"

**Hierarki:**
- "Det er ikke min plass å si fra"
- "Basen bestemmer"
- "De andre vet sikkert bedre"

**Stolthet:**
- "Jeg burde klare dette selv"
- "Dumt å spørre om noe så enkelt"
- "Vil ikke virke usikker"

### Viktig Innsikt
Dette handler ikke om personlighet. Det handler om hvilke signaler systemet rundt deg sender.

> "Barrierene er ofte usynlige - men konsekvensene er høyst synlige."', 
     2, 12),
    
    ('Konsekvensene Av Å Vente', 
     '## Fra Liten Tvil Til Stor Reklamasjon

Feil har en livssyklus. Jo lenger du venter, jo dyrere blir det.

### Feilens Faser

1. **Første tegn**: Du kjenner at noe ikke stemmer
2. **Mulighetsvindu**: Kan fikses enkelt og billig
3. **Låsing**: Arbeidet er dekket eller ferdigstilt
4. **Oppdagelse**: Kunden eller neste fag finner feilen
5. **Reklamasjon**: Kostnad, tid, omdømme

### Eksempel: Feil Fall På Bad
- **Fase 1-2**: Rettes på 30 min, 0 kr ekstra
- **Fase 3**: Må rive membran, ny støp - 8 timer
- **Fase 4-5**: Vannlekkasje, skade på underliggende - mange tusen

### Hovedpoeng
De fleste feil starter ikke som grove tabber. De starter som små ting ingen tør eller rekker å ta tak i.

> "Prisen på å stoppe tidlig er alltid lavere enn prisen på å vente."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 1, Module 2 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'si-fra-for-det-blir-dyrt' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hva Er Psykologisk Trygghet?', 
     '## Trygghet I Praksis

Psykologisk trygghet betyr at det føles trygt å si:
- "Jeg er usikker"
- "Kan vi dobbeltsjekke?"
- "Dette ser rart ut"

### Hvorfor Det Betyr Noe
I praksis er dette kvalitetssikring i sanntid. Når folk tør å si fra, stoppes feil tidligere.

### Tegn På Trygghet
- Folk spør uten å føle seg dumme
- Usikkerhet deles åpent
- Feil diskuteres uten skyldfølelse
- Alle stemmer blir hørt

### Tegn På Utrygghet
- Folk tier heller enn å spørre
- Feil skjules eller bagatelliseres
- Kun sjefen snakker
- Kritikk møtes med forsvar

> "Psykologisk trygghet er ikke om å være snill. Det er om å være smart."', 
     1, 12),
    
    ('Trygghet Som Kvalitetssikring', 
     '## Sammenhengen

Forskning viser tydelig: Team med høy psykologisk trygghet har færre feil og bedre resultater.

### Hvorfor?
- Feil fanges tidligere
- Informasjon deles raskere
- Problemer løses i fellesskap
- Ingen sitter på bekymringer alene

### I Byggebransjen
- Dobbeltsjekk før støp/lukking
- Avklaringer FØR utførelse
- Spørsmål til prosjektering
- Stopp-og-sjekk mellom fag

### Din Rolle
Du trenger ikke være leder for å bidra til trygghet. Hvordan du svarer når kolleger spør, betyr mye.

> "Hver gang du spør eller sier fra, gjør du det lettere for neste person å gjøre det samme."', 
     2, 12),
    
    ('Signalene Systemet Sender', 
     '## Hva Gjør Det Trygt Eller Utrygt?

Trygghet skapes ikke av fine ord på veggen. Den skapes i små øyeblikk hver dag.

### Hva Gjør Det TRYGT?
- Ledere som innrømmer egne feil
- Takk for at du sa fra
- Tid satt av til avklaringer
- Fokus på løsning, ikke skyld

### Hva Gjør Det UTRYGT?
- Øyerulling når noen spør
- "Det burde du vite"
- Aldri nok tid til spørsmål
- Fokus på hvem som har skylden

### Refleksjon
- Hvordan er det på din arbeidsplass?
- Hva gjør det lett eller vanskelig å si fra?
- Hva skulle du ønske var annerledes?

> "Kulturen formes av det som skjer når noen faktisk sier fra."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 1, Module 3 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'si-fra-for-det-blir-dyrt' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Når Og Hvordan Si Fra', 
     '## Praktiske Teknikker

Det er ikke nok å vite at du bør si fra. Du må vite hvordan.

### Timing
**Haster:**
- Sikkerhetsproblemer - STOPP med en gang
- Feil som snart låses (støp, lukking)
- Manglende underlag for å fortsette

**Kan vente litt:**
- Generelle bekymringer
- Forbedringsforslag
- Ting som bør diskuteres i gruppen

### Hvordan Formulere

**Unngå:**
- "Dere gjør feil" (anklage)
- "Dette er helt galt" (drama)
- "Burde ikke noen ha sjekket?" (passivt)

**Bruk:**
- "Jeg lurer på om..." (nysgjerrig)
- "Kan vi dobbeltsjekke..." (konstruktivt)
- "Stemmer dette med tegningen?" (konkret)

> "Målet er å løse problemet, ikke å ha rett."', 
     1, 12),
    
    ('Snakke Med Basen', 
     '## Når Sjefen Er Travel

Basen har mye å gjøre. Det betyr ikke at du ikke kan si fra.

### Forbered Deg
- Vær konkret: Hva er problemet?
- Ha et forslag: Hva tror du bør gjøres?
- Velg riktig øyeblikk: Ikke midt i en krise

### Formulering
"Hei [navn], jeg ser noe jeg lurer på. Kan du se på dette når du har 2 minutter?"

### Hvis Du Ikke Får Respons
- Følg opp skriftlig (SMS, melding)
- Dokumenter at du sa fra
- Ikke gjør ferdig tvilsom utførelse uten avklaring

### Viktig
Det er bedre å mase litt og få avklaring enn å gjøre noe du vet kan bli feil.

> "En god bas setter pris på at du sier fra. Selv om det tar litt tid akkurat da."', 
     2, 12),
    
    ('Etter At Du Sa Fra', 
     '## Hva Skjer Så?

Du har sagt fra. Bra! Men hva nå?

### Mulige Utfall

**Du fikk rett:**
- Feilen ble stoppet - flott!
- Deler erfaringen med teamet
- Byggekloss for neste gang

**Det var ikke en feil:**
- Også bra - nå vet du
- Ingen skam i å sjekke
- Bedre å spørre en gang for mye

**Ingen lyttet:**
- Dokumenter at du sa fra (SMS, mail, notat)
- Du kan ikke tvinges til å utføre noe du vet er feil
- Eskaler om nødvendig

### Bygg Vane
Jo oftere du sier fra, jo lettere blir det. Og jo mer normalt blir det i teamet.

> "Å si fra er en ferdighet. Som alle ferdigheter blir den bedre med øvelse."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 2: Feilreisen
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Feilreisen',
    'Forstå hvordan små usikkerheter utvikler seg til dyre reklamasjoner. Lær å gjenkjenne mønstrene og stoppe feilen i tide.',
    'feilreisen',
    TRUE,
    NULL,
    'construction_worker'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'feilreisen');

-- Course 2 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'feilreisen')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Feilens Livssyklus', 'Fra første tegn til låst feil - forstå hvordan feil utvikler seg over tid.', 1),
    ('Stopp Før Det Låser Seg', 'Identifiser vinduene der feil kan stoppes enkelt og billig.', 2),
    ('Lære Av Nesten-Feil', 'Bruk nesten-feil som verdifull læring for å forebygge fremtidige problemer.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 2, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'feilreisen' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Fra Tegn Til Feil', 
     '## Feilens Tidslinje

Alle feil har en historie. De oppstår ikke plutselig.

### Den Typiske Tidslinjen

**1. Første Tegn**
Du kjenner at noe er rart. En detalj som ikke stemmer. En tegning som er utydelig.

**2. Usikkerhet**
Du vurderer å si fra, men kanskje ikke...

**3. Utførelse**
Du gjør jobben ferdig - med tvilen i bakhodet.

**4. Låsing**
Arbeidet dekkes av neste lag, veggen lukkes, støpen herdes.

**5. Oppdagelse**
Noen finner feilen - ofte for sent.

**6. Kostnad**
Reklamasjon, riving, omarbeid, frustrasjon.

### Hovedinnsikt
Feilen var stoppbar i fase 1-3. I fase 4-6 er det skadebegrensning.

> "Jo tidligere på tidslinjen, jo billigere å stoppe."', 
     1, 12),
    
    ('Når Feil Blir Dyre', 
     '## Kostnadskurven

Prisen på en feil stiger eksponentielt med tid.

### Eksempel: Feil Plassering Av Utsparinger

| Fase | Kostnad |
|------|---------|
| Før støp | 0 kr (flytter forskalingen) |
| Rett etter støp | 2.000 kr (hugge opp) |
| Etter lukking | 15.000 kr (åpne, hugge, tette) |
| Etter overlevering | 50.000+ kr (garanti, reise, admin) |

### Hvorfor Så Stor Forskjell?
- Må åpne opp ferdig arbeid
- Koordinere flere fag
- Dokumentasjon og møter
- Kundefrustrasjon og omdømme

### Forsikring Hjelper Ikke
Ansvarsforsikring dekker skade på andre. Den dekker IKKE kostnaden ved å rette eget arbeid.

> "Reklamasjoner betales av bedriftens margin - ikke av forsikringen."', 
     2, 12),
    
    ('Typiske Mønstre', 
     '## Hva Går Igjen?

Når vi analyserer reklamasjoner, ser vi ofte de samme mønstrene.

### Vanlige Rotårsaker

**Kommunikasjon:**
- Uklare tegninger ingen spurte om
- Beskjeder som ikke nådde frem
- Antakelser i stedet for avklaringer

**Tidspress:**
- Tok snarveien fordi det hastet
- Droppet dobbeltsjekk pga. tempo
- Prioriterte fart over kvalitet

**Grensesnitt:**
- Uklart hvem som hadde ansvar
- Ingen sjekket overgangen mellom fag
- Antok at den andre hadde kontroll

### Refleksjon
- Kjenner du igjen noen av disse?
- Hva kunne vært gjort annerledes?
- Hvor svikter det oftest hos dere?

> "Feil kommer sjelden fra slurv. De kommer fra systemer som ikke fanger opp usikkerhet."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 2, Module 2 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'feilreisen' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Vinduene For Stopp', 
     '## Hvor Kan Feil Fanges?

Det finnes naturlige punkter i prosessen der feil kan stoppes billig.

### Vindu 1: Før Jobbstart
- Gjennomgang av tegninger
- Avklaringer med prosjektering
- Koordinering mellom fag

### Vindu 2: Under Utførelse
- Stopp ved usikkerhet
- Dobbeltsjekk kritiske mål
- Spørre heller enn anta

### Vindu 3: Før Lukking
- Sjekkliste før støp
- Foto-dokumentasjon
- Kontroll på tvers av fag

### Vindu 4: Ved Overlevering
- Sluttsjekk
- Egenkontroll
- Kundens gjennomgang

> "Hvert vindu du bruker aktivt, reduserer risikoen for at feilen når neste fase."', 
     1, 12),
    
    ('Dobbeltsjekk Uten Tapt Tempo', 
     '## Kvalitet Og Effektivitet

Mange tror kvalitetskontroll tar for mye tid. Det trenger det ikke.

### Raske Sjekker Som Virker

**2-minutterssjekken:**
Før du starter: Ser dette riktig ut? Har jeg det jeg trenger?

**Stopp-og-pek:**
Pek fysisk på kritiske punkter og si høyt hva de skal være.

**Kollega-blikk:**
15 sekunder fra en kollega: Ser du noe jeg ikke ser?

### Tid Spart
En 2-minutters sjekk som fanger en feil sparer:
- Timer i omarbeid
- Dager i reklamasjonsbehandling
- Kroner i materiell og lønn

### Kultur For Sjekk
Når alle gjør det, blir det normalt. Ingen føler seg pirkete.

> "Å sjekke er ikke å tvile på deg selv. Det er å være profesjonell."', 
     2, 12),
    
    ('Samarbeid På Tvers', 
     '## Grensesnittene Er Farlige

De fleste feil skjer i overgangene mellom fag og faser.

### Kritiske Grensesnitt
- Rør møter vegg
- Elektriker etter tømrer
- Maler etter murer
- Utførende møter prosjektering

### Hvordan Sikre Overganger

**Før du starter:**
Er underlaget fra forrige fag OK?

**Under arbeid:**
Kommer mitt arbeid til å skape problemer for neste?

**Før du går:**
Har jeg overlatt dette slik at neste kan bygge videre?

### Kommunikasjon
En kort samtale mellom fag kan spare enorme summer:
"Hei, jeg legger rørene her. Funker det for deg?"

> "Ingen eier grensesnittene, men alle kan passe på dem."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 2, Module 3 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'feilreisen' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Nesten-Feil Er Gull', 
     '## Læring Uten Smerte

En nesten-feil er en feil som ble stoppet i tide. Den er uvurderlig.

### Hvorfor Nesten-Feil Er Viktige
- Viser hvor systemet nesten sviktet
- Ingen kostnad å lære av
- Avdekker mønstre
- Bygger forebyggende kultur

### Typiske Nesten-Feil
- "Akkurat da jeg skulle støpe, så jeg at..."
- "Heldigvis spurte jeg før jeg..."
- "Vi oppdaget det rett før lukking..."

### Problemet
De fleste nesten-feil deles aldri. De føles ikke viktige nok.

> "En nesten-feil forteller deg akkurat hvor systemet er sårbart."', 
     1, 10),
    
    ('Dele Erfaringer Trygt', 
     '## Hvordan Lære Som Team

For at nesten-feil skal bli læring, må de deles.

### Barrierer Mot Deling
- "Det var jo ikke en feil"
- "Vil ikke virke dum"
- "Ingen bryr seg"
- "Har ikke tid til slikt"

### Trygg Deling

**Anonymitet ved behov:**
Kan dele hendelser uten navn på hvem.

**Fokus på system, ikke person:**
"Dette kunne skjedd hvem som helst"

**Ledelse går foran:**
Når sjefen deler sine nesten-feil, blir det tryggere for andre.

### Format For Deling
- Korte standup om morgenen
- Ukentlig "hva lærte vi"-runde
- Enkel logg over nesten-feil

> "Deling uten skyld er nøkkelen til kollektiv læring."', 
     2, 12),
    
    ('Fra Hendelse Til Forbedring', 
     '## Bruke Læringen

Det er ikke nok å snakke om nesten-feil. De må føre til endring.

### Fra Hendelse Til Tiltak

1. **Hva skjedde?** (Fakta, ikke skyld)
2. **Hvorfor nesten-feil?** (Rotårsak)
3. **Hva stoppet det?** (Hva fungerte)
4. **Hva kan endres?** (Konkret tiltak)

### Eksempel
- **Hendelse:** Nesten støpt med feil armering
- **Hvorfor:** Tegning var utdatert
- **Stoppet av:** Kollega som spurte
- **Tiltak:** Alltid sjekke revisjonsdato

### Oppfølging
Tiltak uten oppfølging er bortkastet. Sjekk at endringen faktisk skjer.

> "En nesten-feil uten læring er bare flaks. Med læring er det investering."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 3: Stolthet Og Kvalitet
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Stolthet Og Kvalitet',
    'Utforsk hvordan fagstolthet kan både hindre og fremme kvalitet. Lær å bruke stoltheten som drivkraft for å levere riktig - første gang.',
    'stolthet-og-kvalitet',
    TRUE,
    NULL,
    'construction_worker'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'stolthet-og-kvalitet');

-- Course 3 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'stolthet-og-kvalitet')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Fagstolthetens To Sider', 'Forstå hvordan stolthet kan være både styrke og blindsone.', 1),
    ('Kvalitet Som Merkevare', 'Bygg din signatur på yrkesstolthet og førsteklasses utførelse.', 2),
    ('Teamet Som Sikkerhetsnett', 'Bruk kolleger som ressurs for bedre kvalitet.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 3, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'stolthet-og-kvalitet' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Når Stolthet Er Styrke', 
     '## Den Gode Stoltheten

Fagstolthet er en av de fineste egenskapene i håndverksyrker.

### Stolthet Som Drivkraft
- Du vil at jobben skal være bra
- Du setter din signatur på arbeidet
- Du tar ansvar for kvaliteten
- Du lærer og utvikler deg

### Tegn På Sunn Stolthet
- Glede over godt utført arbeid
- Vilje til å gjøre det riktig
- Ønske om å mestre faget
- Respekt for yrket

### Effekten
Stolte håndverkere leverer bedre kvalitet. Det er ingen tilfeldighet.

> "Fagstolthet er motoren i kvalitetsarbeid."', 
     1, 10),
    
    ('Når Stolthet Blir Blindsone', 
     '## Den Vanskelige Siden

Samme stolthet kan også hindre kvalitet.

### Stolthet Som Barriere

**"Jeg burde klare dette selv"**
- Spør ikke selv om du er usikker
- Prøver å løse alt alene
- Ser på spørsmål som svakhet

**"Jeg gjør ikke feil"**
- Vanskelig å innrømme tabber
- Forsvarer i stedet for å lære
- Skylder på andre

**"Jeg trenger ikke hjelp"**
- Avviser innspill fra kolleger
- Stoler blindt på egen vurdering
- Lytter ikke til advarsel

### Konsekvensen
Feil som kunne vært stoppet, får leve videre.

> "Den som tror de aldri gjør feil, gjør de dyreste feilene."', 
     2, 12),
    
    ('Styrken I Å Spørre', 
     '## Nytt Tankesett

Hva om det å spørre var et tegn på styrke, ikke svakhet?

### Perspektivskift

**Gammelt:**
Å spørre = usikker = dårlig fagmann

**Nytt:**
Å spørre = grundig = dyktig fagmann

### De Beste Spør
Erfarne fagfolk spør hele tiden. De vet at:
- Tegninger kan ha feil
- Situasjoner varierer
- Ingen kan alt
- Avklaring sparer tid

### Hvordan Reframe
Neste gang du lurer på noe, si til deg selv:
"Å sjekke dette er profesjonelt."

> "En fagmann som spør er en fagmann som leverer."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 3, Module 2 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'stolthet-og-kvalitet' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Din Signatur På Arbeidet', 
     '## Hver Jobb Er Et Visittkort

Alt du gjør bærer ditt navn - selv om ingen ser det akkurat nå.

### Usynlig, Men Varig
- Rørene bak veggen
- Kablene i taket
- Fundamentet under gulvet

Alt kan spores tilbake. Og noen ganger gjøres det.

### Spørsmålet
Hvis noen åpner denne veggen om 10 år, hva vil de tenke om den som gjorde jobben?

### Stolthet I Det Usynlige
- Gjør det riktig selv når ingen ser
- Tenk langsiktig, ikke bare ferdig-nå
- Din standard er din merkevare

> "Kvalitet er det du gjør når ingen ser på."', 
     1, 10),
    
    ('Langsiktig Rykte', 
     '## Bygge Omdømme Over Tid

I byggebransjen spres rykter - både gode og dårlige.

### Hva Folk Husker
- Den som alltid leverer
- Den som ofte må tilbake
- Den som man kan stole på
- Den som tar snarveier

### Karriereeffekt
Godt rykte = bedre jobber, bedre lag, bedre lønn over tid

Dårlig rykte = begrensede muligheter, mistillit, stress

### Bygge Godt Rykte
- Lever konsistent kvalitet
- Innrøm feil tidlig
- Hjelp kolleger
- Ta ansvar uten å skylde på andre

> "Omdømmet ditt bygges jobb for jobb, dag for dag."', 
     2, 12),
    
    ('Stolthet I Å Levere Rett', 
     '## Første Gang Er Beste Gang

Den største stoltheten er å levere riktig første gang.

### Tre Nivåer Av Stolthet

**1. Stolt av å være ferdig**
OK, men lavt nivå.

**2. Stolt av at det ser bra ut**
Bedre, men ikke nok.

**3. Stolt av at det ER bra**
Beste nivå - funksjon, holdbarhet, kvalitet.

### Omarbeid Er Nederlag
Hver reklamasjon er et lite nederlag. Ikke fordi noen er sur, men fordi jobben ikke var god nok.

### Ny Standard
"Jeg er ferdig når det er riktig - ikke bare når jeg har gått hjem."

> "Ekte fagstolthet måles i null tilbakekallinger."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 3, Module 3 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'stolthet-og-kvalitet' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Ingen Klarer Alt Alene', 
     '## Teamets Kraft

Selv den beste håndverkeren trenger andre.

### Realiteten
- Prosjekter er komplekse
- Mange fag skal fungere sammen
- Endringer skjer kontinuerlig
- Ingen kan vite alt

### Myten Om Enmannshæren
Forestillingen om mesteren som klarer alt selv er en myte. Virkeligheten er at de beste jobber i lag.

### Hva Teamet Gir
- Flere øyne ser mer
- Ulike erfaringer supplerer
- Støtte når det røyner på
- Læring begge veier

> "Ingen bygger alene. Vi lykkes sammen eller mislykkes sammen."', 
     1, 10),
    
    ('Kollegaer Som Kvalitetskontroll', 
     '## Bruk Hverandre

Kolleger er den beste kvalitetskontrollen du har.

### Det Koster Ingenting
Et raskt blikk fra en kollega koster 30 sekunder. En feil kan koste dager.

### Hvordan Spørre
- "Kan du se på dette før jeg lukker?"
- "Ser dette riktig ut for deg?"
- "Er jeg på rett vei her?"

### Hvordan Svare
Når kolleger spør deg:
- Ta det seriøst
- Gi ærlig tilbakemelding
- Ikke kritiser - hjelp

### Begge Veier
Gi og ta. Når du hjelper andre, blir det lettere å be om hjelp selv.

> "Kollega-sjekk er gratis kvalitetskontroll."', 
     2, 12),
    
    ('Støtte Uten Dom', 
     '## Kultur For Kollegahjelp

Målet er et lag der alle løfter hverandre.

### Hva Det IKKE Handler Om
- Å peke på andres feil for å virke smart
- Å kritisere for å kritisere
- Å holde seg for god til å ta imot innspill

### Hva Det Handler Om
- Hjelpe hverandre levere bedre
- Fange feil før de koster
- Lære av hverandre
- Bygge et lag ingen vil forlate

### Start Med Deg Selv
- Innrøm egne feil
- Be om innspill aktivt
- Si takk når du får hjelp
- Gi hjelp uten å opptre overlegen

> "I de beste lagene er det trygt å gjøre feil - fordi alle hjelper."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Link courses to Håndverkere category
WITH cat AS (SELECT id FROM categories WHERE name = 'Håndverkere')
UPDATE courses SET category_id = cat.id
FROM cat
WHERE courses.slug IN ('si-fra-for-det-blir-dyrt', 'feilreisen', 'stolthet-og-kvalitet')
AND courses.category_id IS NULL;

-- End of migration
