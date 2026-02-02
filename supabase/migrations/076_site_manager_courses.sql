-- Migration: 076_site_manager_courses.sql
-- Purpose: Create 3 courses for site managers (bas/byggeleder)
-- Based on workshop "Fra stille feil til smart kvalitet"
-- Content in Bokmål

-- =====================================================
-- COURSE 4: Lederen Som Trygghetsskaper
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Lederen Som Trygghetsskaper',
    'Forstå hvordan dine svar og handlinger former kulturen på prosjektet. Lær å skape et miljø der folk tør å si fra - før feil blir dyre.',
    'lederen-som-trygghetsskaper-bygg',
    TRUE,
    NULL,
    'site_manager'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'lederen-som-trygghetsskaper-bygg');

-- Course 4 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'lederen-som-trygghetsskaper-bygg')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Mikroøyeblikkene', 'Forstå hvordan små handlinger og svar former kulturen daglig.', 1),
    ('Skape Rom For Usikkerhet', 'Praktiske rutiner for å la folk spørre og si fra.', 2),
    ('Håndtere Feil Konstruktivt', 'Når feil skjer - hvordan reagere for å lære, ikke straffe.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 4, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'lederen-som-trygghetsskaper-bygg' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Signaler Du Sender Uten Å Vite Det', 
     '## De Usynlige Beskjedene

Du kommuniserer hele tiden - også når du ikke snakker.

### Signaler Folk Leser
- Hvordan svarer du når noen spør?
- Hva gjør du når du er stresset?
- Hvem får tid og oppmerksomhet?
- Hvordan reagerer du på feil?

### Typiske Negative Signaler
- Sukk eller oppgitt blikk
- "Det burde du vite"
- Avbryte midt i samtale
- Løse problemet selv i stedet for å lytte

### Typiske Positive Signaler
- Legge ned det du holder på med
- "Bra at du spør"
- Følge opp med interesse
- "La oss se på dette sammen"

> "Folk hører ikke bare hva du sier. De leser hvordan du sier det."', 
     1, 12),
    
    ('Hvordan Du Svarer Når Noen Sier Fra', 
     '## Øyeblikket Av Sannhet

Når noen tar mot til seg og sier fra, er responsen din avgjørende.

### Scenario
En fagarbeider kommer til deg: "Jeg tror det er noe feil med tegningen her."

### Dårlig Respons
- "Vi har ikke tid til dette nå"
- "Bare gjør som det står"
- "Det skal du ikke bry deg om"

**Konsekvens:** Neste gang tier han.

### God Respons
- "Ok, vis meg hva du ser"
- "Bra at du sier fra"
- "La meg sjekke dette"

**Konsekvens:** Neste gang sier han fra igjen.

### Hovedregel
Belønn å si fra - alltid. Selv når det tar tid. Selv når det var falsk alarm.

> "Hvordan du håndterer én som sier fra, bestemmer om ti andre gjør det."', 
     2, 12),
    
    ('Tempo Vs Trygghet', 
     '## Når Alt Haster

Tidspress er noe av det som kveler trygghet raskest.

### Dilemmaet
- Du har frister
- Alt skal være ferdig i går
- Du trenger fart

MEN:
- Feil koster mer enn tid
- Omarbeid spiser margin
- Stress skaper flere feil

### Balansen
Du kan ha tempo OG trygghet, men det krever bevisst innsats.

### Praktiske Grep
- Ikke straffre avklaringer, selv om de tar tid
- Bygg inn stopp-punkter i planen
- Prioriter tydelig: "Dette haster, dette kan vente"
- Vis at kvalitet teller, ikke bare tempo

> "Raskeste vei til mål er ofte å stoppe og sjekke underveis."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 4, Module 2 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'lederen-som-trygghetsskaper-bygg' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Før Jobbstart', 
     '## Rutiner Som Forebygger

De beste feilene er de som aldri skjer.

### Før Jobbstart-Møte
Kort gjennomgang hver morgen (10 min):
- Hva gjør vi i dag?
- Noe uklart?
- Hvem trenger å snakke sammen?

### Oppfordre Til Spørsmål
Spør aktivt:
- "Er det noe dere lurer på?"
- "Noe som ser rart ut på tegningene?"
- "Trenger noen avklaring?"

### Senk Terskelen
Gjør det tydelig at spørsmål er ønsket - ikke bare tolerert.

> "Et 10-minutters morgenmøte kan spare 10 timer i omarbeid."', 
     1, 10),
    
    ('Under Arbeid', 
     '## Tilgjengelighet Og Respons

Hvordan du er tilgjengelig i løpet av dagen betyr alt.

### Vær Synlig
- Gå rundt på plassen
- Stopp og snakk
- Vær lett å finne

### Vær Tilgjengelig
- Svar på melding innen rimelig tid
- Ikke avvis spørsmål med "tar det senere"
- Prioriter avklaringer når de kommer

### Aktiv Oppfølging
- "Hvordan går det her?"
- "Noe du trenger?"
- "Alt greit med underlaget?"

### Ikke Vent På At Folk Kommer
Mange vil ikke forstyrre. Du må oppsøke dem.

> "En leder som går rundt, ser mer og blir lettere å spørre."', 
     2, 12),
    
    ('Etter Feil Og Nesten-Feil', 
     '## Når Noe Skjer

Hvordan du håndterer feil, definerer kulturen.

### Umiddelbar Respons
- Fokus på løsning, ikke skyld
- Finn fakta før du reagerer
- Hold deg rolig

### Evaluering Etterpå
- Hva skjedde? (Tidslinje)
- Hvorfor? (Rotårsak, ikke person)
- Hva kan endres? (System, ikke bare individ)

### Nesten-Feil
Når noe nesten gikk galt, men ble stoppet:
- Anerkjenn den som stoppet det
- Analyser hvorfor det nesten skjedde
- Del læringen med teamet

> "Feil som håndteres med læring bygger kultur. Feil som håndteres med skyld ødelegger den."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 4, Module 3 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'lederen-som-trygghetsskaper-bygg' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Fokus På Mønster, Ikke Person', 
     '## Systemtenkning

De fleste feil skjer ikke fordi noen er dumme eller late.

### Typiske Rotårsaker
- Uklare tegninger/beskrivelser
- Tidspress som presser snarveier
- Manglende kommunikasjon mellom fag
- Uklart ansvar
- Dårlig opplæring

### Hvordan Analysere
Spør "hvorfor" fem ganger:
1. Hvorfor ble det feil? (Feil mål)
2. Hvorfor feil mål? (Gammel tegning)
3. Hvorfor gammel tegning? (Ikke oppdatert)
4. Hvorfor ikke oppdatert? (Ingen rutine)
5. Hvorfor ingen rutine? (→ Her kan vi endre)

### Fokus Fremover
Ikke: "Hvem har skylden?"
Men: "Hvordan unngår vi dette igjen?"

> "Gi skylda til systemet, ikke personen. Så fikser du systemet."', 
     1, 12),
    
    ('Lære Som Team', 
     '## Kollektiv Forbedring

Når feil skjer ett sted, kan læringen hjelpe alle.

### Dele Uten Å Henge Ut
- Fokus på hendelsen, ikke personen
- "Det skjedde noe vi kan lære av"
- Gjør det trygt å være eksempel

### Forum For Læring
- Korte ukentlige oppsummeringer
- HMS-møter med fokus på kvalitet
- Prosjektmøter med læringspunkt

### Dokumenter Og Spres
- Enkle notater om hva som skjedde
- Tiltak som ble iverksatt
- Del med andre prosjekter

> "En feil på ett prosjekt trenger ikke gjentas på det neste."', 
     2, 12),
    
    ('Unngå Forsvar Og Skyldfølelse', 
     '## Når Folk Går I Forsvar

Kritikk utløser forsvar. Forsvar blokkerer læring.

### Tegn På Forsvarsmodus
- "Det var ikke min feil"
- "Noen andre burde ha..."
- "Jeg fikk beskjed om å..."
- Taushet og tilbaketrekning

### Hvordan Unngå
- Start med fakta, ikke anklager
- Anerkjenn at situasjonen var vanskelig
- Fokus på fremover
- Be om deres perspektiv først

### Eksempel

**Utløser forsvar:**
"Hvorfor sjekket du ikke tegningen?"

**Åpner for læring:**
"Hjelp meg forstå hva som skjedde. Hva så du?"

> "Folk som føler seg trygge, innrømmer feil. Folk i forsvar skjuler dem."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 5: Feil Koster - Ditt Ansvar
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Feil Koster - Ditt Ansvar',
    'Forstå økonomien bak reklamasjoner og hvorfor tidlig stopp er god business. Lær å måle det som faktisk betyr noe for kvalitet.',
    'feil-koster-ditt-ansvar',
    TRUE,
    NULL,
    'site_manager'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'feil-koster-ditt-ansvar');

