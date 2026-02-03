-- Migration: 103_seed_all_module_quizzes.sql
-- Purpose: Add quizzes to every module for the 12 technical courses
-- Method: Uses a temporary function to handle insertions cleanly

CREATE OR REPLACE FUNCTION pg_temp.insert_module_quiz(
    _course_slug TEXT,
    _module_index INT,
    _quiz_title TEXT,
    _questions JSONB
) RETURNS VOID AS $$
DECLARE
    v_module_id UUID;
    v_quiz_id UUID;
    v_question RECORD;
    v_option RECORD;
    v_q_order INT := 1;
BEGIN
    -- Get Module ID
    SELECT m.id INTO v_module_id
    FROM course_modules m
    JOIN courses c ON c.id = m.course_id
    WHERE c.slug = _course_slug AND m.order_index = _module_index;

    IF v_module_id IS NULL THEN
        RAISE NOTICE 'Module not found: % (Index %)', _course_slug, _module_index;
        RETURN;
    END IF;

    -- Create Quiz (if not exists)
    INSERT INTO quizzes (module_id, title, passing_score)
    VALUES (v_module_id, _quiz_title, 80)
    ON CONFLICT DO NOTHING
    RETURNING id INTO v_quiz_id;

    -- If quiz already existed, get its ID
    IF v_quiz_id IS NULL THEN
        SELECT id INTO v_quiz_id FROM quizzes WHERE module_id = v_module_id;
    END IF;

    -- Loop through questions
    FOR v_question IN SELECT * FROM jsonb_to_recordset(_questions) AS x(text text, type text, options jsonb)
    LOOP
        -- Insert Question
        WITH q_insert AS (
            INSERT INTO quiz_questions (quiz_id, question_text, question_type, order_index)
            VALUES (v_quiz_id, v_question.text, v_question.type, v_q_order)
            RETURNING id
        )
        -- Insert Options
        INSERT INTO quiz_answer_options (question_id, option_text, is_correct, order_index)
        SELECT q_insert.id, 
               opt->>'text', 
               (opt->>'is_correct')::boolean,
               idx - 1
        FROM q_insert,
             jsonb_array_elements(v_question.options) WITH ORDINALITY AS t(opt, idx);
        
        v_q_order := v_q_order + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- EXISTING COURSES (from 075, 076)
-- ============================================================================

