-- Migration: 102_seed_additional_courses.sql
-- Purpose: Add 6 new courses (3 for Håndverker, 3 for Bas/Byggeleder)
-- Content in Bokmål

-- =====================================================
-- HÅNDVERKER: KURS 1 - Effektiv Kommunikasjon
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Effektiv Kommunikasjon',
    'Unngå misforståelser, bruk digitale verktøy smart, og skap et bedre arbeidsmiljø med tydelig kommunikasjon.',
    'effektiv-kommunikasjon-handverker',
    TRUE,
    '/courses/effektiv-kommunikasjon-handverker.png',
    'construction_worker'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'effektiv-kommunikasjon-handverker');

-- Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'effektiv-kommunikasjon-handverker')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Unngå Misforståelser', 'Hvordan sikre at beskjeden er forstått - begge veier.', 1),
    ('Digitale Verktøy På Plassen', 'Bilder, apper og dokumentasjon som forenkler hverdagen.', 2),
    ('Tonefall og Respekt', 'Hvordan vi snakker til hverandre påvirker både trivsel og feilprosent.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Lessons M1
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'effektiv-kommunikasjon-handverker' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hørte Du Hva Jeg Sa?', '## Aktiv Lytting\n\nDet er forskjell på å høre og å lytte.\n- Bekreft beskjeden: "Så du mener at..."\n- Spør hvis uklart\n- Skriv ned viktige mål', 1, 10),
    ('Antakelser Er Farlige', '## Ikke Tro, Men Vit\n\n"Jeg trodde du fikset det" er en klassiker.\n- Sjekk heller en gang for mye\n- Avklar ansvarsområder tydelig', 2, 8),
    ('Kroppsspråk', '## Mer Enn Ord\n\nArmer i kors, himling med øynene - hva signaliserer du uten å si et ord?', 3, 8)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Lessons M2
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'effektiv-kommunikasjon-handverker' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Bilder Sier Mer Enn 1000 Ord', '## Dokumentasjon\n\nTa bilde FØR du lukker veggen. Ta bilde av avviket. Det er din beste forsikring.', 1, 10),
    ('Digitale Sjekklister', '## Hvorfor Gidde?\n\nSjekklister er ikke byråkrati, det er hukommelseshjelp. Bruk dem aktivt for din egen del.', 2, 8),
    ('Chat og E-post', '## Skriftlighet\n\nKorte, tydelige meldinger. Unngå lange avhandlinger. "OK" er ofte nok, men "Mottatt, fikser tirsdag" er bedre.', 3, 8)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Lessons M3
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'effektiv-kommunikasjon-handverker' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hvorfor Rope?', '## Støy På Linja\n\nRoping skaper stress, ikke forståelse. Gå bort til personen i stedet for å rope over plassen.', 1, 8),
    ('Respekt For Andre Fag', '## Vi Er På Samme Lag\n\nElektrikeren er ikke i veien, han gjør jobben sin. Snakk med respekt, så får du respekt tilbake.', 2, 10),
    ('Tilbakemeldinger', '## Ros Og Ris\n\nSi "bra jobba" når det er bra. Si fra rolig når noe er feil. Det bygger kultur.', 3, 8)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;


-- =====================================================
-- HÅNDVERKER: KURS 2 - Ryddig Byggeplass
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Ryddig Byggeplass',
    'HMS, effektivitet og trivsel henger sammen med orden. Lær systemene som gjør hverdagen enklere.',
    'ryddig-byggeplass',
    TRUE,
    '/courses/ryddig-byggeplass.png',
    'construction_worker'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'ryddig-byggeplass');

-- Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'ryddig-byggeplass')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('HMS og Orden', 'Rot er ikke bare stygt, det er farlig.', 1),
    ('Avfallshåndtering', 'Kildesortering gjort enkelt og riktig.', 2),
    ('Effektivitet', 'Bruk tiden på å bygge, ikke på å lete.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Lessons M1 (HMS og Orden)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'ryddig-byggeplass' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Snublefeller', '## Hold Gangveien Fri\n\nLedninger, plankebiter og verktøy på gulvet er de vanligste årsakene til fallskader.', 1, 8),
    ('Støv og Helse', '## Rent Bygg\n\nStøv er ikke bare plagsomt, det er helseskadelig over tid. Rydd etter deg med en gang.', 2, 10),
    ('Brannsikkerhet', '## Brennbart Materiale\n\nSøppelhauger er brannfeller. Tøm dunkene før helgen.', 3, 8)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Lessons M2 (Avfallshåndtering)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'ryddig-byggeplass' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hvorfor Sortere?', '## Penger i Søpla\n\nUsotert avfall er dyrt. Sortering sparer prosjektet for store summer - penger som kan brukes bedre.', 1, 8),
    ('De Vanligste Fraksjonene', '## Tre, Plast, Gips\n\nLær de enkle reglene. Gips må holdes tørt. Plast må komprimeres.', 2, 8),
    ('Farlig Avfall', '## Ikke Bland Dette\n\nFugemasse, spraybokser, batterier. Dette må i egne miljøbokser. Aldri i restavfall.', 3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Lessons M3 (Effektivitet)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'ryddig-byggeplass' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Tidstyven Leting', '## Hvor La Jeg Drillen?\n\nVi bruker timesvis på å lete etter verktøy og materialer. Fast plass til alt sparer tid og frustrasjon.', 1, 8),
    ('Rydd Mens Du Jobber', '## 5 Minutter Spart\n\nRydd litt hele tiden, i stedet for skippertak på fredag kl 14:30.', 2, 8),
    ('Materialflyt', '## Bære Smart\n\nKort vei fra lager til montering. Ikke flytt samme gipspakke fire ganger.', 3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;


-- =====================================================
-- HÅNDVERKER: KURS 3 - Samarbeid med Andre Fag
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Samarbeid med Andre Fag',
    'Forstå grensesnittene mot andre håndverkere. Planlegg bedre, unngå kollisjoner og lever et bedre totalprodukt.',
    'samarbeid-med-andre-fag',
    TRUE,
    '/courses/samarbeid-med-andre-fag.png',
    'construction_worker'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'samarbeid-med-andre-fag');

-- Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'samarbeid-med-andre-fag')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Grensesnittene', 'De kritiske overgangene der feil ofte oppstår.', 1),
    ('Planlegge for Neste Mann', 'Gjør jobben lettere for den som kommer etter deg.', 2),
    ('Løse Utfordringer', 'Når vi krasjer i samme sjakt eller vegg.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Lessons M1 (Grensesnittene)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'samarbeid-med-andre-fag' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Våtromsonen', '## Tett Samarbeid\n\nMembran, rør, sluk, flis. Her må alle snakke sammen.', 1, 10),
    ('Tekniske Føringer', '## Kampen Om Plassen\n\nVentilasjon tar plass. Rør tar plass. Elektro tar plass. Sjekk tegningene sammen.', 2, 10),
    ('Hvem Har Ansvar?', '## Gråsoner\n\nHvem tetter rundt røret? Hvem rydder etter hulltaking? Avklar dette på forhånd.', 3, 8)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Lessons M2 (Planlegge for Neste Mann)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'samarbeid-med-andre-fag' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Ikke Bygg Inne Feil', '## Vær Grei\n\nSer du at røret ligger skjevt? Si fra til rørlegger før du kler igjen veggen.', 1, 8),
    ('Merking', '## Vis Hvor Du Har Vært\n\nMerk av føringer i gulv før flysparkel. Det sparer neste mann for mye gjetting.', 2, 8),
    ('Overlevering', '## Ferdig?\n\nGi beskjed når du er ferdig i en sone, så maleren kan slippe til. Dødtid koster.', 3, 8)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Lessons M3 (Løse Utfordringer)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'samarbeid-med-andre-fag' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Kollisjonskurs', '## Stopp Opp\n\nNår to fag skal være på samme sted samtidig: Ikke krig. Snakk sammen. Kanskje den ene kan ta lunsj mens den andre borer?', 1, 10),
    ('Ta En Kaffe', '## Bli Kjent\n\nDet er vanskeligere å være drittsekk mot en du har drikket kaffe med. Kjenn folka på bygget.', 2, 8),
    ('Løfte Blikket', '## Totalen Teller\n\nKunden driter i hvem sin feil det var. Kunden vil ha et ferdig bygg. Jobb for totalen.', 3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;


-- =====================================================
-- BAS/BYGGELEDER: KURS 4 - Gode Morgenmøter
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Gode Morgenmøter',
    'Start dagen riktig. Lær å holde effektive, korte møter som setter retning, avklarer risiko og motiverer teamet.',
    'gode-morgenmoter',
    TRUE,
    '/courses/gode-morgenmoter.png',
    'site_manager'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'gode-morgenmoter');

-- Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'gode-morgenmoter')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Struktur', 'Oppskriften på et effektivt 10-minutters møte.', 1),
    ('Involvering', 'Få gutta til å snakke, ikke bare lytte. SJA i praksis.', 2),
    ('Oppfølging', 'Fra ord til handling ute på plassen.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Lessons M1 (Struktur)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'gode-morgenmoter' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Agenda På 1-2-3', '## Fast Mønster\n\n1. Hva gjorde vi i går?\n2. Hva skal vi gjøre i dag?\n3. Er det noen hindringer/risiko?', 1, 8),
    ('Hold Tiden', '## Maks 15 Minutter\n\nRespekter folks tid. Start presis. Slutt presis. Lange diskusjoner tas etterpå med de det gjelder.', 2, 8),
    ('Stående Møter', '## Ingen Kaffe Her\n\nHa møtet ute på plassen eller stående i brakka. Det holder tempoet oppe.', 3, 6)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Lessons M2 (Involvering)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'gode-morgenmoter' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Still Spørsmål', '## Ikke Hold Tale\n\nSpør: "Hva er risikoen i dag?" "Trenger dere noe utstyr?" La dem svare.', 1, 10),
    ('Sikker Jobb Analyse (SJA)', '## Ta Det I Møtet\n\nIdentifiser farene før dere går ut. "Skal vi løfte tungt i dag? Ok, hvordan gjør vi det trygt?"', 2, 10),
    ('Hør På Alle', '## Også Lærlingen\n\nLærlingen ser ting du ikke ser. Skap trygghet for at alle kan si noe.', 3, 8)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Lessons M3 (Oppfølging)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'gode-morgenmoter' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Sette Retning', '## Motiver\n\nGi en tydelig målsetting for dagen. "I dag skal vi bli ferdig med veggen i 2. etasje."', 1, 8),
    ('Noter Det Viktigste', '## Referat?\n\nNei, men noter aksjonspunkter. "Ole bestiller container." "Per sjekker tegning."', 2, 8),
    ('Vær Tilgjengelig', '## Etter Møtet\n\nVær igjen 5 minutter hvis noen trenger å ta opp noe på tomannshånd.', 3, 6)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;


-- =====================================================
-- BAS/BYGGELEDER: KURS 5 - Konflikthåndtering
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Konflikthåndtering',
    'Når det smeller på byggeplassen. Lær å håndtere uenigheter, vanskelige personer og dårlig stemning profesjonelt.',
    'konflikthandtering-bygg',
    TRUE,
    '/courses/konflikthandtering-bygg.png',
    'site_manager'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'konflikthandtering-bygg');

-- Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'konflikthandtering-bygg')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Ta Det Tidlig', 'Forebygging er beste forsvar. Stopp "murringen" før det blir brann.', 1),
    ('Den Vanskelige Samtalen', 'En konkret oppskrift på hvordan du tar praten.', 2),
    ('Etterpåklokskap', 'Lær av konflikten og kom styrket ut som team.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Lessons M1 (Ta Det Tidlig)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'konflikthandtering-bygg' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Se Signalene', '## Dårlig Stemning?\n\nBlikking, himling med øynene, klikker som dannes. Ta tak i det med en gang.', 1, 10),
    ('Kaffepraten', '## Uformell Sjekk\n\n"Virker som det er litt temperatur mellom dere?" En enkel setning kan punktere ballongen.', 2, 10),
    ('Ikke Vær Struts', '## Det Går Ikke Over\n\nKonflikter som ignoreres blir ikke borte, de blir betente. Vær modig nok til å se dem.', 3, 8)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Lessons M2 (Den Vanskelige Samtalen)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'konflikthandtering-bygg' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Forberedelse', '## Fakta, Ikke Følelser\n\nHva har skjedd? Hva er observert? Ikke baser deg på rykter. Ha en plan for samtalen.', 1, 10),
    ('Gjennomføring', '## Oppskriften\n\n1. Beskriv problemet (nøytralt)\n2. Hør deres versjon (lytt!)\n3. Bli enige om løsning/fremtid\n4. Ikke dvel ved fortiden', 2, 15),
    ('Hold Hodet Kaldt', '## Ikke Bli Sint\n\nHvis du mister besinnelsen, har du tapt. Vær rolig, saklig og tydelig leder.', 3, 10)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Lessons M3 (Etterpåklokskap)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'konflikthandtering-bygg' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Følg Opp', '## Holder Avtalen?\n\nSjekk inn etter en uke. "Går det bedre nå?" Viser at du bryr deg.', 1, 8),
    ('Læring For Teamet', '## Hva Skjedde?\n\nUten å henge ut noen: "Vi hadde en uenighet om rydding, nå har vi laget en ny rutine."', 2, 10),
    ('Gå Videre', '## Ferdig Snakka\n\nNår saken er løst, er den løst. Ikke dra det opp igjen.', 3, 6)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;


