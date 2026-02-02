-- Migration: 072_complete_parent_courses_part2.sql
-- Purpose: Add lessons for modules 2 and 3 of remaining parent courses
-- Content in Bokmål

-- =====================================================
-- COURSE: Foreldres Sorg (modul 2 og 3 mangler)
-- =====================================================

-- MODUL 2: Kronisk Sorg
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'foreldres-sorg' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Sorg I Bølger', 
     '## Den Kommer Tilbake

Kronisk sorg kjennetegnes av at den kommer i bølger. Du kan ha det bra i uker, så treffer den igjen.

### Vanlige Triggere
- Milepæler (skolestart, bursdager, konfirmasjon)
- Sammenligning med andre familier
- Endringer i barnets tilstand
- Årstider og høytider
- Slitasje over tid

### Dette Er Normalt
- Sorg "løses" ikke en gang for alle
- Gode perioder betyr ikke at du er ferdig
- Dårlige perioder betyr ikke at du går bakover

### Strategi
1. Gjenkjenn at bølgen kommer
2. Ikke kjemp imot - la den passere
3. Ha selvmedfølelse
4. Vit at den går over

> "Sorg er ikke lineær. Den er mer som tidevann."', 
     1, 12),
    
    ('Leve Med Uforutsigbarhet', 
     '## Når Fremtiden Er Usikker

Kronisk sykdom betyr ofte kronisk usikkerhet.

### Hva Gjør Usikkerhet Med Oss?
- Konstant beredskap (høy stressrespons)
- Vanskeligheter med å planlegge
- Angst for fremtiden
- Følelse av manglende kontroll

### Strategier

**Fokuser på det du kan kontrollere:**
- Dagens handlinger
- Relasjoner
- Din egen selvivaretagelse

**Aksepter det du ikke kan kontrollere:**
- Sykdomsforløpet
- Andre menneskers reaksjoner
- Fremtiden

**Mindfulness:**
- Vær i nuet
- En dag om gangen
- Bekymring hjelper ikke

### Mantra
"I dag er det vi vet. I dag kan jeg håndtere."', 
     2, 12),
    
    ('Sorgstøtte', 
     '## Du Trenger Ikke Være Alene

Det finnes hjelp for foreldre som sørger.

### Profesjonell Hjelp
- Psykolog med erfaring fra kronisk sykdom
- Sorggrupper for foreldre
- Familierådgivning

### Pårørendetilbud
- Pårørendesenteret
- Sykehusenes pårørendetilbud
- Diagnoseforeningers støttegrupper

### Når Søke Hjelp?
- Når sorgen hindrer deg i å fungere
- Når du ikke finner glede i noe
- Når tankene blir mørke
- Når du føler deg helt alene

### Barrieren
Mange tenker: "Andre har det verre. Jeg bør klare dette."

Sannheten: Alle fortjener støtte. Din smerte er reell.

> "Å be om hjelp er ikke å gi opp. Det er å ta vare på deg selv."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Finne Glede
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'foreldres-sorg' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Glede Og Sorg Samtidig', 
     '## Det Er Ikke Enten Eller

Mange foreldre føler skyld når de opplever glede.

### Vanlige Tanker
- "Hvordan kan jeg le når barnet mitt er syk?"
- "Jeg fortjener ikke å ha det bra"
- "Det føles feil å være glad"

### Sannheten
- Du kan elske barnet ditt og ha det vanskelig
- Du kan sørge og være glad - samtidig
- Glede tar ikke bort sorgen
- Sorg tar ikke bort retten til glede

### Tillat Deg Selv
Øyeblikk av glede:
- Er ikke forræderi
- Gir deg energi til å fortsette
- Modellerer for barna at livet kan være godt
- Er nødvendig for mental helse

> "Glede og sorg er ikke motsetninger. De lever side om side."', 
     1, 12),
    
    ('Små Gledestunder', 
     '## Bevisst Å Finne Det Gode

I en travel, bekymringsfull hverdag må glede noen ganger oppsøkes aktivt.

### Daglige Mikrogleder
- Første slurk kaffe om morgenen
- Barnets latter
- Et øyeblikk i solen
- En god samtale
- Din favorittmusikk

### Øvelse: Tre Gode Ting
Hver kveld, skriv ned tre ting som var bra i dag. Selv på de verste dagene finnes det noe.

### Plan Glede Inn
- Én ting du gleder deg til hver uke
- Aktiviteter som gir energi
- Tid med mennesker som løfter deg
- Hobbyer du liker (selv 15 min)

### Ikke Vent
Ikke vent til "ting blir bedre". Finn glede nå.

> "Glede er ikke et mål man ankommer. Det er øyeblikk man samler."', 
     2, 12),
    
    ('Mening Midt I Det Vanskelige', 
     '## Finne Formål

Mange foreldre finner at deres erfaring gir dem noe verdifullt.

### Mulige Kilder Til Mening
- Styrket relasjon til familien
- Dypere empati for andre
- Klarere prioriteringer i livet
- Fellesskap med andre i samme situasjon
- Mulighet til å hjelpe andre

### Post-Traumatisk Vekst
Forskning viser at mange som gjennomgår vanskelige ting, opplever positiv vekst:
- Økt personlig styrke
- Nye muligheter
- Dypere relasjoner
- Større takknemlighet
- Spirituell utvikling

### Viktig Forbehold
Dette er IKKE å si at sykdommen er "en velsignelse i forkledning". Det er vondt og vanskelig. Men mening kan vokse fra det vanskelige.

> "Du velger ikke det som skjer. Du kan velge hva du gjør med det."', 
     3, 15)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE: Søsken som Ressurs (modul 2 og 3 mangler)
