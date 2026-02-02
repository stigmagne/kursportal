-- Migration: 074_complete_sibling_courses_part2.sql
-- Purpose: Add lessons for modules 2 and 3 of remaining sibling courses
-- Content in Bokmål

-- =====================================================
-- COURSE: Karriere og Kall (modul 2 og 3 mangler)
-- =====================================================

-- MODUL 2: Tillate Egne Drømmer
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'karriere-og-kall' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Skyldfølelsen Over Suksess', 
     '## Når Å Lykkes Føles Feil

Mange søsken opplever skyldfølelse når de oppnår ting.

### Vanlige Tanker
- "Hvordan kan jeg glede meg når søsken sliter?"
- "Det er urettferdig at jeg har muligheter de ikke har"
- "Jeg burde bruke tiden min på å hjelpe i stedet"
- "Min suksess understreker forskjellen mellom oss"

### Perspektivskift

**Sannhet 1:** Din suksess skader ikke søskenet ditt
**Sannhet 2:** Å holde deg selv tilbake hjelper ingen
**Sannhet 3:** Du kan lykkes OG bry deg om familien
**Sannhet 4:** Dine prestasjoner kan inspirere

### Øvelse
Skriv ned: "Hvis jeg lykkes med [drøm], betyr det at..."
Se på tankene. Er de sanne?

> "Du ærer ikke søskenet ditt ved å holde deg selv tilbake."', 
     1, 12),
    
    ('Definere Suksess For Deg', 
     '## Hva Betyr Suksess For DEG?

Ikke la andre definere hva suksess er for deg.

### Vanlige Definisjoner (som kanskje ikke passer)
- Høy lønn
- Prestisje-tittel
- Andres godkjennelse
- Ofre alt for karrieren

### Dine Verdier
Tenk over hva som virkelig betyr noe for deg:

| Verdi | Hvor viktig (1-10) |
|-------|---------------------|
| Frihet | |
| Sikkerhet | |
| Kreativitet | |
| Familie | |
| Mening | |
| Anerkjennelse | |
| Læring | |

### Din Definisjon
Skriv din egen definisjon av suksess som tar hensyn til DINE verdier.

> "Suksess er å leve etter dine egne verdier, ikke andres forventninger."', 
     2, 15),
    
    ('Balanse Mellom Ambisjon Og Familie', 
     '## Det Er Ikke Enten Eller

Du trenger ikke velge mellom karriere og familie.

### Praktiske Strategier

**Tidsgrenser:**
- Definer arbeidstid
- Ha familietid som er hellig
- Lær å si nei

**Kommunikasjon:**
- Vær ærlig med familien om dine mål
- Be om støtte
- Forklar hva du trenger

**Fleksibilitet:**
- Juster når situasjonen krever det
- Ha perioder med mer og mindre fokus
- Ikke vær rigid

### Når Det Kolliderer
Noen ganger må du velge. Spør deg selv:
- Hva er viktigst akkurat nå?
- Hva vil jeg angre mest?
- Er dette en midlertidig eller permanent prioritering?

> "Balanse betyr ikke 50/50 hver dag. Det betyr riktig fordeling over tid."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Planlegge Fremtiden
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'karriere-og-kall' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Mål Som Motiverer', 
     '## Sette Mål Som Driver Deg

Ikke alle mål er like motiverende.

### SMART-mål
- **Spesifikt**: Hva nøyaktig?
- **Målbart**: Hvordan vet du at du lyktes?
- **Attraktivt**: Motiverer det deg?
- **Realistisk**: Er det mulig?
- **Tidsbestemt**: Når skal det være ferdig?

### Eksempel
✗ "Jeg vil ha en bedre jobb"
✓ "Innen desember vil jeg ha søkt på 10 stillinger innen [felt] og vært på minst 3 intervjuer"

### Langsiktig og Kortsiktig
- 5-års visjon: Hvor vil du være?
- 1-års mål: Hva må på plass?
- Månedlige steg: Hva gjør du nå?

> "Et mål uten en plan er bare et ønske."', 
     1, 12),
    
    ('Overvinne Hindringer', 
     '## Når Livet Kommer I Veien

Planer møter virkeligheten. Vær forberedt.

### Vanlige Hindringer For Søsken
- Familiebehov som tar tid
- Skyldfølelse som bremser
- Selvtvil fra barndommen
- Økonomiske forpliktelser

### Strategier

**Planlegg for hindringer:**
- Hva kan gå galt?
- Hva gjør du da?
- Hvem kan hjelpe?

**Bygg fleksibilitet:**
- Ha plan B
- Juster tidslinjer ved behov
- Feir fremgang, ikke bare mål

**Mentalt mindset:**
- Hindringer er ikke tegn på feil
- De er del av prosessen
- Hver hindring lærer deg noe

> "Det er ikke den som aldri faller som lykkes. Det er den som reiser seg igjen."', 
     2, 12),
    
    ('Første Steg', 
     '## Begynn I Dag

Den beste planen er verdiløs uten handling.

### Start Smått
- Hva er det minste steget du kan ta i dag?
- Ikke vent på perfekte forhold
- Handling skaper motivasjon, ikke omvendt

### 5-minutters Regel
Hvis du utsetter, forplikt deg til bare 5 minutter. Ofte fortsetter du når du først har begynt.

### Accountability
- Fortell noen om målet ditt
- Finn en "accountability partner"
- Sett deadlines for deg selv

### Feir Fremgang
- Anerkjenn hvert steg
- Før logg over fremgang
- Belønn deg selv underveis

### Din Handlingsplan
1. Mitt mål for neste måned er: ___
2. Første steg er: ___
3. Jeg gjør det innen: ___
4. Jeg forteller det til: ___

> "Reisen på tusen mil begynner med ett steg. Ta det steget i dag."', 
     3, 15)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE: Finne Min Stamme (modul 2 og 3 mangler)