-- =====================================================
-- BAS/BYGGELEDER: KURS 6 - Planlegging og Fremdrift
-- =====================================================
INSERT INTO courses (title, description, slug, published, cover_image, target_group)
SELECT 'Planlegging og Fremdrift',
    'Lean construction i praksis. Metoder for å fjerne hindringer, involvere teamet og holde tidsplanen - uten stress.',
    'planlegging-og-fremdrift',
    TRUE,
    '/courses/planlegging-og-fremdrift.png',
    'site_manager'
WHERE NOT EXISTS (SELECT 1 FROM courses WHERE slug = 'planlegging-og-fremdrift');

-- Modules
WITH course AS (SELECT id FROM courses WHERE slug = 'planlegging-og-fremdrift')
INSERT INTO course_modules (course_id, title, description, order_index)
SELECT course.id, v.title, v.description, v.order_index
FROM course, (VALUES
    ('Lean Basics', 'Enkle prinsipper som gir flyt i arbeidet.', 1),
    ('Fjerne Hindringer', 'Basens viktigste jobb: Rydde vei for gutta.', 2),
    ('Realistiske Planer', 'Hvordan lage en plan som faktisk holder.', 3)
) AS v(title, description, order_index)
ON CONFLICT DO NOTHING;

-- Lessons M1 (Lean Basics)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'planlegging-og-fremdrift' AND m.order_index = 1
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Flyt', '## Ikke Stopp Opp\n\nMålet er jevn flyt, ikke skippertak. Unngå venting. Venting er sløsing.', 1, 10),
    ('Lappesystemet', '## Visuelt\n\nBruk lapper på veggen. Få oppgavene synlig. Flytt dem fra "Skal gjøres" til "Ferdig".', 2, 12),
    ('Ryddig Plan', '## Oversikt\n\nAlle skal vite hva de skal gjøre i dag og i morgen. Uten å måtte spørre.', 3, 8)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Lessons M2 (Fjerne Hindringer)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'planlegging-og-fremdrift' AND m.order_index = 2
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Hva Stopper Deg?', '## Det Viktigste Spørsmålet\n\nSpørsmål til teamet: "Hva trenger dere for å gjøre jobben?" Materialer? Tegninger? Strøm?', 1, 10),
    ('Logistikk', '## Ting På Rett Plass\n\nSørg for at materialene er der FØR de trengs. Ikke bruk fagarbeidere som bærehjelp hvis du kan unngå det.', 2, 10),
    ('Beslutninger', '## Ikke Vent\n\nManglende svar stopper fremdrift. Mas på prosjektering/byggherre. Få svar.', 3, 8)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- Lessons M3 (Realistiske Planer)
WITH module AS (
    SELECT m.id FROM course_modules m 
    JOIN courses c ON c.id = m.course_id 
    WHERE c.slug = 'planlegging-og-fremdrift' AND m.order_index = 3
)
INSERT INTO lessons (module_id, title, content, order_index, duration_minutes)
SELECT module.id, v.title, v.content, v.order_index, v.duration
FROM module, (VALUES
    ('Involver De Som Bygger', '## De Vet Best\n\nIkke lag planen alene på kontoret. Spør tømreren: "Hvor lang tid tar denne veggen?" De vet best.', 1, 10),
    ('Buffer', '## Ting Skjer\n\nLegg inn buffer. Ting tar alltid lenger tid enn du tror. En plan uten buffer sprekker første dag.', 2, 8),
    ('Revidering', '## Planen Er Levende\n\nOppdater planen hver uke. En gammel plan er verdiløs.', 3, 8)
) AS v(title, content, order_index, duration)
ON CONFLICT DO NOTHING;

-- =====================================================
-- LINK COURSES TO CATEGORY
-- =====================================================
-- All construction courses (both håndverker and bas/byggeleder) belong to the Håndverkere category
WITH cat AS (SELECT id FROM categories WHERE name = 'Håndverkere')
UPDATE courses SET category_id = cat.id
FROM cat
WHERE courses.slug IN (
    'effektiv-kommunikasjon-handverker',
    'ryddig-byggeplass',
    'samarbeid-med-andre-fag',
    'gode-morgenmoter',
    'konflikthandtering-bygg',
    'planlegging-og-fremdrift'
)
AND courses.category_id IS NULL;

-- End of migration
