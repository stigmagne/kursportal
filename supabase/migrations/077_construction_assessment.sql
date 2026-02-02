-- Migration: 077_construction_assessment.sql
-- Purpose: Create assessment for construction workers (håndverkere) and site managers (bas/byggeleder)
-- Based on workshop "Fra stille feil til smart kvalitet"

-- =====================================================
-- ASSESSMENT TYPE: Byggekvalitet - Håndverker
-- =====================================================
INSERT INTO assessment_types (slug, title_no, title_en, description_no, description_en, target_group, min_age)
VALUES (
    'construction-worker-assessment',
    'Kvalitetskultur - Fagarbeider',
    'Quality Culture - Construction Worker',
    'Kartlegging av kvalitetskultur, trygghet og feilforebygging for fagarbeidere i byggebransjen.',
    'Assessment of quality culture, safety and error prevention for construction workers.',
    'construction_worker',
    18
)
ON CONFLICT (slug) DO NOTHING;

-- =====================================================
-- ASSESSMENT TYPE: Byggekvalitet - Bas/Byggeleder
-- =====================================================
INSERT INTO assessment_types (slug, title_no, title_en, description_no, description_en, target_group, min_age)
VALUES (
    'site-manager-assessment',
    'Kvalitetskultur - Bas/Byggeleder',
    'Quality Culture - Site Manager',
    'Kartlegging av lederpraksis innen kvalitet, trygghet og feilforebygging i byggebransjen.',
    'Assessment of leadership practice in quality, safety and error prevention in construction.',
    'site_manager',
    18
)
ON CONFLICT (slug) DO NOTHING;

-- =====================================================
-- CONSTRUCTION WORKER DIMENSIONS (5)
-- =====================================================

WITH construction_worker_type AS (SELECT id FROM assessment_types WHERE slug = 'construction-worker-assessment')
INSERT INTO assessment_dimensions (assessment_type_id, slug, name_no, name_en, description_no, order_index, low_score_interpretation_no, high_score_interpretation_no)
SELECT 
    construction_worker_type.id,
    v.slug,
    v.name_no,
    v.name_en,
    v.description_no,
    v.order_index,
    v.low_score,
    v.high_score
FROM construction_worker_type, (VALUES
    ('speaking-up', 'Å Si Fra', 'Speaking Up',
     'Evne og trygghet til å si fra når noe ikke stemmer.', 1,
     'Du holder ofte tilbake når du ser noe som ikke stemmer. Du føler det er risikabelt å stille spørsmål.',
     'Du sier fra når du ser noe som ikke stemmer. Du føler deg trygg på å spørre og avklare.'),
    ('error-understanding', 'Feilforståelse', 'Error Understanding',
     'Forståelse av hvordan feil oppstår og utvikler seg til reklamasjoner.', 2,
     'Du har begrenset innsikt i hvordan små usikkerheter blir til dyre reklamasjoner.',
     'Du forstår feilens livssyklus og vet hvor og hvordan feil kan stoppes tidlig.'),
    ('quality-culture', 'Kvalitetskultur', 'Quality Culture',
     'Opplevelse av kvalitetsfokus i team og organisasjon.', 3,
     'Tempo prioriteres ofte over kvalitet. Sjekk-rutiner er mangelfulle.',
     'Kvalitet og tempo er i balanse. Dere har gode rutiner for kvalitetskontroll.'),
    ('collaboration', 'Samarbeid', 'Collaboration',
     'Evne til å samarbeide og støtte kolleger for bedre kvalitet.', 4,
     'Du jobber mye alene og ber sjelden om innspill fra kolleger.',
     'Du bruker kolleger aktivt for kvalitetssjekk og deler erfaringer åpent.'),
    ('professional-pride', 'Fagstolthet', 'Professional Pride',
     'Sunn fagstolthet som driver kvalitet, ikke blokkerer den.', 5,
     'Stoltheten din kan gjøre det vanskelig å innrømme usikkerhet eller be om hjelp.',
     'Du er stolt av faget ditt og ser det å spørre som et tegn på profesjonalitet.')
) AS v(slug, name_no, name_en, description_no, order_index, low_score, high_score)
ON CONFLICT (assessment_type_id, slug) DO NOTHING;

-- =====================================================
-- SITE MANAGER DIMENSIONS (5)
-- =====================================================

WITH site_manager_type AS (SELECT id FROM assessment_types WHERE slug = 'site-manager-assessment')
INSERT INTO assessment_dimensions (assessment_type_id, slug, name_no, name_en, description_no, order_index, low_score_interpretation_no, high_score_interpretation_no)
SELECT 
    site_manager_type.id,
    v.slug,
    v.name_no,
    v.name_en,
    v.description_no,
    v.order_index,
    v.low_score,
    v.high_score
