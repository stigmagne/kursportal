-- Migration: 071_complete_parent_courses_part1.sql
-- Purpose: Add lessons for modules 2 and 3 of parent courses
-- Content in Bokmål

-- =====================================================
-- COURSE: Kommunikasjon i Familien (modul 2 og 3 mangler)
-- =====================================================

-- MODUL 2: Lytte Aktivt
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'kommunikasjon-i-familien' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Lytte Med Hele Deg', 
     '## Mer Enn Å Høre Ord

Barn kommuniserer ikke bare med ord. Spesielt søsken som har lært å "ikke være til bry".

### Lytt Etter:
- **Ordene**: Hva sier de?
- **Tonen**: Hvordan sier de det?
- **Kroppen**: Hva uttrykker kroppsspråket?
- **Stilheten**: Hva sier de IKKE?

### Når Barn Tier
Stillhet kan bety:
- "Jeg vet ikke hvordan jeg skal si det"
- "Jeg vil ikke belaste deg"
- "Jeg er redd for reaksjonen din"
- "Jeg tror ikke du vil forstå"

### Din Respons
Ikke press. Vis at du er tilgjengelig:
"Jeg er her når du er klar til å snakke."

> "Barn snakker når de føler seg trygge. Din jobb er å skape tryggheten."', 
     1, 12),
    
    ('Spørsmål Som Åpner', 
     '## Unngå Ja/Nei-Feller

Vanlige foreldre-spørsmål som lukker samtaler:
- "Hadde du det fint i dag?" → "Ja"
- "Er alt bra?" → "Ja"
- "Var det noe spesielt?" → "Nei"

### Åpne Spørsmål
- "Hva var det beste som skjedde i dag?"
- "Hvem lekte du med? Hva gjorde dere?"
- "Hvis du kunne endre én ting ved i dag, hva ville det vært?"
- "Fortell meg noe du tenkte på i dag."

### For Vanskelige Tema
- "Hvordan er det å være søster/bror til [navn]?"
- "Hva tenkte du da vi måtte på sykehuset?"
- "Er det noe du lurer på om [diagnosen]?"

### Timing
Spør når dere gjør noe sammen - i bilen, ved matlaging, i sengen.

> "De beste samtalene skjer ofte når du ikke sitter ansikt til ansikt."', 
     2, 12),
    
    ('Validering Av Følelser', 
     '## Alle Følelser Er Lov

Søsken kan ha "forbudte" følelser:
- Sinne på det syke barnet
- Misunnelse over oppmerksomheten
- Skam over disse følelsene
- Lettelse når søskenet er borte

### Vanlige Feil
❌ "Du må ikke være sint på bror din"
❌ "Du vet jo at vi elsker dere like mye"
❌ "Du burde være takknemlig for at du er frisk"

### Validerende Respons
✅ "Det høres ut som du føler deg sint. Det er forståelig."
✅ "Det må være vanskelig når vi er så mye borte med søsteren din."
✅ "Det er lov å ønske at ting var annerledes."

### Hovedregel
Anerkjenn følelsen først. Løsninger og perspektiv kommer etterpå.

> "Barn som får lov til å føle, lærer å håndtere følelsene sine."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Familiesamtaler
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'kommunikasjon-i-familien' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Familiemøtet', 
     '## En Arena For Alle

Et regelmessig familiemøte gir alle en stemme.

### Struktur
- **Frekvens**: Ukentlig eller annenhver uke
- **Lengde**: 15-30 minutter (tilpass alder)
- **Tidspunkt**: Fast, forutsigbart

### Agenda (eksempel)
1. Runde: Én ting som var bra denne uken
2. Kalender: Hva skjer neste uke?
3. Utfordringer: Noe vi må løse sammen?
4. Ønsker: Noe noen trenger?
5. Avslutning: Noe hyggelig sammen

### Regler
- Alle får snakke ferdig
- Ingen kritikk av andres innspill
- Fokus på løsninger, ikke skyld

> "Familiemøtet viser barna at deres stemme teller."', 
     1, 12),
    
    ('Snakke Om Det Vanskelige', 
     '## Når Temaet Er Tungt

Noen samtaler er vanskelige, men nødvendige.

### Tema Som Bør Tas Opp
- Endringer i søskenets helsetilstand
- Familiesituasjonens påvirkning på alle
- Bekymringer og frykt
- Døden (hvis relevant)

### Hvordan Nærme Seg
1. **Velg riktig tid**: Rolig, ikke stresset
2. **Start enkelt**: "Det er noe viktig jeg vil snakke om"
3. **Vær ærlig**: Aldersriktig, men ikke lyv
4. **Gi rom**: La dem reagere og spørre
5. **Følg opp**: Kom tilbake til temaet senere

### Husk
Du trenger ikke ha alle svar. Ærlighet om usikkerhet er også verdifullt:
"Jeg vet ikke akkurat, men vi finner ut av det sammen."', 
     2, 15),
    
    ('Daglig Kommunikasjon', 
     '## Små Øyeblikk, Store Effekter

Det er ikke bare de store samtalene som teller.

### Bygge Kommunikasjonskultur
- Hils ordentlig hver morgen
- Spør om dagen ved middagsbordet
- "Good night"-ritualer med hvert barn
- Uformelle samtalestunder

### Vær Tilgjengelig
- Legg bort telefonen
- Stopp opp når de snakker til deg
- Vis med kroppen at du lytter
- Ikke vær for travel for småprat

### For Det Friske Barnet
Ekstra viktig å ha samtaler som IKKE handler om søskenet:
- Deres venner og interesser
- Deres drømmer og planer
- Deres hverdagsliv

> "Kommunikasjon er som en muskel - den styrkes med daglig bruk."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE: Egen Mestring som Forelder (modul 2 og 3 mangler)
-- =====================================================

-- MODUL 2: Parforholdet Under Press
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'egen-mestring-som-forelder' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Press På Relasjonen', 
     '## Parforholdet Blir Utfordret

Forskning viser at foreldre til barn med kronisk sykdom har høyere skilsmisserate.

### Vanlige Utfordringer
- Lite tid til hverandre
- Ulik måte å håndtere stress på
- Uenighet om barnas behov
- Utmattelse og irritabilitet
- Skyldfølelse som rammer ulikt

### Advarselstegn
- Snakker kun om barna/logistikk
- Kritiserer hverandre oftere
- Trekker seg fra hverandre
- Føler seg ensomme i parforholdet

### Viktig Første Steg
Anerkjenn at dette er vanskelig. Ikke late som alt er fint.

> "Et parforhold under press trenger bevisst innsats for å overleve."', 
     1, 12),
    
    ('Kommunikasjon I Krisen', 
     '## Snakke Sammen Når Alt Butter

I stressende perioder bryter kommunikasjonen ofte sammen.

### Vanlige Mønstre
- **Kritiker og forsvarer**: Én kritiserer, én forsvarer seg
- **Krav og tilbaketrekning**: Én pusher, én trekker seg
- **Gjensidig kritikk**: Begge angriper
- **Stonewall**: Én lukker helt

### Mot Sunnere Kommunikasjon

**Bruk jeg-språk:**
- ❌ "Du er aldri tilstede"
- ✅ "Jeg føler meg alene med dette"

**Ta timeout ved opptrapping:**
- "Jeg trenger en pause. Kan vi snakkes om en time?"

**Regelmessig check-in:**
- "Hvordan har du det egentlig?"
- "Hva trenger du fra meg akkurat nå?"

> "I kriser går vi til kjente mønstre. Bevisst kommunikasjon krever ekstra innsats."', 
     2, 12),
    
    ('Tid Til Parforholdet', 
     '## Prioritering Midt I Kaoset

"Vi har ikke tid til date nights" - kanskje det vanligste unnskyldningen.

### Realiteten
Du har ikke tid til å IKKE prioritere parforholdet. Skilsmisse er mye mer krevende.

### Praktiske Forslag

**Daglig:**
- 10 minutter uten telefon etter barna sover
- God morgen-kyss og god natt-kos
- Én positiv ting til hverandre

**Ukentlig:**
- En time bare dere to (selv om det er på sofaen)
- Snakk om noe annet enn barna

**Månedlig:**
- Date night (få hjelp til barnepass)
- Gjør noe dere begge liker

### Husk
Det trenger ikke være romantisk. Det trenger bare å være dere to, uten barna som fokus.

> "Parforholdet er fundamentet familien står på."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Mitt Eget Støttenettverk
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'egen-mestring-som-forelder' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Du Trenger Folk', 
     '## Ensomheten I Rollen

Mange foreldre i din situasjon føler seg isolerte.

### Hvorfor Det Skjer
- Andre "forstår ikke"
- Lite tid og energi til sosial kontakt
- Vanskeligheter med å kommunisere situasjonen
- Skam eller skyldfølelse

### Konsekvenser Av Isolasjon
- Økt stress
- Dårligere mentale helse
- Utbrenthet
- Dårligere foreldrefunksjon

### Hva Forskning Viser
Sosial støtte er en av de viktigste beskyttende faktorene for foreldre i din situasjon.

> "Du kan ikke ta vare på andre hvis ingen tar vare på deg."', 
     1, 12),
    
    ('Bygge Nettverk', 
     '## Hvor Finne Støtte?

### Ulike Typer Støtte

**Praktisk:**
- Hjelp med barnepass
- Matlaging, handling
- Transport

**Emosjonell:**
- Noen å snakke med
- Forståelse uten dømmekraft
- Bare være der

**Informativ:**
- Kunnskap om diagnosen
- Navigering i systemet
- Erfaringsdeling

### Hvor Finne Folk

**Formelt:**
- Pårørendeforeninger
- Sykehusgrupper for foreldre
- Online forum og grupper
- Terapeut eller rådgiver

**Uformelt:**
- Familie og venner
- Naboer
- Kolleger
- Foreldre på barnas skole/aktiviteter

### Ta Initiativ
Folk vil ofte hjelpe, men vet ikke hvordan. Fortell dem hva du trenger.', 
     2, 12),
    
    ('Akseptere Hjelp', 
     '## Hvorfor Er Det Så Vanskelig?

Mange foreldre sliter med å ta imot hjelp.

### Vanlige Hindringer
- "Jeg burde klare dette selv"
- "Andre har nok å gjøre"
- "De forstår jo ikke ordentlig"
- "Det er lettere å gjøre det selv"

### Perspektivskifte

**Fra:** Å ta imot hjelp er svakhet
**Til:** Å ta imot hjelp er smart

**Fra:** Jeg bør klare alt selv
**Til:** Ingen klarer alt alene

**Fra:** Jeg vil ikke være til bry
**Til:** Andre føler seg bra av å hjelpe

### Praktiske Tips
1. Lag en liste over ting du trenger hjelp med
2. Neste gang noen sier "si fra hvis du trenger noe", SI FRA
3. Vær spesifikk: "Kan du hente i barnehagen tirsdag?"
4. Si takk, og la andre føle seg nyttige

> "Å akseptere hjelp er en gave til den som gir."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE: Praktisk Hverdag (modul 2 og 3 mangler)
-- =====================================================

-- MODUL 2: Delegering og Hjelp
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'praktisk-hverdag' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Si Ja Til Hjelp', 
     '## Nettverket Vil Hjelpe

Mennesker rundt deg vil ofte hjelpe, men vet ikke hvordan.

### Vanlige Tilbud (og hva du kan svare)
| De sier | Du kan svare |
|---------|--------------|
| "Si fra hvis du trenger noe" | "Faktisk, kunne du hentet i barnehagen mandag?" |
| "Vil dere ha middag en dag?" | "Ja takk! Torsdag passer bra." |
| "Hvordan går det?" | "Tøft. Kunne du tatt med [barn] på aktivitet?" |

### Lag En Hjelpeliste
Skriv ned:
1. Ting du trenger hjelp med
2. Hvem som har tilbudt seg
3. Match oppgaver med folk

### Vær Konkret
"Trenger hjelp" → vagt
"Kan du hente på skolen tirsdager kl 14?" → konkret

> "Å be om hjelp er ikke svakhet. Det er smarthet."', 
     1, 12),
    
    ('Fordeling I Familien', 
     '## Hvem Gjør Hva?

I travle familier må arbeidsfordelingen være tydelig.

### Mellom Partnere
- Snakk om forventninger
- Del opp etter styrker/preferanser
- Roter ubehagelige oppgaver
- Ha backup-planer

### Barna (aldersriktig)
- Små oppgaver fra tidlig alder
- Tydelige forventninger
- Konsistens
- Unngå at friskt barn får for mye

### Eksempel Fordeling
| Oppgave | Hvem |
|---------|------|
| Sykehusbesøk | Rotering |
| Matlaging | Forelder A |
| Lekser | Forelder B |
| Kveldsrutine | Rotering |

### Revider Regelmessig
Ting endrer seg. Ha jevnlige samtaler om fordelingen fungerer.', 
     2, 10),
    
    ('Utnytte Ressurser', 
     '## Du Trenger Ikke Finne Opp Hjulet

Det finnes mange ressurser tilgjengelig.

### Offentlige Tilbud
- Støttekontakt
- Avlastning
- BPA (brukerstyrt personlig assistanse)
- NAV-ytelser
- Hjelpemidler

### Ideelle Organisasjoner
- Pårørendesenteret
- Diagnoseforeninger
- Røde Kors / andre frivillige
- Søskengrupper for barna

### Private Løsninger
- Barnevakt-nettverk
- Matkasser-levering
- Vaskehjelp (hvis økonomi)

### Navigeringshjelp
Mange steder har koordinatorer som hjelper deg finne frem:
- Sykehuset
- Kommunens koordinerende enhet
- Pårørendesenteret

> "Det finnes mer hjelp der ute enn du aner. Men du må be om det."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Prioritering i Kaos
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'praktisk-hverdag' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Når Alt Haster', 
     '## Prioriteringskunst

I din hverdag føles ofte alt som like viktig. Men det er det ikke.

### Eisenhower-Matrisen
| | Haster | Haster ikke |
|--|--------|-------------|
| **Viktig** | GJØR NÅ | PLANLEGG |
| **Ikke viktig** | DELEGER | DROPP |

### Eksempler
- Sykehustime → Viktig + Haster → GJØR NÅ
- Kvalitetstid med friskt barn → Viktig + Haster ikke → PLANLEGG
- Svare på ufarlig melding → Ikke viktig + Haster → DELEGER/IGNORER
- Bla på sosiale medier → Ikke viktig + Haster ikke → DROPP

### Praktisk Tips
Hver morgen: Hva er DE TRE viktigste tingene i dag? Fokuser på dem.

> "Du kan gjøre alt - bare ikke alt samtidig."', 
     1, 12),
    
    ('La Noe Ligge', 
     '## Perfeksjonisme Er Fienden

Du kan ikke gjøre alt. Punkt.

### Hva Kan Vente?
- Huset trenger ikke være ryddig hele tiden
- Middag trenger ikke være gourmet
- Du trenger ikke svare på alle meldinger umiddelbart
- Barna overlever litt skjermtid

### Hva Kan IKKE Vente?
- Barnas grunnleggende behov
- Kritiske medisinske avtaler
- Din egen basale helse
- Tilkobling til partner og barn

### Senk Listen
Still deg spørsmålet: "Hva er godt nok her?" Ikke "Hva er perfekt?"

### Gi Deg Selv Nåde
Du er i en ekstraordinær situasjon. Vanlige standarder gjelder ikke.

> "Gjort er bedre enn perfekt."', 
     2, 10),
    
    ('Kriseberedskap', 
     '## Når Ting Smeller

Du vet at kriser kommer. Forbered deg.

### Ha Klart På Forhånd
- Kontaktliste for nødssituasjoner
- Naboen/vennen som kan ta imot friskt barn
- Nøkkel hos noen til nødstilfeller
- Viktig medisinsk info tilgjengelig
- Snacks/klær i bilen for lange ventetider

### Plan B For Hverdagsrutiner
- Hvis sykehuset: Hvem henter barn?
- Hvis du blir syk: Hvem tar over?
- Hvis partner borte: Hvem kan hjelpe?

### Kommuniser Planen
Alle relevante personer bør vite:
- Deres rolle ved krise
- Hvordan de kontaktes
- Hva de skal gjøre

### Etter Krisen
- Debrief med partner
- Hva fungerte?
- Hva må justeres?

> "Forberedt er halvveis håndtert."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- End of migration