-- Course 5 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'feil-koster-ditt-ansvar')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Hvem Betaler?', 'Forstå forskjellen på forsikring og egen kostnad ved feil.', 1),
    ('Tidlig Stopp = Spart Penger', 'Se sammenhengen mellom når feil stoppes og hva de koster.', 2),
    ('Måle Det Som Betyr Noe', 'Innfør målinger som faktisk forebygger, ikke bare teller skader.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 5, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'feil-koster-ditt-ansvar' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Myten Om Forsikringen', 
     '## "Vi Har Jo Forsikring"

En vanlig misforståelse er at forsikringen dekker feil.

### Hva Ansvarsforsikring Dekker
- Skade på person
- Skade på tredjeparts eiendom
- Følgeskader på andres ting

### Hva Den IKKE Dekker
- Kostnaden ved å rette eget arbeid
- Omarbeid på det du har levert
- Reklamasjoner på egen utførelse

### Eksempler
| Hendelse | Forsikring? |
|----------|-------------|
| Vannlekkasje skader naboens leilighet | ✅ Ja |
| Du må rive og gjøre om et bad | ❌ Nei |
| Feilmontert kjøkken må rettes | ❌ Nei |
| Mangelfullt arbeid reklameres | ❌ Nei |

> "Forsikringen beskytter mot uhell. Den beskytter ikke mot dårlig arbeid."', 
     1, 12),
    
    ('Hva Koster En Reklamasjon?', 
     '## Den Fulle Prislappen

Når du beregner kostnaden av en feil, må du ta med alt.

### Direkte Kostnader
- Timer til utbedring
- Materiell (ofte kastes det som rives)
- Reise til/fra (ofte flere ganger)
- Koordinering og ventetid

### Indirekte Kostnader
- Administrativ tid
- Møter og dokumentasjon
- Forsinkelse på andre prosjekter
- Frustrasjon og stress

### Omdømmekostnader
- Misfornøyd kunde
- Dårlig omtale
- Tapte fremtidige oppdrag

### Et Eksempel
Feil fall på bad:
- Riving: 8 timer à 600 = 4.800
- Ny membran og fliser: 15.000
- Administrasjon: 3 timer à 800 = 2.400
- Totalt: ~22.000 kr

Alt fra egen margin.

> "Reklamasjoner er ikke et forsikringsproblem. De er et marginproblem."', 
     2, 12),
    
    ('Kvalitet Er Økonomi', 
     '## Bedre Dialog = Bedre Bunnlinje

Koblingen mellom trygghet og økonomi er direkte.

### Regnestykket
- Én reklamasjon koster 20.000 kr
- Ti reklamasjoner = 200.000 kr
- Halverer du reklamasjonene = 100.000 i sparte kostnader

### Hva Koster Forebygging?
- Morgenmøte: 10 min x 5 mann = ~400 kr/dag
- Ekstra sjekk før lukking: 500 kr
- Totalt per uke: ~2.500 kr

### ROI På Trygghet
Hvis forebygging koster 100.000/år, og du unngår 5 reklamasjoner à 20.000:
→ Du sparer 0 kr (break-even)
→ Plus: bedre omdømme, mindre stress, fornøyde folk

I praksis sparer de fleste mye mer.

> "Investering i kvalitet er ikke en kostnad. Det er en sparing."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 5, Module 2 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'feil-koster-ditt-ansvar' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Kostnadskurven', 
     '## Jo Senere, Jo Dyrere

Kostnaden ved å rette en feil stiger eksponentielt med tid.

### Fases
| Fase | Eksempel: Feil høyde på dør |
|------|------------------------------|
| Planlegging | 0 kr (tegning justeres) |
| Før montering | 200 kr (nytt materiale) |
| Etter montering | 2.000 kr (demontere, endre, remontere) |
| Etter overflatebehandling | 8.000 kr (alt må tas på nytt) |
| Etter overlevering | 15.000+ kr (kundefrustrasjon, garanti, admin) |

### 10x-Regelen
Som tommelfingerregel: Kostnaden 10-dobles for hver fase den slipper gjennom.

### Implikasjonen
Hver krone brukt på å stoppe feil tidlig, sparer 10-100 kroner senere.

> "Den billigste feilen er den som aldri ble gjort. Den nest billigste er den som ble stoppet i dag."', 
     1, 12),
    
    ('Hvor Stoppes Feilene?', 
     '## Analyse Av Egne Data

For å forbedre, må du vite hvor feilene stoppes - og hvor de slipper gjennom.

### Kartlegging
For de siste 10 reklamasjonene:
- Når oppsto feilen? (Fase)
- Når ble den oppdaget? (Fase)
- Hva kostet den?

### Mønster
Typiske funn:
- De fleste feil oppstår i grensesnitt
- Mange kunne vært stoppet ved enkel sjekk
- Kommunikasjonssvikt går igjen

### Handling
Når du vet mønsteret, kan du målrette:
- Ekstra oppmerksomhet på risikofaser
- Sjekkpunkter der feil ofte slipper gjennom
- Bedre kommunikasjon der det feiler mest

> "Du kan ikke forbedre det du ikke måler."', 
     2, 12),
    
    ('Investere I Forebygging', 
     '## Hvor Skal Pengene Gå?

Begrenset tid og ressurser må brukes smart.

### Høyest Avkastning
**Før jobbstart:**
- Gjennomgang av tegninger
- Avklaring av uklarheter
- Koordinering mellom fag

**Ved kritiske punkter:**
- Før støp/lukking
- Ved fagskifter
- Før overlevering

**På kjente problemområder:**
- Våtrom
- Grensesnitt mellom fag
- Komplekse detaljer

### Prioritering
Sett inn ressurser der kostnadene historisk har vært høyest.

> "Smart forebygging er ikke å sjekke alt - det er å sjekke det rette."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 5, Module 3 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'feil-koster-ditt-ansvar' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Ikke Bare Tell Skader', 
     '## Reaktiv Vs Proaktiv Måling

De fleste måler bare det som allerede har gått galt.

### Reaktive Målinger (Bakspeil)
- Antall reklamasjoner
- Kostnader til utbedring
- HMS-hendelser

Disse forteller deg hva som har skjedd. De hjelper ikke å forebygge.

### Proaktive Målinger (Frontlys)
- Antall avklaringer før utførelse
- Stopp-og-sjekk gjennomført
- Nesten-feil rapportert
- Trygghetspuls i teamet

Disse forteller deg om systemet virker - før feil skjer.

### Balanse
Du trenger begge. Men de fleste har bare reaktive.

> "Å måle reklamasjoner er som å telle ulykker. Du vil heller forhindre dem."', 
     1, 12),
    
    ('Måle Stopp-Og-Sjekk', 
     '## Dokumenter At Forebygging Skjer

Hvis du ikke måler forebygging, vet du ikke om det skjer.

### Enkle Målinger

**Avklaringer før utførelse:**
- Antall tekniske spørsmål stilt til prosjektering
- Svar mottatt før oppstart

**Sjekkpunkter:**
- Før-støp-sjekk gjennomført? Ja/Nei
- Grensesnitt-sjekk mellom fag? Ja/Nei

**Kommunikasjon:**
- Morgenmøte holdt? Ja/Nei
- Ukentlig kvalitetsgjennomgang? Ja/Nei

### Hvordan Bruke
Ikke for å kontrollere - men for å se om rutinene faktisk følges.

> "Det som måles, blir gjort. Mål forebygging, ikke bare feil."', 
     2, 12),
    
    ('Pulsmålinger På Trygghet', 
     '## Føler Folk Seg Trygge?

Du kan faktisk måle psykologisk trygghet - enkelt og regelmessig.

### Enkel Puls
Én gang i uken/måneden, still teamet 3 spørsmål:

1. Føler du det er OK å stille spørsmål her?
2. Føler du det er OK å si fra når noe ikke stemmer?
3. Føler du at feil kan diskuteres åpent?

Skala 1-5. Anonymt hvis nødvendig.

### Bruk Resultatene
- Trend over tid: Blir det bedre eller verre?
- Sammenlign team: Hvor er det lavest?
- Handling: Snakk om resultatene åpent

### Viktig
Det å spørre sender et signal i seg selv: "Vi bryr oss om dette."

> "En trygghetspuls viser om budskapet ditt faktisk når frem."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE 6: Fra Innsikt Til Tiltak
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Fra Innsikt Til Tiltak',
    'Gjør kunnskap om til handling. Dette kurset gir deg konkrete verktøy for å implementere forebyggende tiltak som faktisk virker.',
    'fra-innsikt-til-tiltak',
    TRUE,
    NULL,
    'site_manager'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'fra-innsikt-til-tiltak');

