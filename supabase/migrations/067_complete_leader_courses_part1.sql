-- Migration: 067_complete_leader_courses_part1.sql
-- Purpose: Add lessons for modules 2 and 3 of leader courses 1-3
-- Content in Bokmål

-- =====================================================
-- COURSE: Lederen som Trygghetsskaper
-- =====================================================

-- MODUL 2: Romme Feil og Usikkerhet
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'lederen-som-trygghetsskaper' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Feil Som Læringsmulighet', 
     '## Når Ting Går Galt

I høypresterende team skjer det feil. Forskjellen ligger i hvordan feilene håndteres.

### To Typer Kulturer

**Skam-kultur:**
- Feil skjules
- Folk peker på andre
- Innovasjon stopper
- Problemer vokser i det skjulte

**Læringskultur:**
- Feil deles åpent
- "Hva kan vi lære?" er første spørsmål
- Rask forbedring
- Problemer fanges tidlig

### Praktiske Grep
1. **Del dine egne feil først**: "I går gjorde jeg en feil med..." 
2. **Spør "hva" ikke "hvem"**: Fokuser på systemet, ikke personen
3. **Feir læring**: "Takk for at du delte dette - nå kan vi alle lære"
4. **Dokumenter og del**: Gjør læring tilgjengelig for alle

> "I en kultur der feil straffes, er den eneste feilen som gjøres at ingen prøver noe nytt."

