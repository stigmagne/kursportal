-- Migration: 068_complete_leader_courses_part2.sql
-- Purpose: Add lessons for modules 2 and 3 of remaining leader courses
-- Content in Bokmål

-- =====================================================
-- COURSE: Lederens Konflikthåndtering
-- =====================================================

-- MODUL 2: Strukturelle Konflikter
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'lederens-konflikthandtering' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Når Systemet Er Problemet', 
     '## Ikke Alle Konflikter Er Personlige

Noen ganger krangler folk fordi systemet setter dem opp mot hverandre.

### Tegn På Strukturell Konflikt
- Samme type konflikt oppstår gjentatte ganger
- Ulike team eller roller kolliderer konsekvent
- Folk i samme rolle sliter med de samme utfordringene
- Konflikten overlever selv når folk byttes ut

### Vanlige Strukturelle Årsaker

**Motstridende mål:**
- Salg vil ha volum, Kvalitet vil ha perfeksjon
- Drift vil ha stabilitet, Utvikling vil ha endring

**Uklar ansvarsfordeling:**
- To mennesker tror de eier samme beslutning
- Ingen vet hvem som har siste ord

**Ressursknapphet:**
- To team kjemper om samme budsjett/folk
- Priortierung er uklar

**Dårlig kommunikasjonsstruktur:**
- Informasjon når ikke frem
- Siloer uten samarbeid

### Spørsmål Å Stille
- Hvem *andre* har hatt denne konflikten?
- Ville denne konflikten oppstått med andre personer i rollene?
- Hva i systemet belønner denne konflikten?