-- =====================================================

-- MODUL 2: Finne Likesinnede
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'finne-min-stamme' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Andre Søsken', 
     '## Fellesskapet Som Forstår

Det finnes andre som har opplevd det samme.

### Hvor Finne Andre Søsken

**Online:**
- Facebook-grupper for søsken
- Sibs UK (internasjonalt)
- Reddit-communities
- Spesialiserte forum

**Offline:**
- Pårørendesentre
- Sykehusenes lærings- og mestringssentre
- Diagnoseforeninger
- Terapigrupper

### Verdien Av Å Bli Forstått
Når noen bare skjønner, slipper du å forklare. Det letter.

### Tips For Første Kontakt
- Start med å lese/lytte
- Del når du er klar
- Ikke press deg selv
- Alle er på ulike steder i prosessen

> "Å møte noen som forstår uten forklaring er befriende."', 
     1, 12),
    
    ('Bygge Nye Vennskap', 
     '## Folk Utenfor Søskenrollen

Du trenger også folk som kjenner deg for andre ting.

### Hvor Møte Nye Mennesker
- Hobbyer og aktiviteter
- Kurs og klasser
- Frivillighetsarbeid
- Arbeidsrelaterte nettverk
- Naboer og lokalsamfunn

### Fra Bekjent Til Venn
1. **Første steg**: Vis interesse, spør spørsmål
2. **Andre steg**: Foreslå å møtes utenfor konteksten
3. **Tredje steg**: Vær konsistent med kontakt
4. **Fjerde steg**: Del noe personlig
5. **Femte steg**: Vær sårbar og ekte

### Vennskap Tar Tid
Forskning viser at det tar 50+ timer sammen for å utvikle vennskap. Vær tålmodig.

> "Vennskap er som hager. De trenger tid og pleie for å blomstre."', 
     2, 15),
    
    ('Ulike Arenaer', 
     '## Spre Deg Utover

Ikke legg alle eggene i én kurv.

### Sunne Nettverksfordeling

**Jobb/karriere:**
- Kolleger du liker
- Mentorer
- Profesjonelle nettverk

**Personlig:**
- Nære venner
- Lett selskap
- Aktivitetsvenner

**Familie:**
- De familiemedlemmene som støtter
- Utvidet familie

**Interesse:**
- Hobbyvenner
- Treningspartnere
- Kreative fellesskap

### Kartlegg Ditt Nettverk
Tegn sirkler: Innerst (nære), midten (gode), ytterst (bekjente).
Hvem er hvor? Hvor vil du ha flere folk?

> "Et rikt nettverk gir deg ulike typer støtte for ulike situasjoner."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Vedlikeholde Relasjoner
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'finne-min-stamme' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Investere I Vennskap', 
     '## Relasjoner Krever Vedlikehold

Vennskap dør av forsømmelse.

### Enkle Vedlikeholdsrutiner
- Send en melding når du tenker på noen
- Husk bursdager og viktige datoer
- Del artikler eller ting som minner deg om dem
- Foreslå regelmessige treff

### Dybde vs Bredde
Du kan ikke ha dype vennskap med alle. Prioriter:
- Hvem gir deg energi?
- Hvem er der når det gjelder?
- Hvem vil du investere i?

### Vennskap Gjennom Livsfaser
Vennskap endrer seg. Det er normalt. Noen forsvinner, nye kommer.

> "De beste vennskapene overlever ved bevisst innsats, ikke tilfeldigheter."', 
     1, 12),
    
    ('Gi Og Ta', 
     '## Balanse I Relasjoner

Sunne relasjoner har gjensidig nytte.

### Tegn På Ubalanse
- Du gir alltid, får lite tilbake
- Du føler deg tappet etter møter
- Det handler alltid om den andre
- Du retter deg etter deres behov

### Søskenmønster
Mange søsken har lært å være den som gir. Pass på at dette mønsteret ikke styrer alle relasjoner.

### Øvelse: Relasjonsrevisjon
For hver nær relasjon, vurder:
- Hvor mye gir jeg? (1-10)
- Hvor mye får jeg? (1-10)
- Er dette OK for meg?

### Justere Balansen
- Be om det du trenger
- Si nei noen ganger
- Velg vekk relasjoner som tapper deg

> "Du fortjener vennskap der du også får."', 
     2, 12),
    
    ('Støtte Og La Deg Støtte', 
     '## Begge Veier

Det vanskeligste for mange søsken er å motta støtte.

### Hvorfor Det Er Vanskelig
- Du lærte å klare deg selv
- Du vil ikke være til bry
- Du tror andre har nok å tenke på
- Det føles sårbart

### Å Motta Er En Gave
Når du lar andre hjelpe deg:
- De føler seg nyttige
- Relasjonen styrkes
- Du modellerer at det er OK å trenge andre

### Praksis
1. Neste gang noen tilbyr hjelp, si ja
2. Be om noe lite fra en venn
3. Del en bekymring med noen du stoler på
4. Takk varmt når noen er der for deg

### Avsluttende Refleksjon
Du har nå verktøy for å:
- Finne mennesker som forstår deg
- Bygge nye vennskap
- Vedlikeholde relasjoner over tid
- Gi og motta støtte

Din stamme er der ute. Gå og finn dem.

> "De sterkeste menneskene er de som vet når de trenger andre."', 
     3, 15)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- End of migration
