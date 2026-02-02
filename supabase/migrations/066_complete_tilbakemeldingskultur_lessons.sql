-- Migration: 066_complete_tilbakemeldingskultur_lessons.sql
-- Purpose: Add lessons for modules 2 and 3 of "Tilbakemeldingskultur" course
-- Content in Bokmål

-- =====================================================
-- MODUL 2: Motta Feedback Som Leder
-- =====================================================

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'tilbakemeldingskultur' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Å Be Om Tilbakemelding', 
     '## Hvorfor Be Om Feedback?

Som leder sender du sterke signaler når du aktivt ber om tilbakemelding. Det viser at du verdsetter andres perspektiver og er åpen for vekst.

### Hva Det Signaliserer
- Du er trygg på deg selv
- Du verdsetter teamets meninger
- Du ønsker å bli bedre
- Det er trygt å gi deg ærlig feedback

### Praktiske Tips
1. **Vær spesifikk**: "Hvordan opplevde du møtet i dag?" i stedet for "Har du noen tilbakemelding?"
2. **Velg riktig tidspunkt**: Etter konkrete hendelser, ikke midt i kriser
3. **Start med trygge personer**: Bygg opp mot de vanskeligere samtalene

> "De beste lederne ber ikke om feedback fordi de trenger det - de ber fordi de vet det gjør teamet tryggere."

