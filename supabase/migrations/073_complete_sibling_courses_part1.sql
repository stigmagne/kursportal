-- Migration: 073_complete_sibling_courses_part1.sql
-- Purpose: Add lessons for modules 2 and 3 of sibling courses
-- Content in Bokmål

-- =====================================================
-- COURSE: Min Stemme, Mine Grenser (modul 3 mangler)
-- =====================================================

-- MODUL 3: Vanskelige Samtaler
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'min-stemme-mine-grenser' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Forberede Samtalen', 
     '## Før Du Tar Det Opp

Vanskelige samtaler med foreldre og familie krever forberedelse.

### Før Samtalen
1. **Definer hva du vil oppnå**: Hva er målet ditt?
2. **Velg riktig tidspunkt**: Ikke midt i en krise
3. **Forbered deg emosjonelt**: Grounding først
4. **Skriv ned hovedpunktene**: Så du ikke glemmer

### Hva Du Vil Si
Bruk jeg-budskap:
"Jeg har tenkt mye på noe jeg vil dele med deg..."
"Det er viktig for meg at du vet hvordan jeg har det..."

### Forventningsstyring
Du kan kontrollere hva du sier, ikke hvordan det mottas. Forbered deg på ulike reaksjoner.

> "En vanskelig samtale tatt er bedre enn en vanskelig samtale unngått."', 
     1, 12),
    
    ('Navigere Vanskelige Reaksjoner', 
     '## Når De Ikke Tar Det Godt

Foreldre kan reagere defensivt på dine behov.

### Vanlige Reaksjoner
- **Bagatellisering**: "Du har det jo så bra"
- **Skyldfølelse**: "Jeg gjorde så godt jeg kunne"
- **Sinne**: "Hvordan kan du si det?"
- **Tårer**: Rollen snus - du må trøste dem

### Hvordan Håndtere

**Hold fast ved ditt:**
"Jeg hører at dette er vanskelig. Men det er viktig for meg at du hører dette."

**Ikke ta ansvar for deres følelser:**
Du kan ha medfølelse uten å trekke tilbake det du sa.

**Ta pause om nødvendig:**
"La oss ta en pause og snakke mer om dette senere."

> "Deres reaksjon er ikke din å fikse. Din sannhet er din å si."', 
     2, 15),
    
    ('Etter Samtalen', 
     '## Bearbeide Etterpå

Vanskelige samtaler setter spor.

### Umiddelbart Etter
- Gi deg selv tid til å lande
- Grounding-teknikker
- Skriv i journal
- Snakk med noen du stoler på

### De Neste Dagene
- Forvent at følelsene svinger
- Ikke forvent umiddelbar endring
- Anerkjenn at du gjorde noe modig

### Når Samtalen Ikke Gikk Bra
Ikke gi opp. Noen samtaler må tas flere ganger:
- Gi det tid
- Prøv igjen med ny tilnærming
- Vurder profesjonell hjelp

### Når Du Blir Hørt
Feir det! Selv om det ikke er perfekt.

> "Å bli hørt er ikke en engangshendelse. Det er en prosess."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE: Hvem Er Jeg? (modul 2 og 3 mangler)
-- =====================================================

-- MODUL 2: Mine Drømmer
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'hvem-er-jeg' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Tillatelse Til Å Drømme', 
     '## Du Har Lov Til Egne Drømmer

Mange søsken har lært å sette egne ønsker til side.

### Vanlige Tankemønstre
- "Jeg burde ikke fokusere på meg selv"
- "Mine drømmer er ikke viktige nok"
- "Det er egoistisk å ville noe for seg selv"
- "Jeg har ikke tid til drømmer"

### Sannheten
- Dine drømmer gjør deg ikke til et dårlig menneske
- Å forfølge dine mål kan inspirere andre
- Du fortjener et liv som gir deg glede

### Øvelse: Drømmepause
Lukk øynene. Hvis ingenting hindret deg - ingen forpliktelser, ingen penger, ingen andres meninger - hva ville du gjort?

> "Drømmer er ikke luksus. De er veiledning."', 
     1, 12),
    
    ('Finne Tilbake Til Deg Selv', 
     '## Hvem Var Du Før Rollen?

Søskenrollen kan ha overskygget hvem du egentlig er.

### Refleksjonsøvelse: Barndomsminner
1. Hva likte du å gjøre som liten?
2. Hva drømte du om å bli?
3. Hvilke aktiviteter ga deg energi?
4. Hva sa folk at du var god på?

### Nuet
- Hva gir deg glede nå?
- Hva føles meningsfylt?
- Hvilke mennesker løfter deg?
- Når glemmer du tiden?

### Finne Tråden
Ofte er det en rød tråd fra fortiden til nå. Interesser som ble glemt, men som fortsatt er der.

> "Du er mer enn rollen du fikk. Du er også den du aldri fikk lov til å være."', 
     2, 15),
    
    ('Visualisere Fremtiden', 
     '## Skap Et Bilde Av Det Du Vil

NLP-teknikk: Visualisering aktiverer de samme hjerneområdene som faktisk gjennomføring.

### Fremtidsvisualisering
1. Sett deg komfortabelt, lukk øynene
2. Se for deg et tidspunkt 5 år frem i tid
3. Forestill deg at alt har gått bra
4. Hvor er du? Hva gjør du? Hvem er rundt deg?
5. Hvordan føles det i kroppen?

### Skriv Det Ned
Beskriv denne fremtiden i presens:
"Jeg bor i... Jeg jobber med... Jeg føler meg..."

### Første Steg
Hva er én liten ting du kan gjøre i dag som bringer deg nærmere dette bildet?

> "Fremtiden skapes av det du gjør i dag."', 
     3, 15)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Mitt Støttenettverk
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'hvem-er-jeg' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hvorfor Du Trenger Folk', 
     '## Ingen Klarer Alt Alene