-- =====================================================

-- MODUL 2: Søskenrelasjonen
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'sosken-som-ressurs' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Styrke Båndet', 
     '## Søsken For Livet

Søskenrelasjonen er ofte den lengste relasjonen i livet. Verdt å investere i.

### Utfordringer I Deres Relasjon
- Ubalanse i oppmerksomhet
- Følelse av urettferdighet
- Ulike roller (omsorgsgiver vs. mottaker)
- Vanskelige følelser overfor hverandre

### Hva Du Kan Gjøre

**La dem ha tid sammen:**
- Uten foreldre som buffer
- Aktiviteter de begge liker
- Vanlige søskenaktiviteter (leke, krangle, kose)

**Normaliser konflikter:**
- Søsken krangler - det er normalt
- Ikke alltid beskytt det syke barnet
- Lær konfliktløsning

**Felles opplevelser:**
- Familieaktiviteter alle kan delta i
- Ferier og tradisjoner
- Positive minner sammen

> "Søskenrelasjon er ikke automatisk. Den må pleies."', 
     1, 12),
    
    ('Håndtere Misunnelse', 
     '## Når Det Friske Barnet Er Misunnelig

Det friske barnet kan bli misunnelig på oppmerksomheten søskenet får.

### Vanlig Uttrykk
- "Dere bryr dere bare om [søsken]"
- "Det er alltid [søsken] som bestemmer"
- "Jeg vil også være syk"
- Oppmerksomhetssøkende adferd

### Hvordan Respondere

**Ikke avvis:**
✗ "Du vet jo at vi elsker dere like mye"
✓ "Jeg hører at du føler deg oversett. Fortell meg mer."

**Anerkjenn virkeligheten:**
"Du har rett i at vi bruker mye tid på [søsken]. Det må være vanskelig for deg."

**Men sett grenser:**
"Samtidig trenger [søsken] ekstra hjelp akkurat nå. Det betyr ikke at du er mindre viktig."

### Handling Over Ord
Vis med handling, ikke bare ord, at de er viktige:
- Prioriter tid med dem
- Feir deres prestasjoner
- Lytt til deres verden

> "Misunnelse er ofte maskert savn. Se savnet."', 
     2, 12),
    
    ('Søskensamtaler', 
     '## Snakk Med Dem Om Dem

Søsken trenger å snakke - men ikke alltid om sykdommen.

### Balanse I Samtaler
Snakk OM søskenets situasjon:
- "Hvordan er det å være [navn]s søsken?"
- "Hva tenker du på når vi er på sykehuset?"

MEN også helt uavhengig av den:
- "Fortell meg om vennene dine"
- "Hva drømmer du om?"
- "Hva liker du å gjøre?"

### Sjekk Inn Regelmessig
- "Hvordan har du det - egentlig?"
- "Er det noe du vil at jeg skal vite?"
- "Føler du deg sett og hørt i familien?"

### De Vanskelige Samtalene
Noen ganger må du ta opp det vanskelige:
- "Jeg vet at du har tatt mye ansvar. Hvordan er det?"
- "Du virker sliten. Snakker vi for lite om hvordan du har det?"

> "Det friske barnet trenger å bli spurt - ikke bare om søskenet."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Forebygge Belastning
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'sosken-som-ressurs' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Tegn På For Mye Ansvar', 
     '## Når Søsken Blir Unge Omsorgsgivere

Noen søsken tar på seg for mye ansvar. Dette kalles "parentifisering".

### Advarselstegn

**Praktisk:**
- Gjør husarbeid som er for mye for alderen
- Passer på søsken når foreldre er borte
- Tar ansvar for medisiner/behandling

**Emosjonelt:**
- Trøster foreldrene
- Skjuler egne problemer for å ikke belaste
- Føler seg ansvarlig for familiens fungering
- Bekymrer seg konstant for familien

### Konsekvenser
- Går glipp av vanlig barndom
- Økt risiko for angst/depresjon
- Vansker med å sette egne grenser
- Kan føre til utbrenthet

> "Barn skal få være barn. Også de som vil hjelpe."', 
     1, 12),
    
    ('Sett Grenser', 
     '## Beskytt Barndommen Deres

Det er din jobb som forelder å beskytte det friske barnet fra for mye.

### Praktiske Grep

**Definer klart:**
- Hva er søskenets oppgaver (aldersriktig)
- Hva er IKKE deres ansvar
- Når de kan si nei

**Sørg for fritid:**
- Aktiviteter uavhengig av familien
- Venner og sosialt liv
- Hobbyer og interesser

**Alternativ hjelp:**
- Få hjelp utenfra i stedet for fra barnet
- Avlastning, støttekontakt
- Ikke la barnet fylle hull i omsorgssystemet

### Den Vanskelige Samtalen
"Jeg vet at du gjerne vil hjelpe. Og det er snilt. Men du er barn, og din jobb er å leve ditt liv."

> "Å sette grenser for hjelpen de gir, er å beskytte dem."', 
     2, 12),
    
    ('Støtte Utenfra For Søsken', 
     '## De Trenger Også Et Nettverk

Søsken trenger støtte fra andre enn foreldrene.

### Viktige Voksne
- Besteforeldre
- Tanter/onkler
- Trenere, lærere
- Venners foreldre

### Si Fra Til Skolen
Informer skolen om hjemmesituasjonen:
- Læreren kan være ekstra oppmerksom
- Helsesykepleier kan være ressurs
- Tilrettelegging ved behov

### Søskengrupper
Mange steder finnes grupper for søsken:
- Sykehusenes lærings- og mestringssentre
- Diagnoseforeninger
- Pårørendesenteret

### Profesjonell Hjelp
Vurder psykolog/terapeut for søsken hvis:
- De strever over tid
- Atferdsendringer
- Angst eller depresjon
- De ber om det

> "Det tar en landsby å oppdra et barn. Spesielt et barn i en sårbar situasjon."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- End of migration