### Refleksjon
Tenk på sist du ba om tilbakemelding. Hvordan reagerte andre? Hva kan du gjøre annerledes neste gang?', 
     1, 10),
    
    ('Å Ta Imot Kritikk', 
     '## Når Feedbacken Svir

Det er lett å ta imot ros. Det utfordrende er når noen forteller deg noe du ikke vil høre.

### Vanlige Reaksjoner
- **Forsvar**: "Ja, men du forstår ikke..."
- **Avvisning**: "Det er ikke sant"
- **Motangrep**: "Hva med når du..."
- **Tilbaketrekning**: Stille, lukket

### Bedre Tilnærming

| I stedet for | Prøv dette |
|--------------|------------|
| Forsvare deg | "Fortell meg mer" |
| Avvise | "Kan du gi et eksempel?" |
| Motangripe | "Jeg hører deg, og det er viktig" |
| Lukke deg | "Jeg trenger litt tid, men jeg setter pris på dette" |

### SARA-Modellen
- **Shock**: Det er normalt å bli overrasket
- **Anger**: Sinne er en naturlig respons
- **Rejection**: Avvisning kommer ofte først
- **Acceptance**: Aksept tar tid

> "Takk for at du sa dette til meg" er de seks mest kraftfulle ordene en leder kan si.', 
     2, 12),
    
    ('Å Vise At Du Har Hørt', 
     '## Feedback Uten Oppfølging Er Bortkastet

Når noen tar risikoen med å gi deg tilbakemelding, skylder du dem mer enn "takk".

### Tre Nivå Av Respons

**Nivå 1: Anerkjenne**
- "Jeg hørte det du sa"
- "Det ga meg noe å tenke på"

**Nivå 2: Reflektere**
- "Jeg har tenkt på det du sa, og..."
- "Du hadde et poeng med..."

**Nivå 3: Handle**
- "Basert på det du sa, har jeg endret..."
- "Du vil kanskje merke at jeg nå..."

### Praktisk Øving
1. Få tilbakemelding
2. Vent 24-48 timer
3. Kom tilbake til personen
4. Del hva du har tenkt
5. Fortell hva du vil prøve

### Hvorfor Det Betyr Noe
Når folk ser at tilbakemeldingen deres fører til endring, vil de:
- Gi mer ærlig feedback
- Stole mer på deg
- Føle seg verdsatt
- Gjøre det samme selv

> "Handling er den ultimate formen for å si takk."', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- MODUL 3: 1:1 Samtaler
-- =====================================================

WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'tilbakemeldingskultur' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Strukturen I En God 1:1', 
     '## Mer Enn Bare Et Møte

En 1:1 er ikke et statusmøte. Det er *deres* tid, ikke din.

### Annen Formatering

| IKKE slik | MEN slik |
|------------|----------|
| "Hva jobber du med?" | "Hva er det viktigste for deg akkurat nå?" |
| "Er alt ok?" | "Hva frustrerer deg mest?" |
| "Har du spørsmål?" | "Hva har jeg gjort som hindret deg?" |

### Forslag Til Struktur (30 min)
1. **Check-in (5 min)**: Hvordan har du det? Ikke bare jobb.
2. **Deres agenda (15 min)**: Hva vil de snakke om?
3. **Utvikling (5 min)**: Langsiktige mål, karriere
4. **Din agenda (5 min)**: Bare om nødvendig

### Forbered Deg
- Les notater fra sist
- Tenk: Hva har jeg observert denne uken?
- Ha åpne spørsmål klare
- Vær til stede - telefon vekk!

> "De beste 1:1-samtalene er de der du snakker minst."

### Tips For Nye Ledere
Start med å stille spørsmål og lytte. Du trenger ikke ha alle svarene.', 
     1, 12),
    
    ('Vanskelige Tema I 1:1', 
     '## Når Det Blir Skummelt

Noen samtaler er vanskeligere enn andre. Det er greit - det er et tegn på at du gjør jobben din.

### Vanlige Vanskelige Tema
- Prestasjonsproblemer
- Konflikt med kolleger
- Personlige utfordringer
- Karriereskuffelse
- Lønnsforventninger

### Forberedelsessjekkliste
- [ ] Hva er fakta, ikke bare min tolkning?
- [ ] Hva vil jeg oppnå med samtalen?
- [ ] Hvordan kan jeg si dette med respekt?
- [ ] Hva trenger jeg å lytte etter?
- [ ] Hva er neste steg?

### Under Samtalen
1. **Start direkte**: "Jeg må snakke med deg om noe vanskelig"
2. **Vær spesifikk**: Bruk SBI-modellen
3. **Lytt aktivt**: De har kanskje informasjon du mangler
4. **Vis empati**: "Jeg forstår at dette er tøft"
5. **Fokuser fremover**: "Hva kan vi gjøre nå?"

### Når Du Ikke Vet Svaret
Det er lov å si:
- "Jeg må tenke på dette"
- "La meg undersøke og komme tilbake til deg"
- "Jeg vet ikke, men jeg skal finne ut av det"

> "Mot i vanskelige samtaler er å vise at du bryr deg nok til å være ærlig."', 
     2, 15),
    
    ('Dokumentasjon Og Oppfølging', 
     '## Hukommelse Er Upålitelig

Skriv ned det som skjer i 1:1. Ikke for å kontrollere - for å støtte.

### Hvorfor Dokumentere?
- Du husker ikke alt
- Det viser at du tar samtalen på alvor
- Det gjør oppfølging lettere
- Det beskytter begge parter

### Hva Skal Noteres?
**JA**:
- Avtalte aksjonspunkter
- Viktige tema diskutert
- Bekymringer eller ønsker
- Karrieremål

**NEI**:
- Alt som ble sagt
- Personlige detaljer (med mindre relevant)
- Din vurdering av personen

### Mal For 1:1-Notat

```
Dato: ___
Deltaker: ___

Deres agenda:
- 

Viktige punkter:
- 

Avtalte aksjoner:
- [ ] Hvem gjør hva innen når

Til neste gang:
- 
```

### Oppfølging Er Nøkkelen
- Send kort oppsummering etter møtet (valgfritt)
- Start neste møte med: "Sist snakket vi om..."
- Hold løfter - eller forklar hvorfor ikke

> "En 1:1 er bare så god som oppfølgingen etterpå."

### Verktøy-Tips
Bruk et felles dokument der både du og medarbeideren kan skrive. Det skaper eierskap hos begge.', 
     3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- End of migration