### Refleksjon
Tenk på sist noen på teamet ditt gjorde en feil. Hvordan reagerte du? Hva lærte dere?', 
     1, 12),
    
    ('Håndtere Usikkerhet', 
     '## Når Du Ikke Vet Svaret

Ledere forventes ofte å ha alle svar. Men de beste lederne er komfortable med å si "jeg vet ikke".

### Hvorfor Usikkerhet Er Ok
- Det viser ærlighet
- Det inviterer til innspill
- Det bygger tillit (ingen liker en som later som)
- Det åpner for bedre løsninger

### Hvordan Håndtere Usikkerhet

| Situasjon | Respons |
|-----------|---------|
| Du vet ikke svaret | "Jeg vet ikke, men la oss finne ut av det sammen" |
| Fremtiden er uklar | "Her er det vi vet, og her er det vi ikke vet" |
| Beslutning under press | "Vi tar beste beslutning med info vi har nå" |

### Kommunikasjon I Usikkerhet
1. **Vær ærlig** om hva du vet og ikke vet
2. **Del prosessen** - hvordan dere skal finne ut mer
3. **Gi trygghet** i usikkerheten - "Vi klarer dette sammen"
4. **Oppdater jevnlig** når du vet mer

> "Trygghet handler ikke om å fjerne usikkerhet - det handler om å tåle den sammen."', 
     2, 10),
    
    ('Psykologisk Trygghet I Kriser', 
     '## Når Presset Øker

Det er lett å være en god leder når alt går bra. Den virkelige testen kommer i kriser.

### Vanlige Feller I Kriser
- Bli mer kontrollerende
- Slutte å lytte
- Ta alle beslutninger selv
- Glemme å ta vare på folk

### Beholde Tryggheten Under Press

**1. Senk tempoet (selv om det føles feil)**
- Ta 5 minutter før store beslutninger
- Spør teamet før du konkluderer
- Husk at panikk smitter

**2. Kommuniser mer, ikke mindre**
- Daglige oppdateringer
- Vær tilgjengelig for spørsmål
- Del også det du ikke vet

**3. Anerkjenn følelsene**
- "Jeg forstår at dette er stressende"
- "Det er normalt å være bekymret"
- "Vi står i dette sammen"

**4. Hold på rutinene**
- 1:1-er er viktigere enn noen gang
- Teamets ritualer gir stabilitet
- Små ting betyr mye

> "I kriser viser du hvem du egentlig er som leder. Sørg for at det er noen teamet vil følge."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Modellere Sårbarhet
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'lederen-som-trygghetsskaper' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Styrken I Sårbarhet', 
     '## Å Vise At Du Er Menneskelig

Mange ledere tror de må være ufeilbarlige. Men forskning viser at sårbare ledere bygger sterkere team.

### Hva Sårbarhet IKKE Er
- Å dele alt med alle
- Å bruke teamet som terapi
- Å være svak eller ubesluttsom
- Å unngå vanskelige beslutninger

### Hva Sårbarhet ER
- Å innrømme feil
- Å si "jeg vet ikke"
- Å be om hjelp
- Å vise at du også lærer

### Praktiske Eksempler
- "Jeg gjorde en feil i går da jeg..."
- "Jeg er usikker på hvordan vi skal løse dette"
- "Kan du hjelpe meg å forstå...?"
- "Dette har jeg slitt med selv"

### Effekten
Når du viser sårbarhet:
- Andre tør å gjøre det samme
- Tilliten øker
- Problemene kommer frem tidligere
- Innovasjonen øker

> "Sårbarhet er ikke svakhet. Det er mot."', 
     1, 10),
    
    ('Balansen Mellom Åpenhet Og Autoritet', 
     '## Du Er Fortsatt Lederen

Å være sårbar betyr ikke å gi opp lederskapet. Det handler om å finne balansen.

### Hva Du Kan Dele
- Profesjonelle usikkerheter
- Læringsreiser og feil
- Utfordringer du jobber med
- At du verdsetter innspill

### Hva Du Bør Være Forsiktig Med
- Personlige kriser (del med noen, ikke alle)
- Usikkerhet om strategiske beslutninger (dekk ryggen din)
- Frustrasjon over egen ledelse
- Ting som skaper unødig bekymring

### Praktiske Retningslinjer

| Situasjon | Åpent med teamet? |
|-----------|-------------------|
| "Jeg gjorde en feil i prosjektet" | ✓ Ja |
| "Jeg er usikker på min fremtid her" | ✗ Nei |
| "Jeg lærer fortsatt dette" | ✓ Ja |
| "Ledelsen driver meg til vanvidd" | ✗ Nei |

### Hovedregel
Del det som gjør deg menneskelig uten å skape usikkerhet om din evne til å lede.

> "Åpenhet bygger tillit. Overdeling bygger bekymring."', 
     2, 12),
    
    ('Å Skape Rom For Andres Sårbarhet', 
     '## Det Handler Om Dem, Ikke Deg

Din sårbarhet er verdiløs hvis den ikke åpner døren for andres.

### Signaler Du Sender
Hver gang noen deler noe sårbart, ser alle andre på hvordan du reagerer. Din respons setter standarden.

### Gode Responser
- "Takk for at du delte dette"
- "Det høres tøft ut. Hvordan kan jeg hjelpe?"
- "Det var modig av deg å ta opp"
- Stillhet og aktiv lytting

### Dårlige Responser
- Hoppe rett til løsning
- Minimere ("Det er vel ikke så ille")
- Sammenligne ("Jeg hadde det verre når...")
- Ignorere og gå videre

### Skape Trygge Rammer
1. **Ikke avbryt** når noen deler
2. **Følg opp** senere: "Hvordan går det med det du nevnte?"
3. **Beskriv aldri andres sårbarhet** til tredjeparter
4. **Gjør det normalt** å snakke om utfordringer

### Teamøvelse
Start møter med: "Hva er én utfordring du står i akkurat nå?" Begynn selv.

> "Folk deler ikke fordi du ba dem om det. De deler fordi du viste at det er trygt."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE: Inkluderende Ledelse
-- =====================================================

-- MODUL 2: Inkludere Alle Stemmer
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'inkluderende-ledelse' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hvem Snakker I Møtene?', 
     '## De Stille Stemmene

I de fleste møter er det noen få som snakker mest. Spørsmålet er: Hvem hører du ikke fra?

### Typisk Møtedynamikk
- 20% av deltakerne står for 80% av taletiden
- Ekstroverte dominerer naturlig
- De med mest erfaring/senioritet snakker først
- Gode ideer går tapt

### Praktiske Teknikker

**1. Roter hvem som snakker først**
- Ikke alltid start med "noen som vil dele?"
- Gå runden, eller trekk tilfeldig navn

**2. Bruk skriftlig input først**
- La alle skrive ned tanker før diskusjon
- Bruk post-its eller digitale verktøy
- Gir de stille tid til å tenke

**3. Still direkte spørsmål**
- "Anna, hva tenker du?"
- "Vi har ikke hørt fra deg ennå, Markus - har du innspill?"

**4. Følg opp etter møtet**
- Send melding til de som var stille
- "Hadde du noen tanker du ikke rakk å dele?"

> "Alle har noe å bidra med. Jobben din er å skape rommet der det skjer."', 
     1, 12),
    
    ('Mangfold I Beslutninger', 
     '## Bedre Beslutninger Gjennom Ulikhet

Homogene grupper føler seg ofte mest effektive. Men de tar dårligere beslutninger.

### Hvorfor Mangfold Gir Bedre Beslutninger
- Flere perspektiver avdekker blindsoner
- Ulik erfaring gir rikere analyse
- Uenighet forbedrer kritisk tenkning
- Færre gruppetenking-feller

### Praktiske Grep

**Ved Rekruttering:**
- Ha mangfold i intervjupanelet
- Sjekk jobbannonsene for bias-språk
- Se aktivt etter andre bakgrunner

**I Hverdagen:**
- Inviter ulike folk til prosjektgrupper
- Roter hvem som får prestisjeoppgaver
- Spør bevisst etter alternative synspunkter

**I Møter:**
- Oppnevn en "djevelens advokat"
- Spør: "Hvem har vi ikke tenkt på?"
- "Hva ser jeg ikke her?"

### Advarsel
Mangfold uten inkludering = frustrasjon. Det holder ikke å ha ulike folk i rommet - de må føle at stemmen deres teller.

> "Mangfold er å bli invitert til festen. Inkludering er å bli bedt om å danse."', 
     2, 12),
    
    ('Mikro-inkludering', 
     '## De Små Tingene Som Betyr Alt

Inkludering handler ikke bare om store initiativ. Det er summen av tusen små handlinger.

### Daglige Inkluderingshandlinger

**Kommunikasjon:**
- Bruk folks navn riktig (og lær uttalen)
- Unngå interne spøker nye ikke forstår
- Oversett sjargong for nyansatte
- Si "vi" i stedet for "dere"

**Møter:**
- Hils på alle, ikke bare de du kjenner best
- Gi kreditt til den som hadde ideen
- Ikke avbryt eller snakk over andre
- Tilpass møtetider til ulike tidssoner/behov

**Synlighet:**
- Inkluder alle i relevante e-poster
- Inviter til lunsjsamtaler
- Presenter folk for viktige kontakter
- Del informasjon proaktivt

### Øvelse: Inkluderingssjekk
Hver uke, spør deg selv:
- Hvem har jeg inkludert aktivt?
- Hvem kan ha følt seg utenfor?
- Hva kan jeg gjøre annerledes neste uke?

> "Inkludering er ikke et prosjekt. Det er en daglig praksis."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Håndtere Ekskludering
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'inkluderende-ledelse' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Å Se Ekskludering', 
     '## Det Du Ikke Ser

Ekskludering er ofte usynlig - spesielt for de som ikke rammes.

### Tegn På Ekskludering
- Noen blir konsekvent ikke invitert
- Folk slutter å bidra i møter
- Uformelle samtaler stopper når visse folk kommer
- Informasjon deles ikke likt
- "Innenfor"-spøker som ikke alle forstår

### Hvem Er Ofte Utenfor?
- Nyansatte
- Folk som jobber remote
- De med annen bakgrunn enn majoriteten
- Introverterte
- Folk som utfordrer status quo

### Hvordan Oppdage Det

**Observer:**
- Hvem spiser lunch med hvem?
- Hvem får viktige oppgaver?
- Hvem nevnes i uformelle samtaler?

**Spør direkte:**
- "Føler du at du er en del av teamet?"
- "Er det noe du føler du går glipp av?"
- Anonyme undersøkelser

**Lytt til kroppen:**
- Hvem trekker seg tilbake?
- Hvem bytter kroppsspråk når de snakker?

> "Det farligste er ikke det du ser - det er det du har sluttet å legge merke til."', 
     1, 12),
    
    ('Å Gripe Inn', 
     '## Når Du Ser Ekskludering

Å se ekskludering uten å handle gjør deg til en del av problemet.

### Når Skal Du Gripe Inn?
- Noen blir avbrutt gjentatte ganger
- En persons idé ignoreres, så roses når noen andre sier det
- Noen blir ikke invitert til et møte de burde vært i
- Nedsettende kommentarer eller "spøker"
- Usynliggjøring i samtaler

### Hvordan Gripe Inn

**I øyeblikket (lavintensitet):**
- "Vent, jeg tror ikke Maria var ferdig"
- "Det var faktisk Johannes sitt forslag i stad"
- "La oss høre fra alle her"

**Etter (høyere intensitet):**
- "Jeg la merke til at... Var det intendert?"
- "Kan vi snakke om hva som skjedde i møtet?"
- Privat samtale med den som ekskluderer

**Med den ekskluderte:**
- "Hvordan opplevde du møtet?"
- "Er dette noe som skjer ofte?"
- "Hva trenger du fra meg?"

### Viktig
Å gripe inn kan være ukomfortabelt. Men det er mye mer ukomfortabelt å være den som blir ekskludert.

> "Det eneste som trengs for at ekskludering skal fortsette, er at de som ser det, ikke sier noe."', 
     2, 15),
    
    ('Bygge Inkluderende Normer', 
     '## Fra Enkelthandlinger Til Kultur

Enkelthendelser er viktige, men varig endring krever systemer og normer.

### Etabler Tydelige Normer

**For møter:**
- "Vi avbryter ikke"
- "Vi gir kreditt til idéer"
- "Vi roterer hvem som snakker først"

**For kommunikasjon:**
- Alle relevante parter i CC
- Oversett sjargong
- Tid til å prosessere før beslutninger

**For teamet:**
- Nye blir aktivt inkludert
- Vi sjekker inn med alle regelmessig
- Uenighet er velkommen

### Gjør Normene Synlige
- Skriv dem ned
- Henvis til dem når de brytes
- Diskuter dem i onboarding
- Oppdater dem når teamet endres

### Mål Inkludering
- Regelmessige pulsundersøkelser
- Inkluderingsspørsmål i 1:1
- Spor hvem som får muligheter
- Se på hvem som slutter (og hvorfor)

### Lederen Som Rollemodell
Normene betyr ingenting hvis du ikke følger dem selv. Teamet ser på deg.

> "Kultur er hva som skjer når ingen ser på. Normer er hva du gjør når alle ser på."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE: Delegering og Tillit
-- =====================================================

-- MODUL 2: Oppfølging Uten Mikro
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'delegering-og-tillit' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Sjekkpunkter Uten Kontroll', 
     '## Følge Opp Uten Å Mikrostyre

Delegering betyr ikke å slippe taket helt. Det betyr å finne riktig balanse.

### Mikroledelse vs. Oppfølging

| Mikroledelse | God Oppfølging |
|--------------|----------------|
| Sjekker konstant | Avtalte sjekkpunkter |
| Dikterer hvordan | Spør hvordan det går |
| Korrigerer alt | Gir rom for andre løsninger |
| Tar tilbake oppgaven | Støtter når nødvendig |

### Etabler Sjekkpunkter Ved Start
Når du delegerer, avtal:
1. **Når** er første oppfølging?
2. **Hva** vil du ha oppdatering om?
3. **Hvordan** skal oppdateringen gis?
4. **Hva** kan de bestemme selv?

### Spørsmål I Oppfølging
- "Hvordan går det?"
- "Er det noe du trenger fra meg?"
- "Hva er de største utfordringene?"
- "Er du på sporet til deadline?"

### Unngå
- "Hvorfor gjorde du det sånn?"
- Å endre målet underveis
- Å ta over når det blir vanskelig
- Å sjekke oftere enn avtalt

> "Tillit er ikke å la folk seile sin egen sjø. Det er å gi dem kompetanse og støtte - og så la dem styre."', 
     1, 12),
    
    ('Når Ting Går Galt', 
     '## Feil Etter Delegering

Noen ganger går delegerte oppgaver galt. Hvordan du håndterer det, definerer fremtidig tillit.

### Første Respons (Ikke reagér med)
- "Jeg visste jeg skulle gjort det selv"
- "Hvorfor spurte du ikke?"
- Sweet-bitter sukk og ta over

### Bedre Tilnærming

**1. Forstå hva som skjedde**
- "Fortell meg hva som skjedde"
- Lytt uten å avbryte
- Still oppklarende spørsmål

**2. Identifiser rotårsak**
- Manglet de ressurser?
- Var forventningene uklare?
- Var oppgaven for vanskelig?
- Skjedde det uforutsette ting?

**3. Fokuser fremover**
- "Hva trenger du for å fikse dette?"
- "Hva har vi lært?"
- "Hva gjør vi annerledes neste gang?"

### Din Rolle I Feilen
Spør deg selv ærlig:
- Var jeg tydelig nok?
- Ga jeg nok støtte?
- Var oppgaven riktig for denne personen?
- Burde jeg sjekket inn tidligere?

> "Når delegering feiler, er det sjelden bare den andres feil."', 
     2, 12),
    
    ('Gradvis Økning Av Ansvar', 
     '## Fra Hånd-Holding Til Autonomi

Tillit bygges gradvis. Start smått, øk over tid.

### Tillitstrappen

**Steg 1: Observer og rapporter**
"Undersøk dette og fortell meg hva du fant"

**Steg 2: Anbefal**
"Kom med en anbefaling for hva vi bør gjøre"

**Steg 3: Gjennomfør med godkjenning**
"Gjør dette, men sjekk med meg først"

**Steg 4: Gjennomfør og rapporter**
"Gjør dette og fortell meg hva du gjorde"

**Steg 5: Full autonomi**
"Dette er ditt domene. Jeg stoler på deg."

### Når Øke Ansvaret?
- Når tidligere steg er mestret
- Når personen viser proaktivitet
- Når de spør om mer ansvar
- Når du ser god dømmekraft

### Når Ta Et Steg Tilbake?
- Ved gjentatte feil på samme område
- Når personen selv ber om mer støtte
- Ved stort press eller krise
- Ved ny type utfordring

### Kommuniser Tydelig
"Jeg gir deg mer ansvar her fordi..." er viktig å si. Likeså om du trenger å ta tilbake noe.

> "Autonomi er ikke noe du gir - det er noe folk fortjener gjennom vist kompetanse."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Bygge Autonome Team
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'delegering-og-tillit' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Fra Avhengighet Til Selvstendighet', 
     '## Målet: Et Team Som Ikke Trenger Deg

Den beste indikatoren på god ledelse er et team som fungerer uten deg.

### Tegn På Avhengighet
- Alle spørsmål kommer til deg
- Ingen beslutninger tas uten deg
- Folk venter på instruksjoner
- Du er alltid i kritisk sti
- Ferieen din = kaos

### Tegn På Selvstendighet
- Teamet løser problemer selv
- Beslutninger tas lokalt
- Folk tar initiativ
- Du blir oppdatert, ikke spurt
- Du kan fokusere på strategi

### Slik Bygger Du Selvstendighet

**1. Slutt å svare med svar**
I stedet for "Gjør X", spør "Hva tenker du?"

**2. Tål ukomforten**
De første "feilene" er læring for fremtiden

**3. Gjør deg unnværlig**
Del kunnskap, dokumenter prosesser, lær andre

**4. Feir initiativ**
Anerkjenn når folk tar ansvar selv

> "Hvis teamet ditt ikke kan fungere uten deg, har du ikke bygget et team - du har bygget en avhengighet."', 
     1, 12),
    
    ('Klare Rammer For Autonomi', 
     '## Frihet Innenfor Grenser

Total frihet er ikke effektiv. Autonomi trenger rammer for å fungere.

### Hva Er Rammene?

**Mål**: Hva skal oppnås?
**Ressurser**: Hva har de å jobbe med?
**Tid**: Når må det være ferdig?
**Grenser**: Hva kan de IKKE gjøre?
**Eskalering**: Når skal de komme til deg?

### Eksempel Ramme
"Du har ansvar for kundetilfredshet. Målet er NPS over 50. Du har budsjett på X og kan ansette Y. Du kan gi refusjoner opp til Z uten godkjenning. Ved juridiske spørsmål, kom til meg."

### Vanlige Feil
- For vage mål ("gjør det bra")
- Uklare grenser (som blir oppdaget ved feil)
- Ingen eskaleringsregler
- Endrer rammer underveis

### Kommuniser Rammene
1. Diskuter dem med personen
2. Skriv dem ned
3. Referer til dem ved behov
4. Oppdater dem ved endringer

> "Rammer er ikke begrensninger. De er det som gjør frihet mulig."', 
     2, 10),
    
    ('Lederen Som Støttespiller', 
     '## Fra Sjef Til Coach

Når teamet er autonomt, endres din rolle. Du er ikke sjefen som instruerer - du er støttespilleren som muliggjør.

### Din Nye Rolle

**Fjerne hindringer**
- "Hva står i veien for deg?"
- Rydde byråkrati
- Skaffe ressurser
- Håndtere interessenter

**Gi retning**
- Holde målet klart
- Kommunisere strategi
- Prioritere når alt er viktig

**Utvikle folk**
- Coaching i 1:1
- Strekkmål og utfordringer
- Feedback og anerkjennelse

**Representere teamet**
- Beskytte mot distraksjoner
- Løfte resultater oppover
- Skaffe støtte fra organisasjonen

### Tidfordeling For Autonome Team
Tidligere: 80% instruere, 20% støtte
Nå: 20% retning, 80% muliggjøring

### Husk
Å gå fra kaptein til coach er vanskelig. Det føles som å gi fra seg kontroll. Men det du gir fra deg i kontroll, får du tilbake i kapasitet.

> "De beste lederne skaper ikke følgere. De skaper andre ledere."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- End of migration part 1
