-- Migration: 069_complete_team_member_courses_part1.sql
-- Purpose: Add lessons for modules 2 and 3 of team member courses 1-3
-- Content in Bokmål

-- =====================================================
-- COURSE: Trygg på Jobb
-- =====================================================

-- MODUL 2: Tørre å Si Fra
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'trygg-pa-jobb' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hvorfor Det Er Vanskelig', 
     '## Frykten For Å Si Fra

De fleste av oss holder tilbake meninger på jobb. Vi er redde for:

### Vanlige Frykter
- At vi høres dumme ut
- At vi blir oppfattet som vanskelige
- At det får konsekvenser for karrieren
- At vi tar feil
- At ingen bryr seg

### Kostnaden Av Stillhet
- Problemer vokser i det skjulte
- Gode ideer går tapt
- Du føler deg usynlig
- Frustrasjon bygger seg opp

### Forskning Viser
De som sier fra, oppfattes som mer kompetente - ikke mindre. Og team der folk sier fra, presterer bedre.

> "Stemmen din har verdi. Å holde den tilbake er å holde tilbake en del av teamet."

### Refleksjon
Tenk på en gang du holdt tilbake noe. Hva var du redd for? Hva skjedde (eller ikke)?', 
     1, 12),
    
    ('Måter Å Si Fra På', 
     '## Lavterskel Strategier

Du trenger ikke storme inn med store konfrontasjoner. Start smått.

### Stille Spørsmål
I stedet for å si "dette er feil", prøv:
- "Kan du hjelpe meg å forstå..."
- "Har vi tenkt på..."
- "Hva vil skje hvis..."

### Trygg Formulering
- **Jeg-språk**: "Jeg opplever..." i stedet for "Du gjør..."
- **Ønske**: "Det hadde vært nyttig om..."
- **Tilbud**: "Kan vi se på dette sammen?"

### Timing
- Ikke i plenum hvis risikabelt
- Be om en prat på tomannshånd
- Etter litt tid til å tenke, ikke i affekt

### Start Med Det Trygge
Begynn med ufarlige meninger i trygge kontekster. Bygg opp.

> "Hver gang du sier noe, blir det lettere neste gang."', 
     2, 12),
    
    ('Når Andre Sier Fra', 
     '## Du Former Kulturen

Hvordan du reagerer når andre sier fra, påvirker om de gjør det igjen.

### Gode Responser
- "Takk for at du sa dette."
- "Det er et interessant perspektiv."
- "Kan du si mer om det?"
- Nikk og lytt

### Dårlige Responser
- Avbryte
- Sukke eller himle med øynene
- Avvise uten å vurdere
- Ignorere og gå videre

### Effekten
Andre ser hvordan du behandler folk som sier fra. Det bestemmer om de tør selv.

### Team-Norm
Foreslå for teamet: "La oss gjøre det trygt å være uenige her. Alle ideer er velkomne."

> "Du har makt til å gjøre det tryggere for andre å snakke. Bruk den."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Håndtere Usikkerhet og Feil
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'trygg-pa-jobb' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Feil Er Menneskelig', 
     '## Alle Gjør Feil

Feil på jobb føles ofte som en katastrofe. Men det er en del av arbeidet.

### Typer Feil
- **Slurvefeil**: Glemte en detalj, misforsto
- **Prosessfeil**: Fulgte ikke rutinen
- **Vurderingsfeil**: Tok en dårlig beslutning
- **Innovasjonsfeil**: Prøvde noe nytt som ikke fungerte

### De Fleste Feil Er Små
- De føles større enn de er
- Andre legger mindre merke til dem enn du tror
- De kan ofte rettes

### Feil Som Ikke Er Greit
Slapp, unnskyldning for sløvhet, gjentatte samme feil. Men én feil? Det er menneskelig.

> "Noen som aldri gjør feil, prøver heller ikke noe nytt."', 
     1, 10),
    
    ('Når Du Gjør En Feil', 
     '## Steg For Å Håndtere Det

Alle gjør feil. Forskjellen er hvordan du håndterer det etterpå.

### 1. Erkjenn Det
- Ikke skjul eller dekkver
- Si fra tidlig - problemer vokser i det skjulte
- "Jeg har gjort en feil med..."

### 2. Ta Ansvar
- Ikke skyldig på andre eller omstendigheter
- "Jeg burde ha sjekket/spurt/tenkt..."
- Unngå "ja, men..."

### 3. Fiks Det
- Fokuser på løsning
- "Her er hva jeg foreslår vi gjør..."
- Be om hjelp hvis du trenger det

### 4. Lær Av Det
- Hva gikk galt?
- Hva gjør jeg annerledes neste gang?
- Del lærdommen med andre (hvis passende)

> "Hvordan du håndterer feilen, sier mer om deg enn feilen selv."', 
     2, 12),
    
    ('Leve Med Usikkerhet', 
     '## Når Du Ikke Vet

Arbeidslivet er fullt av usikkerhet. Å tåle det er en ferdighet.

### Kilder Til Usikkerhet
- Nye oppgaver du ikke mestrer (ennå)
- Uklare forventninger
- Omorganiseringer og endringer
- Usikker fremtid

### Vanlige Reaksjoner
- Angst og bekymring
- Behov for å kontrollere alt
- Unngåelse
- Negativt tankekjør

### Sunnere Tilnærming
1. **Aksepter usikkerheten**: Du kan ikke kontrollere alt
2. **Fokuser på det du kan**: Din innsats, dine valg
3. **Søk informasjon**: Spør, les, lær
4. **Støtt deg på andre**: Del bekymringer med kollegaer eller leder

### Mantra
"I dag vet jeg ikke alt. Og det er OK."

> "Usikkerhet er ikke en feil i jobben - det er en del av den."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE: Min Plass i Teamet
-- =====================================================

-- MODUL 2: Ditt Unike Bidrag
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'min-plass-i-teamet' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hva Du Bringer', 
     '## Dine Unike Styrker

Alle bringer noe unikt til et team. Spørsmålet er om du ser det selv.

### Typer Bidrag
Det er ikke bare fagkompetanse som teller:
- **Perspektiv**: Din bakgrunn gir unik innsikt
- **Ferdigheter**: Både faglige og mellommenneskelige
- **Energi**: Optimisme, rolig, analytisk - alt trengs
- **Koblinger**: Hvem kjenner du? Hva har du erfart?

### Øvelse: Kartlegg Bidragene
Still deg selv:
1. Hva kommer lett for meg som er vanskelig for andre?
2. Hva spør folk meg om råd om?
3. Hva gjør jeg som ofte blir lagt merke til?
4. Når føler jeg meg mest nyttig?

### Andres Syn
Spør 2-3 kolleger: "Hva vil du si er mitt viktigste bidrag til teamet?"

> "Ditt bidrag er ofte usynlig for deg fordi det kommer så naturlig."', 
     1, 12),
    
    ('Verdsett Deg Selv', 
     '## Imposter-Syndrom

Føler du noen gang at du ikke hører hjemme, at snart vil noen avsløre at du ikke er god nok?

### Vanlige Tankemønstre
- "De andre er mye flinkere"
- "Jeg har bare vært heldig"
- "Snart finner de ut at jeg ikke kan noe"
- "Jeg burde vite alt nå"

### Realiteten
- 70% av folk opplever dette
- De som virker trygge, tviler også
- Din følelse er ikke bevis på virkeligheten
- Du ble ansatt av en grunn

### Mot-Strategier
1. **Dokumenter suksess**: Hold en liste over ting du har fått til
2. **Del følelsen**: Andre opplever det samme
3. **Aksepter læringskurven**: Ekspert er ikke startpunkt
4. **Handling over følelse**: Du trenger ikke føle deg selvsikker for å handle

> "Fakta at du tviler på deg selv betyr at du bryr deg - ikke at du er dårlig."', 
     2, 12),
    
    ('Finne Din Rolle', 
     '## Mer Enn Stillingstittel

Din rolle i et team handler om mer enn hva som står i arbeidskontrakten.

### Formelle vs. Uformelle Roller
**Formelt**: Det du er ansatt for å gjøre
**Uformelt**: Det du naturlig blir i et team

### Uformelle Team-Roller
- **Tilretteleggeren**: Sørger for at ting skjer
- **Utfordreren**: Stiller de kritiske spørsmålene
- **Harmonisereren**: Løser spenninger
- **Idéskaperen**: Kommer med nye vinklinger
- **Utføreren**: Får ting ferdig

### Finn Din
- Hvilken rolle tar du naturlig?
- Hvilken rolle ønsker du deg mer av?
- Mangler teamet en rolle du kan fylle?

### Fleksibilitet
Rollen kan endre seg med kontekst. Du kan være utfordrer i én situasjon og harmoniserer i en annen.

> "Finn hvor du tilfører mest verdi. Det er din plass."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Håndtere Utenforskap
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'min-plass-i-teamet' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Når Du Føler Deg Utenfor', 
     '## Smerten Ved Ekskludering

Å føle seg utenfor på jobb er vondt. Og det er ikke innbilning - det har reelle effekter.

### Vanlige Opplevelser
- Ikke bli invitert til samtaler eller møter
- Føle at andre har "insider"-info du mangler
- Tuppen av teamet, ikke kjernen
- "De andre" har noe du ikke har del i

### Effekter
- Redusert motivasjon
- Dårligere prestasjon
- Mer stress og angst
- Vurderer å slutte

### Viktig Å Vite
- Du er ikke alene
- Det betyr ikke at det er noe galt med deg
- Det kan endres
- Du har mer makt enn du tror

> "Utenforskap føles personlig, men det handler ofte om strukturer og tilfeldigheter."', 
     1, 12),
    
    ('Strategier For Å Komme Inn', 
     '## Ta Aktive Steg

Du trenger ikke vente på at andre skal inkludere deg.

### Praktiske Grep

**Oppsøk kontakt:**
- Inviter til kaffe/lunsj
- Stikk innom for en prat
- Spør om du kan bli med på noe

**Vis interesse:**
- Still spørsmål om andres prosjekter
- Tilby hjelp
- Vis nysgjerrighet på personene

**Skap arenaer:**
- Foreslå felles aktiviteter
- Start en lunchgruppe
- Initier faglige samlinger

**Vær tålmodig:**
Relasjoner tar tid. Ikke forvent umiddelbar forandring.

### Husk
Initiativ er ikke desperat - det er profesjonelt og sosialt smart.

> "De fleste venter på at andre skal ta initiativ. Vær den som tar det."', 
     2, 12),
    
    ('Når Problemet Er Større', 
     '## Noen Ganger Er Det Mer Enn Følelse

Hvis utenforskapet er systematisk eller vedvarende, er det mer alvorlig.

### Tegn På Reell Ekskludering
- Du holdes aktivt utenfor informasjon
- Andre snakker over deg i møter
- Du får ikke samme muligheter
- Det er et mønster over tid

### Hva Kan Du Gjøre?

**1. Dokumenter**
Hold oversikt over hendelser - hva skjedde, når, hvem

**2. Snakk med noen**
- En kollega du stoler på
- HR eller leder (hvis trygt)
- Tillitsvalgt eller verneombud

**3. Vurder samtale med den det gjelder**
Noen ganger er folk ubevisste. Et direkte spørsmål kan hjelpe.

**4. Kjenn dine rettigheter**
Du har rett til et forsvarlig psykososialt arbeidsmiljø.

### Grenser
Du skal ikke akseptere systematisk ekskludering. Det er ikke din feil.

> "Å be om hjelp når noe er galt, er styrke - ikke svakhet."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE: Kommunikasjon på Jobb
-- =====================================================

-- MODUL 2: Tydelig Kommunikasjon
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'kommunikasjon-pa-jobb' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Klarhet I Budskap', 
     '## Si Det Du Mener

Uklar kommunikasjon skaper misforståelser, frustrasjon og ekstraarbeid.

### Vanlige Problemer
- For mye omsvøp og innpakning
- Antakelser om at andre forstår
- Vage beskjeder ("gjør det snart")
- Passive formuleringer ("det kunne kanskje vært...")

### Klar Kommunikasjon
**Vær spesifikk:**
- ❌ "Vi trenger å gjøre noe med det"
- ✅ "Kan du oppdatere rapporten innen torsdag?"

**Si det viktigste først:**
- Start med poenget, utdyp etterpå
- Spesielt i e-post og møter

**Bekreft forståelse:**
- "Er vi enige om at...?"
- "Kan du oppsummere hva du skal gjøre?"

> "Jo viktigere budskapet er, jo enklere bør du si det."', 
     1, 10),
    
    ('Gi Og Motta Beskjeder', 
     '## Effektiv Informasjonsutveksling

Informasjon forsvinner mellom mennesker. Slik reduserer du tapet.

### Når Du Gir Beskjed

**Velg riktig kanal:**
| Type | Kanal |
|------|-------|
| Hastesak | Telefon/ansikt |
| Dokumentasjon | E-post |
| Kompleks diskusjon | Møte |
| Rask sjekk | Chat |

**Strukturer budskapet:**
1. Kontekst (hvorfor sier jeg dette)
2. Beskjed (hva er poenget)
3. Handling (hva skal du gjøre)

### Når Du Mottar Beskjed
- Noter det ned
- Bekreft mottaket
- Still oppklarende spørsmål
- Følg opp hvis du er usikker

> "Den som sender, er ansvarlig for at budskapet kommer frem."', 
     2, 12),
    
    ('Skriftlig Kommunikasjon', 
     '## E-post Og Chat

Mye kommunikasjon på jobb er skriftlig. Her er noen prinsipper.

### E-post-Etikette
- **Tydelig emnelinje**: Fortell hva det handler om
- **Kort og konkret**: Respekter andres tid
- **Én ting per e-post**: Lett å finne igjen
- **Tenk før du sender**: Spesielt i frustrasjon

### Sjekkliste Før Sending
- [ ] Er mottaker riktig?
- [ ] Er CC nødvendig?
- [ ] Er beskjeden tydelig?
- [ ] Ville jeg sagt dette ansikt til ansikt?
- [ ] Trenger det egentlig en e-post?

### Chat vs. E-post
**Chat**: Rask, uformell, forsvinner
**E-post**: Dokumentert, formell, søkbar

### Misforståelser
Tekst mangler tonefall. Noe som høres greit ut i ditt hode, kan leses negativt. Når i tvil, ring.

> "Skriv som om alle kan lese det - for det kan de."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Vanskelige Samtaler
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'kommunikasjon-pa-jobb' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Når Samtalen Er Vanskelig', 
     '## Omtrent Alle Gruer Seg

Vanskelige samtaler er... vanskelige. Du er ikke alene om å utsette dem.

### Typer Vanskelige Samtaler
- Si ifra om noe som ikke fungerer
- Be om noe (lønnsøkning, endring)
- Ta opp en konflikt
- Gi negativ tilbakemelding
- Motta negativ tilbakemelding

### Hvorfor Vi Unngår
- Frykt for konfrontasjon
- Usikkerhet om utfall
- Redsel for å såre
- Håp om at det ordner seg selv

### Kostnaden Av Unngåelse
- Problemet vokser
- Frustrasjon bygges opp
- Relasjoner blir overfladiske
- Du bærer på ting unødvendig

> "De samtalene du unngår, er ofte de du trenger mest."', 
     1, 12),
    
    ('Forberede Den Vanskelige Samtalen', 
     '## Planlegging Er Halve Jobben

Vanskelige samtaler går bedre med forberedelse.

### Før Samtalen

**1. Klargjør målet**
- Hva vil du oppnå?
- Hva er minste akseptable utfall?

**2. Samle fakta**
- Hva er fakta vs. din tolkning?
- Hvilke eksempler har du?

**3. Forstå den andre**
- Hva kan være deres perspektiv?
- Hva er deres interesser?

**4. Planlegg åpningen**
- Klar, direkte, respektfull start
- "Jeg trenger å snakke med deg om..."

### Formler
- "Jeg opplever at... og jeg trenger at vi..."
- "Kan vi snakke om...? Det er viktig for meg."
- "Jeg har lagt merke til... Kan du hjelpe meg å forstå?"

> "Forberedelse gir deg mot. Improvisasjon gir deg angst."', 
     2, 12),
    
    ('I Samtalen', 
     '## Gjennomføring

Du er forberedt. Nå er det tid for samtalen.

### Praktiske Tips

**Start tydelig:**
Ikke pakk inn i 10 minutter med small talk. Gå til saken.

**Lytt aktivt:**
Du har forberedt deg, men de har kanskje informasjon du ikke har.

**Hold deg rolig:**
Det er normalt at følelser kommer. Pust. Ta pause om nødvendig.

**Fokuser på fremover:**
Hva skal vi gjøre nå? Ikke bare hva som gikk galt.

### Når Det Eskalerer
- Navngi det: "Jeg merker at dette blir vanskelig"
- Foreslå pause: "Kan vi ta en pause og fortsette i morgen?"
- Hold deg til fakta: Ikke gå i personnivå

### Avslutt Godt
- Oppsummer hva dere er enige om
- Avtal neste steg
- Takk for samtalen (selv om den var vanskelig)

> "Den vanskeligste delen er å starte. Resten kan du håndtere."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- End of migration