FROM site_manager_type, (VALUES
    ('creating-safety', 'Skape Trygghet', 'Creating Safety',
     'Din evne til å skape et miljø der folk tør å si fra og spørre.', 1,
     'Teamet ditt virker forsiktige med å dele usikkerhet eller stille spørsmål.',
     'Du har skapt et miljø der folk deler åpent og tør å stoppe opp ved usikkerhet.'),
    ('error-economics', 'Feil og Økonomi', 'Error Economics',
     'Forståelse av økonomien bak reklamasjoner og tidlig stopp.', 2,
     'Du har begrenset oversikt over de faktiske kostnadene ved feil og reklamasjoner.',
     'Du forstår kostnadskurven og investerer målrettet i forebygging.'),
    ('quality-routines', 'Kvalitetsrutiner', 'Quality Routines',
     'Rutiner for kvalitetskontroll før, under og etter arbeid.', 3,
     'Kvalitetskontroll skjer uregelmessig eller kun når problemer oppstår.',
     'Dere har tydelige stopp-punkter og rutiner for kvalitetssikring.'),
    ('constructive-response', 'Konstruktiv Respons', 'Constructive Response',
     'Hvordan du håndterer feil og nesten-feil i teamet.', 4,
     'Feil fører ofte til fokus på skyld fremfor læring. Folk blir defensive.',
     'Feil håndteres konstruktivt med fokus på systemer og forbedring.'),
    ('implementation', 'Implementering', 'Implementation',
     'Evne til å gjøre innsikt om til konkrete, varige tiltak.', 5,
     'Gode intensjoner blir sjelden til varige rutiner. Tiltak forsvinner etter kort tid.',
     'Du implementerer tiltak systematisk og følger opp at de faktisk gjennomføres.')
) AS v(slug, name_no, name_en, description_no, order_index, low_score, high_score)
ON CONFLICT (assessment_type_id, slug) DO NOTHING;

-- =====================================================
-- CONSTRUCTION WORKER QUESTIONS (25)
-- =====================================================