-- Course 6 Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'fra-innsikt-til-tiltak')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Tiltak Som Virker', 'Praktiske grep før, under og etter arbeid som faktisk forebygger.', 1),
    ('Implementering', 'Hvem gjør hva, når - og hvordan vite at det skjer.', 2),
    ('Oppfølging Og Forankring', 'Hvordan sikre at tiltak overlever den første uken.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Course 6, Module 1 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'fra-innsikt-til-tiltak' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Før Jobbstart', 
     '## Forebygge Før Det Begynner

De beste tiltakene tar fatt i risiko før utførelse.

### Konkrete Tiltak

**Tegningsgjennomgang:**
- Gå gjennom tegninger sammen før oppstart
- Marker uklarheter med post-it/markør
- Avklar alt før første spiker

**Koordineringsmøte:**
- Hvem gjør hva denne uken?
- Hvor møtes fagene?
- Hvor er det risiko for konflikt?

**ROS-analyse (enkel):**
- Hva kan gå galt?
- Hvor alvorlig er det?
- Hva gjør vi for å hindre det?

### Krav Til Tiltak
- Realistisk innen dagens rammer
- Konkret (hvem, hva, når)
- Mulig å måle om det skjer

> "15 minutter forberedelse kan spare 15 timer utbedring."', 
     1, 12),
    
    ('Under Arbeid', 
     '## Løpende Kvalitetssikring

Forebygging stopper ikke når arbeidet starter.

### Konkrete Tiltak

**Stopp-og-sjekk:**
- Definerte kontrollpunkter i prosessen
- Sjekk før lukking/støping
- Dokumenter med foto/signatur

**Kollegakontroll:**
- Par-sjekk på kritiske oppgaver
- 2 minutter fra kollega = gratis QA

**Avklaringskanal:**
- Hvem kontaktes ved tvil?
- Forventet responstid
- Alternativ hvis hovedperson utilgjengelig

**Synlig progresjon:**
- Tavle/skjerm med status
- Ulike fag ser hverandres fremdrift
- Lettere å koordinere

> "Kontroll underveis er billigere enn kontroll etterpå."', 
     2, 12),
    
    ('Etter Feil Og Nesten-Feil', 
     '## Lære Av Det Som Skjer

Feil vil skje. Det viktige er å lære.

### Konkrete Tiltak

**Hendelseslogg:**
- Enkel dokumentasjon av hva som skjedde
- Ingen skyldfokus
- Åpen for alle å bidra

**Evalueringsmøte:**
- Kort møte etter hendelser
- Hva skjedde? Hvorfor? Hva gjør vi?
- Fokus på forbedring, ikke straff

**Dele På Tvers:**
- Læringspunkter deles med andre team
- Prosjektmøter inkluderer kvalitetsuppdatering
- Positivt fokus: "Dette lærte vi"

**Feire når feil stoppes:**
- Anerkjenn de som stopper feil
- Det er en seier, ikke en selvfølge
- Bygger kultur for å si fra

> "En organisasjon som lærer av feil, gjør færre feil."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 6, Module 2 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'fra-innsikt-til-tiltak' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hvem Gjør Hva', 
     '## Ansvarliggjøring

Et tiltak uten navn er bare en god intensjon.

### For Hvert Tiltak, Definer:

**Hvem?**
- Konkret person (ikke "noen" eller "vi")
- Backup hvis hovedperson er borte

**Hva?**
- Helt konkret handling
- Ikke vagt ("forbedre kommunikasjon")
- Målbart ("morgenmøte hver dag")

**Når?**
- Start-dato
- Frekvens (daglig, ukentlig, ved hver støp)
- Sluttdato for evaluering

### Eksempel

❌ "Vi skal bli bedre på å sjekke tegninger"

✅ "Pål gjennomgår tegninger med teamet hver mandag kl 07:30. Start neste uke. Evaluering etter 4 uker."

> "Et tiltak uten eier, er et tiltak som dør."', 
     1, 12),
    
    ('Realistisk Innen Rammer', 
     '## Ikke Lag For Mange Tiltak

Ambisiøse planer feiler. Enkle planer lykkes.

### Begrens Omfanget
- Start med 2-3 tiltak, ikke 10
- Velg de som har størst effekt
- Test først, utvid etterpå

### Bruk Eksisterende Strukturer
- Bygg på møter dere allerede har
- Legg til det, ikke erstatt
- Minst mulig ekstra tid

### Gjør Det Enkelt
- Kan forklares på ett minutt
- Ingen omfattende dokumentasjon
- Lett å huske

### Test I Liten Skala
- Prøv på ett prosjekt/team først
- Juster basert på erfaring
- Ruller ut når det virker

> "Bedre å gjennomføre ett tiltak 100% enn ti tiltak 10%."', 
     2, 12),
    
    ('Hvordan Vite At Det Skjer', 
     '## Synlighet Og Sporing

Hvis ingen følger med, forsvinner tiltaket.

### Enkle Sporingsmetoder

**Sjekkliste:**
- Fysisk eller digital liste
- Huke av når gjennomført
- Synlig for alle

**Tavle/Dashboard:**
- Status på tiltak
- Grønt/gult/rødt
- Oppdateres ukentlig

**Kort Puls:**
- 5 minutter i ukemøte
- "Hvordan går det med X?"
- Ærlig tilbakemelding

### Handle På Avvik
Hvis tiltak ikke følges:
- Forstå hvorfor (tid, glemsel, motstand?)
- Juster om nødvendig
- Vær tydelig på at det er viktig

> "Tiltak som ikke følges opp, følges ikke."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Course 6, Module 3 Lessons
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'fra-innsikt-til-tiltak' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Testperiode', 
     '## Prøv I 4-6 Uker

Nye rutiner trenger tid til å sette seg.

### Hvorfor 4-6 Uker?
- Kort nok til å justere raskt
- Lang nok til å se om det virker
- Tid til å gjøre feil og lære

### Under Testperioden
- Følg planen, selv om det butter
- Noter hva som fungerer og ikke
- Ikke gi opp ved første motstand

### Etter Testperioden
- Evaluer: Hva fungerte?
- Spør teamet: Hva synes dere?
- Beslut: Fortsett, juster, eller dropp

### Forventningsstyring
Si tydelig: "Vi prøver dette i 4 uker, så evaluerer vi."

> "Ingenting er permanent. Alt er et eksperiment til vi vet at det virker."', 
     1, 12),
    
    ('Evaluering Og Justering', 
     '## Lære Av Implementeringen

Første forsøk er sjelden perfekt.

### Evalueringsspørsmål
- Ble tiltaket gjennomført som planlagt?
- Hva var lett? Hva var vanskelig?
- Ga det ønsket effekt?
- Hva bør endres?

### Typiske Justeringer
- Forenkle det som er for komplekst
- Endre tidspunkt/frekvens
- Bytte ansvarlig
- Skrote det som ikke virker

### Feire Suksess
Hvis noe virker, feir det:
- Fortell teamet
- Del med andre prosjekter
- Bygg på det som fungerer

> "Den beste planen er den som justeres basert på virkeligheten."', 
     2, 12),
    
    ('Forankring I Organisasjonen', 
     '## Fra Prosjekt Til Kultur

For at endring skal vare, må den bli "sånn vi gjør det".

### Ledelsesforankring
- Daglig leder/prosjektleder må støtte aktivt
- Ikke bare akseptere - aktivt etterspørre
- Prioritere tid og ressurser

### Integrering I Rutiner
- Legg inn i maler og sjekklister
- Del av onboarding for nye
- Ta det med til nye prosjekter

### Vedlikeholdelse
- Jevnlig oppfrisk (kvartalsvis/halvårlig)
- Fortsett å måle
- Ikke ta suksess for gitt

### Endelig Test
Kulturen er endret når folk sier:
"Selvfølgelig gjør vi sånn - det er jo bare sånn det er."

> "Varige endringer blir usynlige - de blir bare måten vi jobber på."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Link site manager courses to Håndverkere category
WITH cat AS (SELECT id FROM categories WHERE name = 'Håndverkere')
UPDATE courses SET category_id = cat.id
FROM cat
WHERE courses.slug IN ('lederen-som-trygghetsskaper-bygg', 'feil-koster-ditt-ansvar', 'fra-innsikt-til-tiltak')
AND courses.category_id IS NULL;

-- End of migration