> "Hvis du løser en personkonflikt, har du løst én konflikt. Hvis du løser en systemkonflikt, har du løst hundre."', 
     1, 12),
    
    ('Løse Strukturelle Problemer', 
     '## Fiks Systemet, Ikke Bare Symptomene

Når konflikten er strukturell, hjelper det lite med medling. Du må endre noe.

### Mulige Løsninger

**Ved motstridende mål:**
- Tydeliggjør prioritering fra toppen
- Lag felles mål begge måles på
- Skap forum for regelmessig avklaring

**Ved uklar ansvarsfordeling:**
- RACI-matrise (Responsible, Accountable, Consulted, Informed)
- Dokumenter og kommuniser beslutningsrett
- Eskaleringsprosess ved uenighet

**Ved ressursknapphet:**
- Transparent prioriteringsprosess
- Reduser konkurranse, øk samarbeid
- Felles budsjett med felles mål

**Ved kommunikasjonsbrist:**
- Regelmessige synkpunkter mellom team
- Rotiering eller hospitering
- Felles ritualer

### Prosess For Systemendring
1. Identifiser mønsteret
2. Involver de berørte i analyse
3. Design løsning sammen
4. Pilot i liten skala
5. Evaluer og juster
6. Implementer bredere

> "Den beste konflikthåndteringen er å fjerne kilden til konflikten."', 
     2, 12),
    
    ('Din Rolle I Systemet', 
     '## Du Er Også En Del Av Det

Som leder er du ikke bare observatør av systemet - du er en del av det.

### Hvordan Du Kan Være Problemet
- Du setter motstridende mål for folk
- Du er uklar i forventninger
- Du eskalerer ting som burde løses lokalt
- Du belønner konkuranse fremfor samarbeid
- Du ignorerer gjentakende konflikter

### Ærlige Spørsmål Til Deg Selv
- Har jeg satt klare prioriteringer?
- Vet alle hvem som bestemmer hva?
- Belønner jeg riktig adferd?
- Er jeg tilgjengelig når eskalering trengs?
- Håndterer jeg konflikter - eller unngår jeg dem?

### Tegn På At Du Er Del Av Problemet
- Folk eskalerer alt til deg
- Du får høre om konflikter sent
- De samme konfliktene oppstår igjen og igjen
- Folk sier "vi venter på at du bestemmer"

### Hva Du Kan Gjøre
1. Be om ærlig feedback på din rolle
2. Observer dine egne mønstre
3. Endre det du har kontroll over
4. Vær en forbedring, ikke en flaskehals

> "Du kan ikke løse konflikter du er blind for at du skaper."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Forebygge Konflikter
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'lederens-konflikthandtering' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Klare Forventninger', 
     '## De Fleste Konflikter Starter Med Uklarhet

Når folk ikke vet hva som forventes, fyller de inn blanktene selv - ofte feil.

### Hvor Uklarhet Skaper Konflikt
- Hvem har ansvar for hva?
- Hva er målet og hva er "bra nok"?
- Hvem bestemmer når det er uenighet?
- Hva er akseptabel og uakseptabel adferd?

### Praktiske Grep

**Ved rollefordeling:**
- Beskriv rollene skriftlig
- Diskuter overlappende områder
- Avklar hvem som har siste ord

**Ved prosjektstart:**
- Tydelig målbeskrivelse
- Definert kvalitetsstandard
- Kjent deadline og milepæler
- Eskaleringsrutine

**I teamet:**
- Normer for kommunikasjon
- Forventninger til responstid
- Regler for uenighet

### Test: Er Du Tydelig Nok?
Spør fem forskjellige folk på teamet:
- "Hva er ditt viktigste mål?"
- "Hvem har ansvar for X?"
- "Hva gjør du ved uenighet med kollega?"

Hvis svarene varierer mye, har du et klarhetsproblem.

> "Invester tid i klarhet nå, eller bruk mer tid på konflikter senere."', 
     1, 12),
    
    ('Bygge Relasjoner Før Krisen', 
     '## Konflikt Er Lettere Når Dere Kjenner Hverandre

Folk som har relasjon, løser uenighet lettere enn fremmede.

### Hvorfor Relasjoner Hjelper
- Du gir folk velvillig tolkning
- Det er lettere å ta vanskelige samtaler
- Folk føler seg forpliktet til å løse ting
- Antagelser erstattes av kunnskap

### Praktiske Grep For Lederen

**Teambygging som fungerer:**
- Felles opplevelser (ikke bare festligheter)
- Samarbeidsoppgaver på tvers
- Rotiering på prosjekter
- Uformell tid sammen

**1:1 på kryss og tvers:**
- Oppmuntre til samtaler mellom teammedlemmer
- Koble folk som jobber parallelt
- Introduksjoner for nye

**Synliggjør hele mennesket:**
- Personlige introer i møter
- Del bakgrunn og interesser
- Feir personlige milepæler

### Investering Før Konflikt
- Når relasjonen er god: "Hei, vi må snakke om dette"
- Når relasjonen mangler: "Hvem er denne personen og hva vil de?"

> "Den beste tiden å bygge en bro er før du trenger å krysse den."', 
     2, 10),
    
    ('Tidlig Varsling', 
     '## Fang Konflikter Før De Eksploderer

De verste konfliktene er de som har fått vokse i det stille.

### Varseltegn Å Se Etter
- Korte, frosne samtaler
- Folk unngår hverandre
- Klagende bak ryggen
- Motvilje mot samarbeid
- "Alt er fint"-svar som føles falskt

### Systemer For Tidlig Varsling

**Regelmessige pulser:**
- Korte temperaturmålinger
- Anonyme undersøkelser
- Retro-møter med ærlig feedback

**1:1 som radar:**
- Spør direkte om samarbeid
- "Er det noe du vil jeg skal vite?"
- "Hvordan er stemningen i teamet?"

**Åpen dør-praksis:**
- Gjør det trygt å komme til deg
- Reager konstruktivt når folk sier fra
- Følg opp det du hører

### Når Du Ser Tegn
1. Ikke vent og se
2. Ha en uformell prat med de involverte
3. Navngi det du observerer
4. Tilby hjelp tidlig

> "Små konflikter er som små branner. Slukk dem mens de er små."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE: Lederens Egenomsorg
-- =====================================================

-- MODUL 2: Grenser Som Leder
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'lederens-egenomsorg' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Tilgjengelighet Og Grenser', 
     '## Du Trenger Ikke Være På 24/7

Mange ledere tror de må være tilgjengelige hele tiden. Det er en oppskrift på utbrenthet.

### Myten Om Konstant Tilgjengelighet
- "Hvis jeg er borte, stopper alt"
- "Folk trenger meg for beslutninger"
- "Jeg må vise at jeg bryr meg"
- "Hva om noe kritisk skjer?"

### Realiteten
- Teamet klarer mer enn du tror
- Konstant tilgjengelighet skaper avhengighet
- Du modellerer usunn adferd
- Utmattet leder = dårlig leder

### Praktiske Grenser

**Arbeidstid:**
- Definér når du er "på" og "av"
- Kommuniser dette tydelig
- Respekter grensene selv (vanskeligst)

**Kommunikasjon:**
- Skru av varsler utenfor arbeidstid
- Ha en klar eskaleringsrutine for ekte kriser
- Aksepter at e-poster kan vente

**Ferie:**
- Faktisk kople av
- Opprett backup
- Stol på at ting overlever

### Kommuniser Grensene
"Jeg sjekker ikke e-post etter kl. 18. Ved akutt krise, ring. Alt annet tar jeg i morgen."

> "Grenser er ikke egoistisk. Det er nødvendig for å holde ut over tid."', 
     1, 12),
    
    ('Å Si Nei', 
     '## Det Umulige Ordet

For mange ledere er "nei" nesten umulig å si. Men det er kanskje det viktigste ordet du har.

### Hvorfor "Nei" Er Vanskelig
- Du vil hjelpe
- Du vil ikke skuffe
- Du tenker du burde klare alt
- Du er redd for konsekvenser

### Kostnaden Av Alltid "Ja"
- Overbelastning
- Dårligere kvalitet på alt
- Brente løfter
- Frustrasjon og bitterhet
- Utbrenthet

### Hvordan Si Nei

**Direkte men vennlig:**
"Nei, det har jeg ikke kapasitet til nå."

**Med alternativ:**
"Nei, men kanskje X kan hjelpe?"

**Med utsettelse:**
"Ikke nå, men vi kan se på det i Q2."

**Med avklaring:**
"Hvis jeg tar dette, hva skal jeg droppe?"

### Hovedregel For Prioritering
Hver "ja" er et implisitt "nei" til noe annet. Spør: Er dette viktigere enn det jeg må droppe?

> "Å si ja til alt er å si nei til det som virkelig betyr noe."', 
     2, 10),
    
    ('Delegering Som Egenomsorg', 
     '## Du Trenger Ikke Gjøre Alt Selv

Delegering handler ikke bare om utvikling av andre. Det handler også om din egen overlevelse.

### Tegn På At Du Holder For Mye
- Arbeidsdagene dine er for lange
- Du er alltid sliten
- Du rekker aldri strategisk tenkning
- Du er flaskehalsen i alt

### Hva Du Holder (Men Ikke Burde)

**Vanlige eksempler:**
- Oppgaver du liker
- Ting "ingen gjør like bra"
- Småting som tar 5 min (men det er 50 av dem)
- Ting du alltid har gjort

### Øvelse: Delegerings-audit
Hver dag i en uke, loggfør alt du gjør. Spør:
- Må dette gjøres av meg?
- Hvem andre kunne gjort dette?
- Hva stopper meg fra å delegere?

### Overvinne Hindringene

| Hindring | Løsning |
|----------|---------|
| "Det tar lengre tid å lære bort" | Invester nå, spar senere |
| "De gjør det ikke like bra" | 80% bra er ofte godt nok |
| "Jeg liker å gjøre det" | Finn glede i å utvikle andre |
| "Det er mitt ansvar" | Ansvar ≠ gjøre alt selv |

> "Du kan ikke helle fra en tom kopp. Delegering er å fylle koppen din."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- MODUL 3: Støtte og Mentoring
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'lederens-egenomsorg' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Finne En Mentor', 
     '## Du Trenger Også Noen Å Lære Av

Alle ledere, uansett nivå, har nytte av en mentor.

### Hva Er En Mentor?
- Noen med mer erfaring enn deg
- Som kan gi råd og perspektiv
- Som har vært der du er
- Som du kan være ærlig med

### Hva En Mentor Gir Deg
- Erfaring du ikke har
- Objektivt blikk på situasjoner
- Støtte i vanskelige beslutninger
- Nettverk og muligheter
- Normalisering ("jeg har opplevd det samme")

### Hvordan Finne En Mentor

**Intern:**
- Ledere på høyere nivå
- HR eller ledelsesutvikling
- Uformelle forbindelser

**Ekstern:**
- Bransjenettverk
- Alumni-nettverk
- Profesjonelle mentor-programmer
- Styremedlemmer eller rådgivere

### Det Første Steget
Identifiser 2-3 personer du beundrer. Ta kontakt og be om en kaffe. Du trenger ikke kalle det "mentorskap" - bare start samtalen.

### Tips For Relasjonen
- Respekter tiden deres
- Kom forberedt med spørsmål
- Implementer rådene og rapporter tilbake
- Gi noe tilbake (det går begge veier)

> "Bak hver stor leder står en annen leder som veiledet dem."', 
     1, 12),
    
    ('Ledernettverk', 
     '## Du Er Ikke Alene

Andre ledere står i de samme utfordringene som deg. Å koble dere sammen er gull.

### Verdien Av Ledernettverk
- Andre forstår det du går gjennom
- Du lærer av andres feil (ikke bare dine)
- Det normaliserer utfordringer
- Du får nye perspektiver
- Det er mindre ensomt

### Typer Nettverk

**Interne:**
- Ledergruppe på tvers av avdelinger
- Lederforum eller -samlinger
- Uformelle lederlikeer

**Eksterne:**
- Bransjeforeninger
- Lederutviklingsprogrammer alumni
- Profesjonelle nettverk (LinkedIn-grupper, etc.)
- Mastermind-grupper

### Mastermind-Gruppe
En liten gruppe (4-6 ledere) som møtes regelmessig for å:
- Dele utfordringer
- Gi hverandre råd
- Holde hverandre ansvarlig
- Støtte hverandres utvikling

### Slik Starter Du
- Finn 3-5 andre ledere på ditt nivå
- Avtal månedlig møte (1-2 timer)
- Roter hvem som bringer "case"
- Hold det konfidensielt

> "Ensom på toppen" er et valg, ikke en nødvendighet."', 
     2, 10),
    
    ('Profesjonell Hjelp', 
     '## Noen Ganger Trenger Du Mer

Det er ingen skam i å søke profesjonell hjelp - verken for utvikling eller utfordringer.

### Når Er Det Aktuelt?

**Coach:**
- Du vil utvikle deg målrettet
- Du står fast i et mønster
- Du trenger noen å tenke høyt med
- Du vil ha struktur på utviklingen

**Terapeut:**
- Personlige utfordringer påvirker jobben
- Stress eller utbrenthet
- Relasjonelle utfordringer
- Du trenger å bearbeide noe

**Lederutviklingsprogram:**
- Du vil investere i ferdighetene dine
- Du trenger ny input
- Firmaet tilbyr det

### Hvordan Finne Riktig Person
- Be om anbefalinger
- Ha en prøvesamtale
- Sjekk referanser og erfaring
- Velg noen du føler deg trygg på

### Bryt Tabuet
Mange ledere skammer seg over å trenge hjelp. Men:
- Toppidrettsutøvere har coacher
- Styreledere har rådgivere
- Selv terapeuter har terapeuter

### Investering I Deg Selv
Tid og penger brukt på din utvikling er ikke egoistisk. Det er smart. Du er fundamentet teamet ditt står på.

> "De sterkeste lederne er de som tør å innrømme at de trenger støtte."', 
     3, 12)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- End of migration part 2