-- Speaking Up Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'construction-worker-assessment' AND d.slug = 'speaking-up'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Når jeg ser at noe ikke stemmer på en jobb, sier jeg fra til leder eller kolleger.', 'When I see something is not right on a job, I speak up to my manager or colleagues.', FALSE, 1),
    ('Jeg føler meg trygg på å stille spørsmål, selv om det kan virke som om jeg burde vite svaret.', 'I feel safe asking questions, even if it might seem like I should know the answer.', FALSE, 2),
    ('På min arbeidsplass blir folk som sier fra behandlet med respekt.', 'At my workplace, people who speak up are treated with respect.', FALSE, 3),
    ('Tidspress gjør det ofte vanskelig å stoppe opp og avklare usikkerheter.', 'Time pressure often makes it difficult to stop and clarify uncertainties.', TRUE, 4),
    ('Jeg har opplevd situasjoner der jeg visste noe var galt, men ikke sa fra.', 'I have experienced situations where I knew something was wrong but did not speak up.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Error Understanding Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'construction-worker-assessment' AND d.slug = 'error-understanding'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg forstår hvordan små usikkerheter kan utvikle seg til dyre reklamasjoner.', 'I understand how small uncertainties can develop into expensive complaints.', FALSE, 1),
    ('På min arbeidsplass diskuterer vi feil som noe vi kan lære av, ikke noe å skylde på noen for.', 'At my workplace, we discuss errors as learning opportunities, not blame.', FALSE, 2),
    ('Jeg vet at forsikringen vanligvis ikke dekker kostnaden ved å rette eget arbeid.', 'I know that insurance usually does not cover the cost of correcting our own work.', FALSE, 3),
    ('Nesten-feil blir delt og lært av i teamet mitt.', 'Near-misses are shared and learned from in my team.', FALSE, 4),
    ('Vi har gode rutiner for å fange opp feil før de låser seg.', 'We have good routines for catching errors before they become locked in.', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Quality Culture Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'construction-worker-assessment' AND d.slug = 'quality-culture'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Kvalitet prioriteres like høyt som tempo på min arbeidsplass.', 'Quality is prioritized as highly as speed at my workplace.', FALSE, 1),
    ('Vi har tid til å gjøre jobben riktig første gang.', 'We have time to do the job right the first time.', FALSE, 2),
    ('Lederne våre går foran som gode eksempler når det gjelder kvalitet.', 'Our leaders set good examples when it comes to quality.', FALSE, 3),
    ('Det er tydelig hvem som har ansvar for kvalitet i ulike faser av arbeidet.', 'It is clear who is responsible for quality in different phases of work.', FALSE, 4),
    ('Vi bruker sjekklister eller kvalitetskontroller på kritiske punkter.', 'We use checklists or quality controls at critical points.', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Collaboration Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'construction-worker-assessment' AND d.slug = 'collaboration'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg ber regelmessig kolleger om å kaste et blikk på arbeidet mitt før jeg avslutter.', 'I regularly ask colleagues to take a look at my work before I finish.', FALSE, 1),
    ('Folk på min arbeidsplass hjelper hverandre å fange opp feil.', 'People at my workplace help each other catch errors.', FALSE, 2),
    ('Kommunikasjonen mellom ulike fag fungerer godt på prosjektene mine.', 'Communication between different trades works well on my projects.', FALSE, 3),
    ('Jeg føler meg komfortabel med å gi tilbakemelding til kolleger om deres arbeid.', 'I feel comfortable giving feedback to colleagues about their work.', FALSE, 4),
    ('Vi har gode rutiner for å koordinere overganger mellom fag og faser.', 'We have good routines for coordinating transitions between trades and phases.', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Professional Pride Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'construction-worker-assessment' AND d.slug = 'professional-pride'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg er stolt av kvaliteten på arbeidet jeg leverer.', 'I am proud of the quality of work I deliver.', FALSE, 1),
    ('Jeg føler at å spørre er et tegn på profesjonalitet, ikke svakhet.', 'I feel that asking is a sign of professionalism, not weakness.', FALSE, 2),
    ('Jeg gjør arbeid riktig selv når ingen ser på.', 'I do work correctly even when no one is watching.', FALSE, 3),
    ('Mitt rykte som fagarbeider betyr mye for meg.', 'My reputation as a skilled worker means a lot to me.', FALSE, 4),
    ('Jeg synes det er vanskelig å innrømme usikkerhet overfor kolleger.', 'I find it difficult to admit uncertainty to colleagues.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- =====================================================
-- SITE MANAGER QUESTIONS (25)
-- =====================================================

-- Creating Safety Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'site-manager-assessment' AND d.slug = 'creating-safety'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Teamet mitt deler åpent når de er usikre eller har gjort feil.', 'My team openly shares when they are unsure or have made mistakes.', FALSE, 1),
    ('Jeg modellerer sårbarhet ved å innrømme mine egne feil.', 'I model vulnerability by admitting my own mistakes.', FALSE, 2),
    ('Jeg merker at noen i teamet holder tilbake meninger eller spørsmål.', 'I notice that some in the team hold back opinions or questions.', TRUE, 3),
    ('Jeg reagerer rolig og konstruktivt når noen sier fra om usikkerhet.', 'I react calmly and constructively when someone speaks up about uncertainty.', FALSE, 4),
    ('Teamet mitt later til å være redde for å fortelle meg dårlige nyheter.', 'My team seems afraid to tell me bad news.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Error Economics Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'site-manager-assessment' AND d.slug = 'error-economics'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg har god oversikt over de faktiske kostnadene ved reklamasjoner i mine prosjekter.', 'I have good insight into the actual costs of complaints in my projects.', FALSE, 1),
    ('Jeg forstår forskjellen på hva forsikring dekker og hva bedriften må betale selv.', 'I understand the difference between what insurance covers and what the company pays itself.', FALSE, 2),
    ('Jeg prioriterer ressurser til forebygging, ikke bare brannslukking.', 'I prioritize resources for prevention, not just firefighting.', FALSE, 3),
    ('Jeg vet hvor i prosessen de fleste feil oppstår på mine prosjekter.', 'I know where in the process most errors occur on my projects.', FALSE, 4),
    ('Jeg måler og følger opp kostnadene ved feil og reklamasjoner systematisk.', 'I measure and follow up on the costs of errors and complaints systematically.', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Quality Routines Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'site-manager-assessment' AND d.slug = 'quality-routines'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Vi har tydelige rutiner for kvalitetskontroll før kritiske faser.', 'We have clear routines for quality control before critical phases.', FALSE, 1),
    ('Jeg sørger for at det er tid til avklaringer før arbeid starter.', 'I ensure there is time for clarifications before work starts.', FALSE, 2),
    ('Vi dokumenterer stopp-og-sjekk underveis i arbeidet.', 'We document stop-and-check during work.', FALSE, 3),
    ('Vi har gode rutiner for å evaluere og lære etter feil eller nesten-feil.', 'We have good routines for evaluating and learning after errors or near-misses.', FALSE, 4),
    ('Kvalitetskontrollen vår er mest reaktiv - vi reagerer når noe går galt.', 'Our quality control is mostly reactive - we react when something goes wrong.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Constructive Response Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'site-manager-assessment' AND d.slug = 'constructive-response'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Når feil skjer, fokuserer jeg på systemer og prosesser fremfor enkeltpersoner.', 'When errors occur, I focus on systems and processes rather than individuals.', FALSE, 1),
    ('Jeg anerkjenner aktivt de som stopper feil eller sier fra om usikkerhet.', 'I actively acknowledge those who stop errors or speak up about uncertainty.', FALSE, 2),
    ('Nesten-feil deles og læres av i teamet mitt.', 'Near-misses are shared and learned from in my team.', FALSE, 3),
    ('Folk blir defensive når vi diskuterer feil.', 'People become defensive when we discuss errors.', TRUE, 4),
    ('Jeg skaper rom for å diskutere feil åpent uten fokus på skyld.', 'I create space to discuss errors openly without focusing on blame.', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Implementation Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'site-manager-assessment' AND d.slug = 'implementation'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Når vi beslutter tiltak, er det tydelig hvem som har ansvar for gjennomføring.', 'When we decide on actions, it is clear who is responsible for implementation.', FALSE, 1),
    ('Vi tester nye rutiner i liten skala før vi ruller dem ut bredt.', 'We test new routines on a small scale before rolling them out widely.', FALSE, 2),
    ('Tiltak vi iverksetter blir fulgt opp systematisk over tid.', 'Actions we implement are followed up systematically over time.', FALSE, 3),
    ('Gode intensjoner blir ofte til varige rutiner hos oss.', 'Good intentions often become lasting routines with us.', FALSE, 4),
    ('Vi justerer tiltak basert på erfaringer underveis.', 'We adjust actions based on experiences along the way.', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- =====================================================
-- COURSE RECOMMENDATIONS
-- =====================================================

-- Construction Worker: Speaking Up -> Si Fra Før Det Blir Dyrt
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug = 'si-fra-for-det-blir-dyrt'
)
WHERE slug = 'speaking-up' 
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'construction-worker-assessment');

-- Construction Worker: Error Understanding -> Feilreisen
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug = 'feilreisen'
)
WHERE slug = 'error-understanding' 
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'construction-worker-assessment');

-- Construction Worker: Quality Culture -> Si Fra + Stolthet
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug IN ('si-fra-for-det-blir-dyrt', 'stolthet-og-kvalitet')
)
WHERE slug = 'quality-culture' 
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'construction-worker-assessment');

-- Construction Worker: Collaboration -> Stolthet Og Kvalitet
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug = 'stolthet-og-kvalitet'
)
WHERE slug = 'collaboration' 
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'construction-worker-assessment');

