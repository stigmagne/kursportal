-- Migration: 070_complete_team_member_courses_part2.sql
-- Purpose: Add lessons for modules 2 and 3 of remaining team member courses
-- Content in Bokmål

-- =====================================================
-- COURSE: Sunne Grenser på Jobb
-- =====================================================

-- MODUL 2: Si Nei Uten Skyldfølelse
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'sunne-grenser-pa-jobb' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hvorfor "Nei" Er Så Vanskelig', 
     '## Jakten På Å Være Snill

De fleste av oss har lært at det er snilt å si ja. Men hva koster det?

### Grunner Til At Vi Sier Ja
- Vi vil være hjelpsomme
- Vi frykter å skuffe
- Vi er redde for konsekvenser
- Vi overvurderer egen kapasitet
- Det føles uhøflig å si nei

### Kostnaden Av For Mange Ja
- Kvaliteten på alt synker
- Du blir stresset og sliten
- Du bryter løfter (fordi du ikke rekker)
- Bitterhet mot de du sa ja til
- Ingen tid til det viktigste

### Perspektivskift
Et ja til alt er et nei til noe viktig. Hva er det du sier nei til ved å si ja?

> "Nei er ikke avvisning. Det er prioritering."', 
     1, 12),
    
    ('Praktiske Måter Å Si Nei', 
     '## Formuleringer Som Fungerer

Du trenger ikke være uhøflig for å si nei. Her er noen strategier.

### Direktt Nei
"Nei, det har jeg ikke kapasitet til nå."

### Nei Med Alternativ
"Jeg kan ikke gjøre det, men kanskje X kan hjelpe?"

### Nei Med Utsettelse
"Ikke denne uken, men jeg kan se på det i neste."

### Nei Med Avklaring
"Hvis jeg gjør dette, hva skal jeg nedprioritere?"

### Kanskje-Nei
"La meg sjekke kalenderen og komme tilbake til deg."
(Gir deg tid til å vurdere)

### Ting Å Huske
- Du trenger ikke forklare i detalj
- Et nei trenger ikke være evig
- Det blir lettere med øvelse
- De fleste respekterer et tydelig nei

> "Et tydelig nei er bedre enn et halvhjertet ja."', 
     2, 10),
    
    ('Håndtere Skyldfølelse', 
     '## Følelsen Etter

Selv når du vet at nei var riktig, kan skyldfølelsen komme.

### Normaliser Det
- Skyldfølelse er vanlig
- Det betyr ikke at du tok feil
- Det er programmert fra barndommen
- Det blir lettere med tid

### Perspektivskift
Spør deg selv:
- Ville jeg forventet dette av andre?
- Hva ville jeg rådet en venn til?
- Er dette min jobb å fikse?
- Hva er konsekvensen av å si ja?

### Aksept
Du kan ikke gjøre alle fornøyde. Det er ikke mulig. Å prøve vil bare slite deg ut.

### Selvmedfølelse
Det er OK å prioritere egen kapasitet. Du er ikke egoistisk - du er bærekraftig.

> "Du kan ikke hjelpe andre fra bunnen av en utbrent tilstand."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Work-Life Balance
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'sunne-grenser-pa-jobb' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Grensen Mellom Jobb Og Fritid', 
     '## Når Jobben Er Overalt

I en verden med hjemmekontor og konstant tilkobling er grensen mellom jobb og privatliv utvisket.

### Utfordringer
- Epost på telefonen hele tiden
- Jobbing på kveldene "bare litt"
- Tanker om jobb i fritiden
- Aldri helt fri

### Konsekvenser
- Kronisk stress
- Dårligere søvn
- Relasjonsproblemer
- Redusert produktivitet (ja, virkelig)

### Hvorfor Grenser Hjelper
Hjernen trenger hvile for å prestere. Konstant tilkobling gir dårligere resultater, ikke bedre.

> "Du er ikke mer dedikert ved å være tilgjengelig hele tiden. Du er bare mer sliten."', 
     1, 12),
    
    ('Praktiske Grensesettingstips', 
     '## Konkrete Tiltak

Grenser må være konkrete for å virke.

### Tidsgrenser
- Bestem når arbeidsdagen slutter - og hold det
- Ikke sjekk jobbmail etter en viss tid
- Ha faste "off-limits" tider (middag, helger)

### Fysiske Grenser
- Ikke jobb i sengen
- Ha et definert arbeidssted (selv hjemme)
- Skift klær fra jobb til fritid

### Digitale Grenser
- Skru av jobbvarsler etter arbeidstid
- Bruk separate enheter for jobb/privat om mulig
- "Do Not Disturb"-modus

### Kommuniser Grensene
Fortell kolleger og leder:
"Jeg sjekker ikke epost etter kl. 18. Ved hastetilfeller, ring."

> "Grenser du ikke kommuniserer, er grenser ingen respekterer."', 
     2, 10),
    
    ('Bærekraftig Arbeidsliv', 
     '## Langsiktig Tenkning

Det handler ikke om å jobbe minst mulig, men om å jobbe bærekraftig.

### Tegn På Ubærekraft
- Du er konstant sliten, selv etter helger
- Du gleder deg aldri til mandager
- Hobbyer og vennskap lider
- Helsen påvirkes

### Mot Et Bærekraftig Arbeidsliv

**Daglig:**
- Pauser i løpet av dagen
- Skikkelig lunsj (ikke foran PC)
- Markert slutt på dagen

**Ukentlig:**
- Minst én dag helt fri
- Tid til trening eller hobby
- Sosial tid utenfor jobb

**Årlig:**
- Faktisk ferie (ikke bare hjemme)
- Tid til å lade helt om

### Din Rett
Du har faktisk rett til hvile og fritid. Det er ikke et privilegium.

> "Et bærekraftig arbeidsliv er ikke luksus. Det er et fundament for alt annet."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE: Håndtere Konflikt
-- =====================================================

-- MODUL 2: Ta Opp Vanskelige Ting
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'handtere-konflikt' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Den Første Samtalen', 
     '## Å Ta Det Opp

De fleste konflikter vokser fordi ingen tar initiativ til å snakke.

### Før Du Snakker
- Er dette faktisk et problem? (Noen ting går over av seg selv)
- Har du avkjølt deg tilstrekkelig?
- Hva vil du oppnå?

### Åpningen
Ikke start med anklager. Start med nysgjerrighet.

**Gode åpninger:**
- "Kan vi snakke om noe? Jeg opplever at..."
- "Jeg vil gjerne forstå perspektivet ditt på..."
- "Har du et øyeblikk? Det er noe jeg trenger å ta opp."

**Dårlige åpninger:**
- "Vi må snakke om feilen din"
- "Du gjør alltid..."
- "Alle mener at du..."

### Setting
- Privat (ikke i plenum)
- Tid nok (ikke mellom møter)
- Nøytral grunn hvis mulig

> "Hvordan du starter samtalen, predikerer ofte hvordan den slutter."', 
     1, 12),
    
    ('Holde Samtalen Konstruktiv', 
     '## Underveis I Diskusjonen

Selv gode samtaler kan spore av. Her er hvordan du holder kursen.

### Teknikker

**Jeg-språk:**
"Jeg føler meg..." i stedet for "Du gjør..."

**Fokus på adferd, ikke person:**
"Når du avbryter i møter" vs "Du er respektløs"

**Spør, ikke anta:**
"Var det slik det var ment?" i stedet for "Du mente tydeligvis..."

**En ting om gangen:**
Ikke ta opp 5 gamle saker samtidig

### Når Det Blir Vanskelig
- Ta en pustepause
- Navngi det: "Jeg merker at vi begge blir frustrert"
- Foreslå pause: "Kan vi fortsette i morgen?"

### Feller Å Unngå
- Å vinne diskusjonen (dette er ikke en konkurranse)
- Å bevise at du har rett
- Å grave i fortiden

> "Målet er ikke å vinne, men å forstå - og å bli forstått."', 
     2, 12),
    
    ('Når Dere Ikke Blir Enige', 
     '## Akseptere Uenighet

Ikke alle konflikter har en løsning der alle er fornøyde. Og det er OK.

### Typer Utfall
- **Enighet**: Dere finner en felles løsning ✓
- **Kompromiss**: Begge gir litt ✓
- **Aksept**: Dere er uenige, men forstår hverandre ✓
- **Eskalering**: Trenger ekstern hjelp →

### Når Eskalere
- Dere står fast etter flere forsøk
- Det påvirker arbeidet
- Det er prinsipielle spørsmål
- Én part nekter å delta i samtale

### Hvem Å Gå Til
- Leder (med fokus på løsning, ikke skyldfølelse)
- HR
- Verneombud
- Ekstern megler

### Akseptere Uenighet
Noen ganger må du leve med at dere ser ulikt på ting. Det betyr ikke at du tapte eller at dere ikke kan samarbeide.

> "Uenighet trenger ikke bety konflikt. Konflikt trenger ikke bety krise."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Gjenoppbygging
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'handtere-konflikt' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Etter Stormen', 
     '## Relasjonen Etterpå

En konflikt etterlater seg noe. Spørsmålet er hva du gjør med det.

### Vanlige Feil
- Late som ingenting skjedde
- Unngå personen helt
- Holde nag
- Snakke om det til alle andre

### Hvorfor Gjenoppbygging Betyr Noe
- Dere skal fortsatt jobbe sammen
- Ting som ignoreres, gror
- Andre på teamet merker spenningen
- Det er slitsomt å bære på konflikter

### Første Steg
Ta initiativ til normalisering:
- Hils som vanlig
- Inkluder personen i samtaler
- Vis at du er forbi det (selv om det fortsatt stikker litt)

> "Gjenoppbygging er ikke å late som det aldri skjedde. Det er å bestemme seg for å gå videre."', 
     1, 10),
    
    ('Reparere Tillit', 
     '## Når Noe Ble Ødelagt

Etter noen konflikter er tilliten skadet. Den kan gjenoppbygges, men det tar tid.

### Tillitsbyggende Handlinger

**Hold ordene dine:**
Gjør det du sier du skal gjøre. Små ting teller.

**Vær konsistent:**
Ikke hot-and-cold. Forutsigbarhet bygger trygghet.

**Vis god vilje:**
Små gester som viser at du vil at dette skal fungere.

**Gi tid:**
Tillit bygges ikke over natten. Vær tålmodig.

### Når Du Har Sviktet Andre
- Innrøm det tydelig
- Unngå "ja, men..."
- Vis gjennom handling at det ikke gjentar seg

### Når Andre Har Sviktet Deg
- Gi rom for at folk kan endre seg
- Sett grenser for hva du er villig til å akseptere
- Beskytt deg selv, men ikke lukk helt

> "Tillit er ikke binær. Den gjenoppbygges handling for handling."', 
     2, 12),
    
    ('Lære Av Konflikten', 
     '## Hva Kan Du Ta Med Deg?

Konflikter suger. Men de kan også lære deg noe verdifullt.

### Spørsmål For Refleksjon

**Om deg selv:**
- Hva trigget meg i denne situasjonen?
- Hva gjorde jeg som eskalerte?
- Hva skulle jeg gjort annerledes?
- Hva sier dette om mine grenser/verdier?

**Om dynamikken:**
- Var det et mønster her?
- Hva handlet dette egentlig om?
- Hva kan vi gjøre for å unngå lignende situasjoner?

### Forebygging
- Klarere kommunikasjon om forventninger
- Tidligere intervensjon neste gang
- Bedre konflikttoleranse generelt

### Fra Sår Til Styrke
Folk som har håndtert konflikter godt, blir bedre på det. Hver konflikt er trening.

> "Konflikter du overlever, gjør deg bedre rustet til de neste."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE: Vekst og Mestring
-- =====================================================

-- MODUL 2: Lære av Feil
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'vekst-og-mestring' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Feil Som Feedback', 
     '## Data, Ikke Dom

Hva om du så på feil som informasjon, ikke nederlag?

### Tradisjonelt Syn
Feil = Jeg er dårlig
Feil = Noe å skjule
Feil = Bevis på manglende evner

### Growth-Syn
Feil = Læremulighet
Feil = Informasjon om hva som ikke virker
Feil = Et uunngåelig steg på veien

### Eksempler
- Edison "fant 1000 måter som ikke fungerte"
- Idrettsutøvere analyserer tap mer enn seire
- Forskere feiler oftere enn de lykkes

### Spørsmål Å Stille
- Hva forteller denne feilen meg?
- Hva gjør jeg annerledes neste gang?
- Hvem kan hjelpe meg forstå dette bedre?

> "Feil er ikke motsatt av suksess. De er en del av den."', 
     1, 12),
    
    ('Post-Mortem Uten Skam', 
     '## Analysere Uten Å Dømme

Når noe går galt, kan vi reagere med skam eller med nysgjerrighet. Nysgjerrighet er mer nyttig.

### Strukturert Feillæring

**1. Hva skjedde?**
Beskriv hendelsen objektivt. Hvem, hva, når.

**2. Hva var planen?**
Hva forventet du skulle skje?

**3. Hva gikk annerledes?**
Hvor skilte virkeligheten seg fra planen?

**4. Hvorfor?**
Hva var rotårsakene? (Ikke "fordi jeg er dum")

**5. Hva lærer jeg?**
Hvilket prinsipp kan jeg ta med?

**6. Hva gjør jeg neste gang?**
Konkret endring i handling.

### Team-Post-Mortem
Samme prosess, men fokus på systemet, ikke individer. "Hvordan sviktet systemet?" ikke "Hvem er skyldig?"

> "En god post-mortem ender med læring, ikke skyld."', 
     2, 12),
    
    ('Dele Feil Med Andre', 
     '## Sårbarhetens Kraft

Å dele feil kan føles risikabelt. Men det har store fordeler.

### Hvorfor Dele
- Andre kan lære av dine feil
- Det normaliserer at feil skjer
- Det bygger tillit
- Du fremstår som modent og selvinnsiktsfullt

### Hvordan Dele
- **Feil + læring**: Ikke bare feil
- **Riktig forum**: Ikke alt til alle
- **Eierskap**: Ikke skyld på andre
- **Fremover**: Fokus på hva du lærte

### Eksempel
✗ "Jeg rotet det til igjen, jeg er elendig"
✓ "Jeg gjorde en feil med X. Det jeg lærte var at Y. Neste gang vil jeg Z."

### Når Ikke Dele
- Når det involverer andres konfidensielle info
- Når det er åpenbart strategispill
- Når det er ferskt og du fortsatt er i sjokk

> "Å dele feil med visdom er styrke, ikke svakhet."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Din Karriereutvikling
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'vekst-og-mestring' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Eierskap Til Egen Vekst', 
     '## Din Karriere Er Ditt Ansvar

Venter du på at noen skal utvikle deg? Du kan vente lenge.

### Realiteten
- Arbeidsgiver har interesse i din utvikling - men også tusen andre ting
- Din leder kan mye - men kan ikke lese tanker
- HR har programmer - men de er generiske

### Ditt Ansvar
- Vite hva du vil
- Si fra om behov
- Oppsøke muligheter
- Sette grenser for egen vekst

### Praktiske Steg
1. **Kartlegg nåsituasjonen**: Hva kan du? Hva liker du? Hva er du god på?
2. **Definer retningen**: Hvor vil du? (Ikke for konkret, men en retning)
3. **Identifiser gapene**: Hva trenger du for å komme dit?
4. **Lag en plan**: Konkrete steg du kan ta
5. **Snakk med leder**: Vær tydelig på dine ambisjoner

> "Ingen bryr seg mer om karrieren din enn du."', 
     1, 12),
    
    ('Strekkmål', 
     '## Akkurat Utenfor Komfortsonen

Vekst skjer ikke i komfortsonen. Men panikksonen hjelper heller ikke.

### Tre Soner
1. **Komfortsone**: Trygt, kjent, lite vekst
2. **Strekksone**: Utfordrende men håndterbart - her skjer veksten
3. **Panikksone**: Overveldende, blokkerer læring

### Hva Er Et Strekkmål?
- Noe du ikke kan allerede
- Noe du tror du kan lære
- Noe litt skummelt, men spennende
- Noe som vil gjøre deg bedre

### Eksempler På Strekkmål
- Ta ordet i et stort møte
- Lære en ny ferdighet
- Lede et prosjekt for første gang
- Gi presentasjon til ledelsen
- Si fra om noe vanskelig

### Hvordan Strekke
- Små steg, gradvis økning
- Søk støtte og feedback
- Aksepter at det vil føles ukomfortabelt
- Feir fremgang, ikke bare ferdig resultat

> "Hvis alt du gjør er lett, vokser du ikke."', 
     2, 12),
    
    ('Finne Mentorer Og Støtte', 
     '## Du Trenger Ikke Gjøre Det Alene

De fleste suksessfulle mennesker har hatt hjelp langs veien.

### Typer Støtte

**Mentor:**
Erfaren person som veileder deg

**Coach:**
Profesjonell som hjelper deg utvikle deg selv

**Sponsor:**
Noen i maktposisjon som fremmer din karriere

**Peer network:**
Kolleger på samme nivå du kan lære med

### Hvordan Finne Mentorer
- Se etter folk du beundrer
- Be om en kaffe for å lære
- Vær konkret om hva du vil vite
- Respekter tiden deres
- Gi noe tilbake

### Bygg Nettverk
- Interne nettverk og komiteer
- Bransjeorganisasjoner
- Alumni-nettverk
- Konferanser og fagdager

### Hovedregel
Be om hjelp. De fleste vil hjelpe, men de kan ikke se at du trenger det.

> "De som ber om hjelp, kommer lenger enn de som prøver alene."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- End of migration