-- 1. Si Fra Før Det Blir Dyrt
SELECT pg_temp.insert_module_quiz(
    'si-fra-for-det-blir-dyrt', 1, 'Modultest: Hvorfor si fra?',
    '[
        {"text": "Hvorfor er det viktig å si fra om feil?", "type": "multiple_choice", "options": [{"text": "For å spare penger og tid", "is_correct": true}, {"text": "For å sladre på andre", "is_correct": false}]},
        {"text": "Hva skjer hvis vi ignorerer små feil?", "type": "multiple_choice", "options": [{"text": "De kan vokse seg store og dyre", "is_correct": true}, {"text": "De forsvinner av seg selv", "is_correct": false}]},
        {"text": "Hvem har ansvaret for å melde avvik?", "type": "multiple_choice", "options": [{"text": "Alle på byggeplassen", "is_correct": true}, {"text": "Bare verneombudet", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'si-fra-for-det-blir-dyrt', 2, 'Modultest: Kostnader',
    '[
        {"text": "Hva er 1:10:100 regelen?", "type": "multiple_choice", "options": [{"text": "En feil blir tidoblet i kostnad for hvert ledd den går uoppdaget", "is_correct": true}, {"text": "En standard for betongblanding", "is_correct": false}]},
        {"text": "Hva koster mest?", "type": "multiple_choice", "options": [{"text": "Å rette feilen etter at bygget er ferdig", "is_correct": true}, {"text": "Å bruke tid på å gjøre det rett første gang", "is_correct": false}]},
        {"text": "Hvem betaler for feilene våre i lengden?", "type": "multiple_choice", "options": [{"text": "Kunden og til slutt bedriften vår", "is_correct": true}, {"text": "Staten", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'si-fra-for-det-blir-dyrt', 3, 'Modultest: Hvordan si fra?',
    '[
        {"text": "Hvordan bør du si fra om en feil?", "type": "multiple_choice", "options": [{"text": "Saklig og konstruktivt", "is_correct": true}, {"text": "Sint og anklagende", "is_correct": false}]},
        {"text": "Hvem bør du si fra til først?", "type": "multiple_choice", "options": [{"text": "Nærmeste leder eller bas", "is_correct": true}, {"text": "Avisen", "is_correct": false}]},
        {"text": "Er det lov å feile?", "type": "multiple_choice", "options": [{"text": "Ja, hvis vi lærer av det og sier fra", "is_correct": true}, {"text": "Nei, aldri", "is_correct": false}]}
    ]'
);

-- 2. Feilreisen
SELECT pg_temp.insert_module_quiz(
    'feilreisen', 1, 'Modultest: Første feil',
    '[
        {"text": "Hvor oppstår ofte de første feilene?", "type": "multiple_choice", "options": [{"text": "I planlegging eller prosjektering", "is_correct": true}, {"text": "I lunsjen", "is_correct": false}]},
        {"text": "Hva hjelper mot prosjekteringsfeil?", "type": "multiple_choice", "options": [{"text": "Å sjekke tegninger nøye før start", "is_correct": true}, {"text": "Å gjette", "is_correct": false}]},
        {"text": "Kan en liten tegnefeil bli stor ute?", "type": "true_false", "options": [{"text": "Sant", "is_correct": true}, {"text": "Usant", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'feilreisen', 2, 'Modultest: Underveis',
    '[
        {"text": "Hva er en vanlig årsak til utførelsesfeil?", "type": "multiple_choice", "options": [{"text": "Dårlig tid og stress", "is_correct": true}, {"text": "For mye verktøy", "is_correct": false}]},
        {"text": "Hva bør du gjøre hvis du er usikker?", "type": "multiple_choice", "options": [{"text": "Stoppe opp og spørre", "is_correct": true}, {"text": "Bare kjøre på", "is_correct": false}]},
        {"text": "Hjelper det å dekke over en feil?", "type": "multiple_choice", "options": [{"text": "Nei, den kommer for en dag", "is_correct": true}, {"text": "Ja, hvis ingen ser det", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'feilreisen', 3, 'Modultest: Konsekvenser',
    '[
        {"text": "Hva skjer ved overlevering med feil?", "type": "multiple_choice", "options": [{"text": "Reklamasjoner og misfornøyde kunder", "is_correct": true}, {"text": "Ingenting", "is_correct": false}]},
        {"text": "Hvorfor er omdømme viktig?", "type": "multiple_choice", "options": [{"text": "Det sikrer oss nye jobber", "is_correct": true}, {"text": "Det spiller ingen rolle", "is_correct": false}]},
        {"text": "Kan en feil gå ut over sikkerheten?", "type": "true_false", "options": [{"text": "Sant", "is_correct": true}, {"text": "Usant", "is_correct": false}]}
    ]'
);

-- 3. Stolthet Og Kvalitet
SELECT pg_temp.insert_module_quiz(
    'stolthet-og-kvalitet', 1, 'Modultest: Hva er stolthet?',
    '[
        {"text": "Hva betyr yrkesstolthet?", "type": "multiple_choice", "options": [{"text": "Å bry seg om resultatet man leverer", "is_correct": true}, {"text": "Å være arrogant", "is_correct": false}]},
        {"text": "Hvem er kvalitetskontrolløren din?", "type": "multiple_choice", "options": [{"text": "Du selv, i første rekke", "is_correct": true}, {"text": "Kunden", "is_correct": false}]},
        {"text": "Er håndverk et viktig yrke?", "type": "true_false", "options": [{"text": "Sant", "is_correct": true}, {"text": "Usant", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'stolthet-og-kvalitet', 2, 'Modultest: Kvalitetskrav',
    '[
        {"text": "Hva er god nok kvalitet?", "type": "multiple_choice", "options": [{"text": "I henhold til beskrivelse og standard", "is_correct": true}, {"text": "Så lenge det henger sammen", "is_correct": false}]},
        {"text": "Hvorfor følger vi standarder?", "type": "multiple_choice", "options": [{"text": "For å sikre lik og god kvalitet", "is_correct": true}, {"text": "For å gjøre jobben kjedelig", "is_correct": false}]},
        {"text": "Kan man være stolt av en usynlig jobb?", "type": "multiple_choice", "options": [{"text": "Ja, grunnarbeidet er viktigst", "is_correct": true}, {"text": "Nei, bare synlig overflate teller", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'stolthet-og-kvalitet', 3, 'Modultest: Omdømme',
    '[
        {"text": "Hva betyr omdømme for en bedrift?", "type": "multiple_choice", "options": [{"text": "Alt - det avgjør om vi får jobb", "is_correct": true}, {"text": "Lite", "is_correct": false}]},
        {"text": "Hvordan bygger du ditt personlige omdømme?", "type": "multiple_choice", "options": [{"text": "Ved å være pålitelig og dyktig", "is_correct": true}, {"text": "Ved å skylde på andre", "is_correct": false}]},
        {"text": "Smitter dårlig kvalitet?", "type": "multiple_choice", "options": [{"text": "Ja, ''broken windows'' effekten", "is_correct": true}, {"text": "Nei", "is_correct": false}]}
    ]'
);

-- 4. Lederen Som Trygghetsskaper
SELECT pg_temp.insert_module_quiz(
    'lederen-som-trygghetsskaper-bygg', 1, 'Modultest: Psykologisk Trygghet',
    '[
        {"text": "Hva er psykologisk trygghet?", "type": "multiple_choice", "options": [{"text": "At teamet tør å si meningen sin uten frykt", "is_correct": true}, {"text": "At ingen skader seg fysisk", "is_correct": false}]},
        {"text": "Hva skjer i utrygge team?", "type": "multiple_choice", "options": [{"text": "Feil skjules og folk tier stilt", "is_correct": true}, {"text": "Produktiviteten går opp", "is_correct": false}]},
        {"text": "Hvem har hovedansvar for tryggheten?", "type": "multiple_choice", "options": [{"text": "Lederen", "is_correct": true}, {"text": "Verneombudet alene", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'lederen-som-trygghetsskaper-bygg', 2, 'Modultest: Bygge Tillit',
    '[
        {"text": "Hvordan bygger man tillit?", "type": "multiple_choice", "options": [{"text": "Ved å være ærlig og forutsigbar", "is_correct": true}, {"text": "Ved å bestemme alt", "is_correct": false}]},
        {"text": "Hva bryter ned tillit?", "type": "multiple_choice", "options": [{"text": "Løftebrudd og baksnakking", "is_correct": true}, {"text": "Strenge krav", "is_correct": false}]},
        {"text": "Er tillit nødvendig for effektivitet?", "type": "true_false", "options": [{"text": "Sant", "is_correct": true}, {"text": "Usant", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'lederen-som-trygghetsskaper-bygg', 3, 'Modultest: Kultur',
    '[
        {"text": "Hva er bedriftskultur?", "type": "multiple_choice", "options": [{"text": "Måten vi gjør ting på her", "is_correct": true}, {"text": "Fargen på logoen", "is_correct": false}]},
        {"text": "Kan en leder endre kultur?", "type": "multiple_choice", "options": [{"text": "Ja, ved å gå foran som eksempel", "is_correct": true}, {"text": "Nei, kultur er fastlåst", "is_correct": false}]},
        {"text": "Hva er en ''nullfeilskultur'' mot ''læringskultur''?", "type": "multiple_choice", "options": [{"text": "Læringskultur tåler feil for å bli bedre", "is_correct": true}, {"text": "Nullfeilskultur er best", "is_correct": false}]}
    ]'
);

-- 5. Feil Koster - Ditt Ansvar
SELECT pg_temp.insert_module_quiz(
    'feil-koster-ditt-ansvar', 1, 'Modultest: Økonomien i Feil',
    '[
        {"text": "Hva er direkte kostnader ved feil?", "type": "multiple_choice", "options": [{"text": "Materialer og timer for å rette opp", "is_correct": true}, {"text": "Kaffepauser", "is_correct": false}]},
        {"text": "Hva er indirekte kostnader?", "type": "multiple_choice", "options": [{"text": "Tapt omdømme og forsinkelser i andre ledd", "is_correct": true}, {"text": "Lønnsutgifter", "is_correct": false}]},
        {"text": "Spiser feilretting av overskuddet?", "type": "true_false", "options": [{"text": "Sant", "is_correct": true}, {"text": "Usant", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'feil-koster-ditt-ansvar', 2, 'Modultest: Ansvarsfordeling',
    '[
        {"text": "Er feil alltid håndverkerens skyld?", "type": "multiple_choice", "options": [{"text": "Nei, ofte skyldes det system eller planlegging", "is_correct": true}, {"text": "Ja, alltid", "is_correct": false}]},
        {"text": "Hvordan tar man ansvar som leder?", "type": "multiple_choice", "options": [{"text": "Ved å finne årsak og løse problemet", "is_correct": true}, {"text": "Ved å finne en syndebukk", "is_correct": false}]},
        {"text": "Hjelper det å skylde på andre?", "type": "multiple_choice", "options": [{"text": "Nei, det løser ingenting", "is_correct": true}, {"text": "Ja, det føles godt", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'feil-koster-ditt-ansvar', 3, 'Modultest: Forebygging',
    '[
        {"text": "Hva er beste måte å unngå feilkostnader?", "type": "multiple_choice", "options": [{"text": "Gjøre rett første gang", "is_correct": true}, {"text": "Ha god forsikring", "is_correct": false}]},
        {"text": "Er kontrollarbeid lønnsomt?", "type": "multiple_choice", "options": [{"text": "Ja, det forebygger dyrere feil", "is_correct": true}, {"text": "Nei, det tar bare tid", "is_correct": false}]},
        {"text": "Hva betyr KS?", "type": "multiple_choice", "options": [{"text": "Kvalitetssikring", "is_correct": true}, {"text": "Kaffeslabberas", "is_correct": false}]}
    ]'
);

-- 6. Fra Innsikt Til Tiltak
SELECT pg_temp.insert_module_quiz(
    'fra-innsikt-til-tiltak', 1, 'Modultest: Analyse',
    '[
        {"text": "Hva er en rotårsak?", "type": "multiple_choice", "options": [{"text": "Den grunnleggende årsaken til problemet", "is_correct": true}, {"text": "Det man ser ved første øyekast", "is_correct": false}]},
        {"text": "Hva er ''5 Hvorfor''?", "type": "multiple_choice", "options": [{"text": "En metode for å finne rotårsak", "is_correct": true}, {"text": "En lek", "is_correct": false}]},
        {"text": "Hvorfor analyserer vi feil?", "type": "multiple_choice", "options": [{"text": "For å hindre at de skjer igjen", "is_correct": true}, {"text": "For å fordele skyld", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'fra-innsikt-til-tiltak', 2, 'Modultest: Tiltaksutvikling',
    '[
        {"text": "Hva kjennetegner et godt tiltak?", "type": "multiple_choice", "options": [{"text": "Det er konkret og gjennomførbart", "is_correct": true}, {"text": "Det er vagt og generelt", "is_correct": false}]},
        {"text": "Hvem bør være med på å lage tiltak?", "type": "multiple_choice", "options": [{"text": "De som kjenner problemet på kroppen", "is_correct": true}, {"text": "Bare direktøren", "is_correct": false}]},
        {"text": "Er ''skjerpings'' et godt tiltak?", "type": "multiple_choice", "options": [{"text": "Nei, det endrer ingenting", "is_correct": true}, {"text": "Ja, det virker alltid", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'fra-innsikt-til-tiltak', 3, 'Modultest: Implementering',
    '[
        {"text": "Når er et tiltak ferdig implementert?", "type": "multiple_choice", "options": [{"text": "Når det fungerer i hverdagen", "is_correct": true}, {"text": "Når det er skrevet ned", "is_correct": false}]},
        {"text": "Hvorfor må vi følge opp tiltak?", "type": "multiple_choice", "options": [{"text": "For å se om de faktisk virker", "is_correct": true}, {"text": "For moro skyld", "is_correct": false}]},
        {"text": "Hva gjør vi hvis tiltaket ikke virker?", "type": "multiple_choice", "options": [{"text": "Justerer eller prøver noe nytt", "is_correct": true}, {"text": "Gir opp", "is_correct": false}]}
    ]'
);


-- ============================================================================
-- NEW COURSES (from 102)
-- ============================================================================

-- 7. Effektiv Kommunikasjon (Håndverker)
SELECT pg_temp.insert_module_quiz(
    'effektiv-kommunikasjon-handverker', 1, 'Quiz: Unngå Misforståelser',
    '[
        {"text": "Hva kjennetegner aktiv lytting?", "type": "multiple_choice", "options": [{"text": "Du bekrefter innholdet i beskjeden", "is_correct": true}, {"text": "Du tenker på hva du skal si selv", "is_correct": false}]},
        {"text": "Hvorfor bør man stille kontrollspørsmål?", "type": "multiple_choice", "options": [{"text": "For å sikre at man har forstått oppgaven", "is_correct": true}, {"text": "For å virke dum", "is_correct": false}]},
        {"text": "Er det lov å be om skriftlig beskjed?", "type": "true_false", "options": [{"text": "Ja, spesielt ved endringer", "is_correct": true}, {"text": "Nei, det tar for lang tid", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'effektiv-kommunikasjon-handverker', 2, 'Quiz: Digitale Verktøy',
    '[
        {"text": "Hvorfor bør man dokumentere med bilder?", "type": "multiple_choice", "options": [{"text": "Det beviser utført arbeid og kvalitet", "is_correct": true}, {"text": "Det er gøy med selfies", "is_correct": false}]},
        {"text": "Når bør man ta bilde av skjulte føringer?", "type": "multiple_choice", "options": [{"text": "Før man lukker veggen/gulvet", "is_correct": true}, {"text": "Når veggen er malt", "is_correct": false}]},
        {"text": "Er digitale sjekklister godkjent dokumentasjon?", "type": "true_false", "options": [{"text": "Ja, som regel", "is_correct": true}, {"text": "Nei, må være papir", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'effektiv-kommunikasjon-handverker', 3, 'Quiz: Tonefall og Respekt',
    '[
        {"text": "Hvordan påvirker roping arbeidsmiljøet?", "type": "multiple_choice", "options": [{"text": "Det skaper stress og usikkerhet", "is_correct": true}, {"text": "Det motiverer folk", "is_correct": false}]},
        {"text": "Hva betyr respekt for andres fag?", "type": "multiple_choice", "options": [{"text": "At man ikke ødelegger for andre håndverkere", "is_correct": true}, {"text": "At man holder seg unna", "is_correct": false}]},
        {"text": "Hva er en konstruktiv tilbakemelding?", "type": "multiple_choice", "options": [{"text": "Fokus på sak og løsning", "is_correct": true}, {"text": "Personangrep", "is_correct": false}]}
    ]'
);

-- 8. Ryddig Byggeplass (Håndverker)
SELECT pg_temp.insert_module_quiz(
    'ryddig-byggeplass', 1, 'Quiz: HMS og Orden',
    '[
        {"text": "Hva er en vanlig skadeårsak ved rot?", "type": "multiple_choice", "options": [{"text": "Fall og snubling", "is_correct": true}, {"text": "Hørselskade", "is_correct": false}]},
        {"text": "Hvem har ansvar for å rydde etter en jobb?", "type": "multiple_choice", "options": [{"text": "De som har utført jobben", "is_correct": true}, {"text": "Lærlingen alene", "is_correct": false}]},
        {"text": "Kan støv påvirke helsen?", "type": "true_false", "options": [{"text": "Ja, byggstøv kan være skadelig", "is_correct": true}, {"text": "Nei, støv er ufarlig", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'ryddig-byggeplass', 2, 'Quiz: Avfallshåndtering',
    '[
        {"text": "Hvorfor kildesorterer vi?", "type": "multiple_choice", "options": [{"text": "Miljøkrav og kostnadsbesparelser", "is_correct": true}, {"text": "Fordi basen sier det", "is_correct": false}]},
        {"text": "Hva skjer hvis man blander restavfall i gipsen?", "type": "multiple_choice", "options": [{"text": "Hele lasset kan bli nedgradert og dyrere", "is_correct": true}, {"text": "Ingenting", "is_correct": false}]},
        {"text": "Hvor skal batterier og spraybokser?", "type": "multiple_choice", "options": [{"text": "Farlig avfall", "is_correct": true}, {"text": "Restavfall", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'ryddig-byggeplass', 3, 'Quiz: Effektivitet',
    '[
        {"text": "Hvordan påvirker orden effektiviteten?", "type": "multiple_choice", "options": [{"text": "Mindre tid går med til leting", "is_correct": true}, {"text": "Det tar bare tid å rydde", "is_correct": false}]},
        {"text": "Hva er ''fast plass'' prinsippet?", "type": "multiple_choice", "options": [{"text": "At utstyr alltid legges tilbake samme sted", "is_correct": true}, {"text": "At man står stille og jobber", "is_correct": false}]},
        {"text": "Bør man rydde underveis?", "type": "true_false", "options": [{"text": "Ja, det holder plassen trygg og effektiv", "is_correct": true}, {"text": "Nei, ta alt til helgen", "is_correct": false}]}
    ]'
);

-- 9. Samarbeid med Andre Fag (Håndverker)
SELECT pg_temp.insert_module_quiz(
    'samarbeid-med-andre-fag', 1, 'Quiz: Grensesnittene',
    '[
        {"text": "Hvor oppstår flest feil i et bygg?", "type": "multiple_choice", "options": [{"text": "I overganger mellom fag", "is_correct": true}, {"text": "Midt på gulvet", "is_correct": false}]},
        {"text": "Hva må avklares i et grensesnitt?", "type": "multiple_choice", "options": [{"text": "Hvem som gjør hva og rekkefølgen", "is_correct": true}, {"text": "Hvem som skal ha lunsj først", "is_correct": false}]},
        {"text": "Er det lurt å sjekke andres tegninger?", "type": "true_false", "options": [{"text": "Ja, for å se etter kollisjoner", "is_correct": true}, {"text": "Nei, pass dine egne saker", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'samarbeid-med-andre-fag', 2, 'Quiz: Planlegge for Neste',
    '[
        {"text": "Hvorfor bør du tenke på neste faggruppe?", "type": "multiple_choice", "options": [{"text": "For å sikre god fremdrift og kvalitet", "is_correct": true}, {"text": "For å være snill", "is_correct": false}]},
        {"text": "Hva bør du gjøre hvis du ser en feil som vil ramme neste mann?", "type": "multiple_choice", "options": [{"text": "Si fra med en gang", "is_correct": true}, {"text": "Ignorere det", "is_correct": false}]},
        {"text": "Bør føringer merkes?", "type": "multiple_choice", "options": [{"text": "Ja, for å unngå at noen borer i dem", "is_correct": true}, {"text": "Nei, det ser stygt ut", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'samarbeid-med-andre-fag', 3, 'Quiz: Utfordringer',
    '[
        {"text": "Hvordan løser man best en kollisjon?", "type": "multiple_choice", "options": [{"text": "Dialog og felles løsning", "is_correct": true}, {"text": "Førstemann til mølla", "is_correct": false}]},
        {"text": "Hvorfor er det lurt å kjenne de andre på bygget?", "type": "multiple_choice", "options": [{"text": "Det senker terskelen for samarbeid", "is_correct": true}, {"text": "For å låne snus", "is_correct": false}]},
        {"text": "Hvem er sjefen over sluttresultatet?", "type": "multiple_choice", "options": [{"text": "Ingen enkeltperson, det er et teamarbeid", "is_correct": true}, {"text": "Arkitekten", "is_correct": false}]}
    ]'
);

-- 10. Gode Morgenmøter (Bas)
SELECT pg_temp.insert_module_quiz(
    'gode-morgenmoter', 1, 'Quiz: Møtestruktur',
    '[
        {"text": "Hvor langt bør et morgenmøte være?", "type": "multiple_choice", "options": [{"text": "Maks 10-15 minutter", "is_correct": true}, {"text": "Minst 1 time", "is_correct": false}]},
        {"text": "Hva er en god agenda?", "type": "multiple_choice", "options": [{"text": "Gårsdagen, dagens plan, risiko/hindringer", "is_correct": true}, {"text": "Kaffe og prat om fotball", "is_correct": false}]},
        {"text": "Hvorfor stående møter?", "type": "multiple_choice", "options": [{"text": "Det holder effektiviteten oppe", "is_correct": true}, {"text": "Det sparer stoler", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'gode-morgenmoter', 2, 'Quiz: Involvering',
    '[
        {"text": "Hvorfor skal du stille spørsmål i møtet?", "type": "multiple_choice", "options": [{"text": "For å aktivere teamet og avdekke risiko", "is_correct": true}, {"text": "For å teste om de følger med", "is_correct": false}]},
        {"text": "Hva er SJA?", "type": "multiple_choice", "options": [{"text": "Sikker Jobb Analyse", "is_correct": true}, {"text": "Sjelden Jobb Aktivitet", "is_correct": false}]},
        {"text": "Bør lærlingen høres?", "type": "true_false", "options": [{"text": "Ja, alle observasjoner er viktige", "is_correct": true}, {"text": "Nei, de skal bare lytte", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'gode-morgenmoter', 3, 'Quiz: Oppfølging',
    '[
        {"text": "Hva er viktigst å sitte igjen med etter møtet?", "type": "multiple_choice", "options": [{"text": "En klar plan for dagen", "is_correct": true}, {"text": "En god vits", "is_correct": false}]},
        {"text": "Trenger man referat fra morgenmøter?", "type": "multiple_choice", "options": [{"text": "Kun for viktige avklariger/aksjonspunkter", "is_correct": true}, {"text": "Alltid fullt referat", "is_correct": false}]},
        {"text": "Hvor bør basen være etter møtet?", "type": "multiple_choice", "options": [{"text": "Tilgjengelig for spørsmål", "is_correct": true}, {"text": "Låst på kontoret", "is_correct": false}]}
    ]'
);

-- 11. Konflikthåndtering (Bas)
SELECT pg_temp.insert_module_quiz(
    'konflikthandtering-bygg', 1, 'Quiz: Tidlig Innsats',
    '[
        {"text": "Hva er første tegn på konflikt?", "type": "multiple_choice", "options": [{"text": "Endret oppførsel, stillhet, grupperinger", "is_correct": true}, {"text": "Folk ler", "is_correct": false}]},
        {"text": "Hvorfor ta det tidlig?", "type": "multiple_choice", "options": [{"text": "Det er enklere å løse før det låser seg", "is_correct": true}, {"text": "Man bør vente til det går over", "is_correct": false}]},
        {"text": "Bør man ignorere rykter?", "type": "multiple_choice", "options": [{"text": "Nei, sjekk fakta", "is_correct": true}, {"text": "Ja, alltid", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'konflikthandtering-bygg', 2, 'Quiz: Samtalen',
    '[
        {"text": "Hva bør du fokusere på i en konfliktsamtale?", "type": "multiple_choice", "options": [{"text": "Fakta og fremtidig løsning", "is_correct": true}, {"text": "Hvem som har skylda", "is_correct": false}]},
        {"text": "Hvorfor er lytting viktig?", "type": "multiple_choice", "options": [{"text": "For å forstå begge sider av saken", "is_correct": true}, {"text": "For å samle argumenter mot dem", "is_correct": false}]},
        {"text": "Hva hvis du blir sint?", "type": "multiple_choice", "options": [{"text": "Ta en pause, behold roen", "is_correct": true}, {"text": "Skrik tilbake", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'konflikthandtering-bygg', 3, 'Quiz: Læring',
    '[
        {"text": "Hva er målet med konflikthåndtering?", "type": "multiple_choice", "options": [{"text": "Gjenopprette samarbeid og lære", "is_correct": true}, {"text": "Kåre en vinner", "is_correct": false}]},
        {"text": "Bør man følge opp etterpå?", "type": "true_false", "options": [{"text": "Ja, for å sikre at avtalen holdes", "is_correct": true}, {"text": "Nei, saken er ferdig", "is_correct": false}]},
        {"text": "Kan en konflikt styrke teamet?", "type": "multiple_choice", "options": [{"text": "Ja, hvis den løses godt", "is_correct": true}, {"text": "Nei, aldri", "is_correct": false}]}
    ]'
);

-- 12. Planlegging og Fremdrift (Bas)
SELECT pg_temp.insert_module_quiz(
    'planlegging-og-fremdrift', 1, 'Quiz: Lean Prinsipper',
    '[
        {"text": "Hva er hovedmålet med Lean Construction?", "type": "multiple_choice", "options": [{"text": "Maksimal verdi, minimal sløsing (flyt)", "is_correct": true}, {"text": "Jobbe fortest mulig", "is_correct": false}]},
        {"text": "Hva hjelper lappesystemet med?", "type": "multiple_choice", "options": [{"text": "Visuell oversikt og forpliktelse", "is_correct": true}, {"text": "Dekorere veggen", "is_correct": false}]},
        {"text": "Hva er sløsing?", "type": "multiple_choice", "options": [{"text": "Venting, leting, feilretting", "is_correct": true}, {"text": "Kaffepauser", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'planlegging-og-fremdrift', 2, 'Quiz: Hindringer',
    '[
        {"text": "Hva bør basen spørre om hver dag?", "type": "multiple_choice", "options": [{"text": "Hva hindrer dere i å jobbe effektivt?", "is_correct": true}, {"text": "Er dere ferdige snart?", "is_correct": false}]},
        {"text": "Hva er logistikkens rolle?", "type": "multiple_choice", "options": [{"text": "At rett ting er på rett plass til rett tid", "is_correct": true}, {"text": "Å kjøre truck", "is_correct": false}]},
        {"text": "Hvem skal fjerne hindringer?", "type": "multiple_choice", "options": [{"text": "Lederen/Basen", "is_correct": true}, {"text": "De går bort av seg selv", "is_correct": false}]}
    ]'
);
SELECT pg_temp.insert_module_quiz(
    'planlegging-og-fremdrift', 3, 'Quiz: Planlegging',
    '[
        {"text": "Hvem lager den beste fremdriftsplanen?", "type": "multiple_choice", "options": [{"text": "De som skal utføre arbeidet (involvering)", "is_correct": true}, {"text": "En konsulent på kontoret", "is_correct": false}]},
        {"text": "Hvorfor trenger vi buffer?", "type": "multiple_choice", "options": [{"text": "For å håndtere uforutsette ting", "is_correct": true}, {"text": "For å kunne sove lenge", "is_correct": false}]},
        {"text": "Hvor ofte bør planen revideres?", "type": "multiple_choice", "options": [{"text": "Jevnlig (f.eks. ukentlig)", "is_correct": true}, {"text": "Aldri", "is_correct": false}]}
    ]'
);