-- Construction Worker: Professional Pride -> Stolthet Og Kvalitet
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug = 'stolthet-og-kvalitet'
)
WHERE slug = 'professional-pride' 
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'construction-worker-assessment');

-- Site Manager: Creating Safety -> Lederen Som Trygghetsskaper
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug = 'lederen-som-trygghetsskaper-bygg'
)
WHERE slug = 'creating-safety' 
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'site-manager-assessment');

-- Site Manager: Error Economics -> Feil Koster
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug = 'feil-koster-ditt-ansvar'
)
WHERE slug = 'error-economics' 
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'site-manager-assessment');

-- Site Manager: Quality Routines -> Fra Innsikt Til Tiltak
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug = 'fra-innsikt-til-tiltak'
)
WHERE slug = 'quality-routines' 
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'site-manager-assessment');

-- Site Manager: Constructive Response -> Lederen Som Trygghetsskaper
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug = 'lederen-som-trygghetsskaper-bygg'
)
WHERE slug = 'constructive-response' 
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'site-manager-assessment');

-- Site Manager: Implementation -> Fra Innsikt Til Tiltak
UPDATE assessment_dimensions 
SET recommended_course_ids = ARRAY(
    SELECT id FROM courses WHERE slug = 'fra-innsikt-til-tiltak'
)
WHERE slug = 'implementation' 
AND assessment_type_id = (SELECT id FROM assessment_types WHERE slug = 'site-manager-assessment');

-- Update profiles user_type constraint to support new target groups
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_user_type_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_user_type_check 
    CHECK (user_type IS NULL OR user_type IN ('sibling', 'parent', 'both', 'team-member', 'team-leader', 'work-both', 'all', 'construction_worker', 'site_manager'));

-- End of migration