Mange søsken har lært å være selvstendige. Det er en styrke, men også en begrensning.

### Utfordringer For Søsken
- Vanskelig å be om hjelp
- Føler seg annerledes enn andre
- Lært å ikke være til byrde
- Prioriterer andres behov over egne

### Forskning Viser
Sosial støtte er en av de viktigste faktorene for:
- Mental helse
- Fysisk helse
- Livsmestring
- Resiliens

### Refleksjon
Hvem i livet ditt kan du virkelig stole på? Bruker du dem?

> "Styrke er ikke å klare alt selv. Det er å vite når du trenger andre."', 
     1, 12),
    
    ('Typer Støtte', 
     '## Ikke Alle Trenger Å Forstå Alt

Du trenger ulike mennesker for ulike behov.

### Støttekategorier

**De som forstår:**
- Andre søsken
- Støttegrupper
- Terapeuter med erfaring

**De som elsker deg:**
- Venner og partner
- Familie som ser deg
- Kolleger som bryr seg

**De som inspirerer:**
- Mentorer
- Forbilder
- Mennesker som utfordrer deg

**De som bare er morsomme:**
- Folk du ler med
- Aktivitetsvenner
- Lett selskap

### Kartlegging
Hvem har du i hver kategori? Hvor er hullene?', 
     2, 12),
    
    ('Bygge Og Vedlikeholde', 
     '## Vennskap Krever Innsats

Relasjoner oppstår ikke av seg selv. De må pleies.

### Starte Nye Relasjoner
- Delta i aktiviteter du liker
- Si ja til invitasjoner
- Vær den som tar initiativ
- Vær tålmodig - tillit tar tid

### Vedlikeholde Relasjoner
- Regelmessig kontakt (ikke bare i kriser)
- Spør og lytt - ikke bare snakk om deg selv
- Vær pålitelig
- Feir andres seire

### Gi Og Ta
Sunt vennskap har balanse:
- Du kan be om støtte
- Du kan gi støtte tilbake
- Ingen teller nøyaktig

> "De beste vennskapene er de der begge føler seg rikere."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE: Sorg og Aksept (modul 2 og 3 mangler)
-- =====================================================

-- MODUL 2: Bearbeide Tap
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'sorg-og-aksept' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Sorgarbeid', 
     '## Gi Sorgen Rom

Sorg som ignoreres, forsvinner ikke. Den kommer ut på andre måter.

### Tegn På Ubearbeidet Sorg
- Plutselige følelsesutbrudd
- Nummenhet eller distanse
- Kronisk tristhet eller irritabilitet
- Fysiske symptomer uten forklaring
- Unngåelse av minner

### Bearbeiding
- Anerkjenn tapene
- La deg selv føle
- Del med noen du stoler på
- Gi det tid

### Skriveøvelse
Skriv et brev til deg selv som barn. Fortell barnet hva du tapte, og at det er lov å sørge.

> "Sorg er ikke noe du kommer over. Det er noe du går gjennom."', 
     1, 15),
    
    ('Ritualer For Sorg', 
     '## Markere Det Som Var

Ritualer hjelper oss å bearbeide tap på en konkret måte.

### Ideer Til Sorg-ritualer

**Skriving:**
- Brev til fortiden
- Journal om det du mistet
- Poesi eller kreativ skriving

**Fysiske markeringer:**
- Tenne lys på bestemte dager
- Plante noe som blomstrer
- Lage et minnealbum

**Bevegelse:**
- Gå en tur med intensjon om å sørge
- Dans ut følelsene
- Yoga for sorg

### Årlige Markeringer
Noen velger å markere bestemte datoer - ikke for å bli værende i sorgen, men for å anerkjenne den.

> "Ritualer gir sorgen en plass, så den ikke tar all plass."', 
     2, 12),
    
    ('Profesjonell Hjelp', 
     '## Når Du Trenger Mer

Noen ganger trenger sorg profesjonell støtte.

### Når Oppsøke Hjelp
- Sorgen blokkerer hverdagen
- Du føler deg fast
- Tankene blir mørke
- Isolasjon over tid
- Selvskading eller avhengighet

### Typer Hjelp
- **Psykolog**: Individuell terapi
- **Sorggrupper**: Delt erfaring
- **Traumeterapi**: EMDR, Somatisk terapi
- **Psykiater**: Hvis medisiner er aktuelt

### Det Er Ikke Svakhet
Å be om hjelp er modent og klokt. Du fortjener støtte.

> "Terapi er ikke for de svake. Det er for de som vil vokse."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Finne Aksept
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'sorg-og-aksept' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hva Aksept Er', 
     '## Aksept Er Ikke Det Samme Som Å Like Det

Mange misforstår aksept.

### Aksept Er IKKE:
- Å synes det var greit
- Å glemme
- Å tilgi alt
- Å late som det ikke påvirket deg

### Aksept ER:
- Å slutte å kjempe mot virkeligheten
- Å anerkjenne at det skjedde
- Å slippe ønsket om en annen fortid
- Å bruke energien på nåtiden

### NLP-perspektiv
Du kan ikke endre det som skjedde. Du kan endre forholdet ditt til det.

> "Aksept er ikke at det var OK. Aksept er at det var."', 
     1, 12),
    
    ('Prosessen Mot Aksept', 
     '## Aksept Tar Tid

Ingen kan tvinge seg til aksept. Det skjer gradvis.

### Steg På Veien
1. **Fornektelse**: "Det var ikke så ille"
2. **Sinne**: "Det var urettferdig"
3. **Forhandling**: "Hvis bare..."
4. **Sorg**: "Jeg mistet noe viktig"
5. **Aksept**: "Det var slik det var"

### Tips For Prosessen
- Ikke forhast deg
- La deg gå frem og tilbake
- Vær tålmodig med deg selv
- Feir små fremskritt

### Aksept-affirmarer
"Jeg aksepterer det som var, og fokuserer på det som er."
"Fortiden min formet meg, men den definerer meg ikke."

> "Aksept er ikke et mål du når. Det er en praksis du øver."', 
     2, 15),
    
    ('Leve Videre', 
     '## Etter Aksept

Aksept frigjør energi til å leve.

### Hva Kommer Etter
- Mer tilstedeværelse i nuet
- Mindre reaktivitet til fortiden
- Frihet til å velge fremover
- Mulighet for tilgivelse (hvis du vil)

### Post-traumatisk Vekst
Mange som har vært gjennom vanskelige ting, opplever vekst:
- Styrket empati
- Klarere prioriteringer
- Dypere relasjoner
- Større takknemlighet

### Din Nye Historie
Du er ikke lenger et offer for fortiden. Du er forfatteren av din fremtid.

> "Dine sår er bevis på at du overlevde. Dine arr er bevis på at du helbredet."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- End of migration
