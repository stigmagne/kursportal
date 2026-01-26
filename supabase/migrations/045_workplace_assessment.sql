-- Migration: 045_workplace_assessment.sql
-- Purpose: Add workplace psychological safety assessment types, dimensions, and questions

-- Create assessment type for team members
INSERT INTO assessment_types (slug, title_no, title_en, description_no, description_en, target_group, min_age)
VALUES (
    'team-member-assessment',
    'Arbeidsmiljø - Team-medlem',
    'Workplace - Team Member',
    'Kartlegg din opplevelse av psykologisk trygghet og arbeidsmiljø som team-medlem.',
    'Assess your experience of psychological safety and work environment as a team member.',
    'team-member',
    18
)
ON CONFLICT (slug) DO NOTHING;

-- Create assessment type for leaders
INSERT INTO assessment_types (slug, title_no, title_en, description_no, description_en, target_group, min_age)
VALUES (
    'team-leader-assessment',
    'Arbeidsmiljø - Leder',
    'Workplace - Leader',
    'Kartlegg din lederpraksis innen psykologisk trygghet og teamutvikling.',
    'Assess your leadership practice in psychological safety and team development.',
    'team-leader',
    18
)
ON CONFLICT (slug) DO NOTHING;

-- =====================================================
-- TEAM MEMBER DIMENSIONS (6)
-- =====================================================

WITH team_member_type AS (SELECT id FROM assessment_types WHERE slug = 'team-member-assessment')
INSERT INTO assessment_dimensions (assessment_type_id, slug, name_no, name_en, description_no, order_index, low_score_interpretation_no, high_score_interpretation_no)
SELECT 
    team_member_type.id,
    v.slug,
    v.name_no,
    v.name_en,
    v.description_no,
    v.order_index,
    v.low_score,
    v.high_score
FROM team_member_type, (VALUES
    ('psychological-safety', 'Psykologisk Trygghet', 'Psychological Safety',
     'Din opplevelse av å kunne si fra, stille spørsmål og ta risiko uten frykt for negative konsekvenser.', 1,
     'Du opplever at det er risikabelt å si fra eller stille spørsmål. Du holder ofte tilbake meninger eller ideer.',
     'Du føler deg trygg på å dele tanker, ideer og bekymringer. Du vet at feil blir sett som læring.'),
    ('belonging', 'Tilhørighet', 'Belonging',
     'Grad av inkludering og følelse av å være en verdsatt del av teamet.', 2,
     'Du føler deg ofte på utsiden eller at du ikke helt passer inn. Din stemme blir ikke alltid hørt.',
     'Du opplever sterk tilhørighet og vet at du er verdsatt for den du er.'),
    ('work-communication', 'Kommunikasjon', 'Communication',
     'Kvaliteten på kommunikasjon med kollegaer og ledere.', 3,
     'Kommunikasjonen på jobb er uklar eller vanskelig. Du føler deg ofte misforstått.',
     'Kommunikasjonen flyter godt. Du blir hørt og forstår andre.'),
    ('work-boundaries', 'Grensesetting', 'Boundaries',
     'Evne til å sette grenser for arbeidsbelastning og tid.', 4,
     'Du sliter med å si nei og tar på deg for mye. Arbeid og fritid glir ofte over i hverandre.',
     'Du har sunne grenser og kan prioritere uten dårlig samvittighet.'),
    ('conflict-handling', 'Konflikthåndtering', 'Conflict Handling',
     'Håndtering av uenigheter og vanskelige situasjoner med kollegaer.', 5,
     'Du unngår konflikter eller opplever at de eskalerer. Vanskelige samtaler er stressende.',
     'Du håndterer uenigheter konstruktivt og kan ta opp vanskelige temaer.'),
    ('growth-mastery', 'Vekst og Mestring', 'Growth and Mastery',
     'Opplevelse av personlig og faglig utvikling på jobben.', 6,
     'Du føler deg stagnert og ser ikke klare utviklingsmuligheter.',
     'Du opplever kontinuerlig læring og ser muligheter for vekst.')
) AS v(slug, name_no, name_en, description_no, order_index, low_score, high_score)
ON CONFLICT (assessment_type_id, slug) DO NOTHING;

-- =====================================================
-- LEADER DIMENSIONS (6)
-- =====================================================

WITH team_leader_type AS (SELECT id FROM assessment_types WHERE slug = 'team-leader-assessment')
INSERT INTO assessment_dimensions (assessment_type_id, slug, name_no, name_en, description_no, order_index, low_score_interpretation_no, high_score_interpretation_no)
SELECT 
    team_leader_type.id,
    v.slug,
    v.name_no,
    v.name_en,
    v.description_no,
    v.order_index,
    v.low_score,
    v.high_score
FROM team_leader_type, (VALUES
    ('creating-safety', 'Skape Trygghet', 'Creating Safety',
     'Din evne som leder til å skape et trygt miljø der folk tør å feile og lære.', 1,
     'Teamet ditt virker forsiktige med å dele eller ta risiko. Feil blir sjelden diskutert åpent.',
     'Du har skapt et miljø der folk deler fritt og ser feil som læringsmuligheter.'),
    ('inclusive-leadership', 'Inkluderende Ledelse', 'Inclusive Leadership',
     'Hvordan du inkluderer alle stemmer og skaper rom for mangfold.', 2,
     'Noen i teamet deltar sjelden, og du har utfordringer med å nå alle.',
     'Alle i teamet bidrar aktivt, og du verdsetter ulike perspektiver.'),
    ('feedback-culture', 'Tilbakemeldingskultur', 'Feedback Culture',
     'Hvordan du gir og mottar tilbakemeldinger.', 3,
     'Tilbakemeldinger gis sjelden eller oppleves som ubehagelige for teamet.',
     'Du har en åpen kultur for tilbakemeldinger som oppleves som støttende.'),
    ('delegation-trust', 'Delegering og Tillit', 'Delegation and Trust',
     'Din evne til å delegere ansvar og vise tillit til teamet.', 4,
     'Du har vanskelig for å slippe kontroll og følger ofte opp i detalj.',
     'Du delegerer med tillit og gir teamet rom for autonomi.'),
    ('leader-conflict', 'Lederens Konflikthåndtering', 'Leader Conflict Handling',
     'Håndtering av konflikter mellom teammedlemmer og i organisasjonen.', 5,
     'Konflikter i teamet blir ofte liggende eller håndteres sent.',
     'Du tar tak i konflikter tidlig og fasiliterer gode løsninger.'),
    ('leader-wellbeing', 'Lederens Egenomsorg', 'Leader Wellbeing',
     'Hvordan du tar vare på deg selv som leder.', 6,
     'Du føler deg ofte overveldet og har lite tid til egen refleksjon og hvile.',
     'Du har gode rutiner for egenomsorg og kan lede fra overskudd.')
) AS v(slug, name_no, name_en, description_no, order_index, low_score, high_score)
ON CONFLICT (assessment_type_id, slug) DO NOTHING;

-- =====================================================
-- TEAM MEMBER QUESTIONS (30)
-- =====================================================

-- Psychological Safety Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'team-member-assessment' AND d.slug = 'psychological-safety'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg tør å si ifra når jeg er uenig med kollegaer eller ledere.', 'I dare to speak up when I disagree with colleagues or managers.', FALSE, 1),
    ('Jeg holder tilbake ideer fordi jeg er redd for hvordan de vil bli mottatt.', 'I hold back ideas because I am afraid of how they will be received.', TRUE, 2),
    ('Det er trygt å innrømme feil på min arbeidsplass.', 'It is safe to admit mistakes at my workplace.', FALSE, 3),
    ('Jeg kan stille spørsmål uten å føle meg dum.', 'I can ask questions without feeling stupid.', FALSE, 4),
    ('Jeg er redd for å bli sett ned på hvis jeg ber om hjelp.', 'I am afraid of being looked down upon if I ask for help.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Belonging Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'team-member-assessment' AND d.slug = 'belonging'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg føler meg som en verdsatt del av teamet.', 'I feel like a valued part of the team.', FALSE, 1),
    ('Min mening blir tatt på alvor i diskusjoner.', 'My opinion is taken seriously in discussions.', FALSE, 2),
    ('Jeg føler meg ofte på utsiden av det sosiale fellesskapet.', 'I often feel on the outside of the social community.', TRUE, 3),
    ('Jeg blir inkludert i viktige samtaler og beslutninger.', 'I am included in important conversations and decisions.', FALSE, 4),
    ('Jeg føler at jeg må endre meg for å passe inn.', 'I feel I have to change myself to fit in.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Work Communication Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'team-member-assessment' AND d.slug = 'work-communication'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg får klar og tydelig informasjon om det jeg trenger for å gjøre jobben min.', 'I receive clear information about what I need to do my job.', FALSE, 1),
    ('Jeg opplever ofte misforståelser med kollegaer.', 'I often experience misunderstandings with colleagues.', TRUE, 2),
    ('Det er enkelt å ta kontakt med lederen min når jeg trenger det.', 'It is easy to contact my manager when I need to.', FALSE, 3),
    ('Jeg føler at jeg blir lyttet til når jeg snakker.', 'I feel listened to when I speak.', FALSE, 4),
    ('Viktig informasjon når meg ofte for sent.', 'Important information often reaches me too late.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Work Boundaries Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'team-member-assessment' AND d.slug = 'work-boundaries'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg klarer å si nei når jeg har for mye å gjøre.', 'I am able to say no when I have too much to do.', FALSE, 1),
    ('Jobben tar ofte over fritiden min.', 'Work often takes over my free time.', TRUE, 2),
    ('Jeg har en sunn balanse mellom jobb og privatliv.', 'I have a healthy work-life balance.', FALSE, 3),
    ('Jeg føler meg skyldig hvis jeg ikke svarer på meldinger utenom arbeidstid.', 'I feel guilty if I do not respond to messages outside working hours.', TRUE, 4),
    ('Arbeidsbelastningen min er håndterbar.', 'My workload is manageable.', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Conflict Handling Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'team-member-assessment' AND d.slug = 'conflict-handling'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg kan ta opp vanskelige temaer med kollegaer på en konstruktiv måte.', 'I can bring up difficult topics with colleagues in a constructive way.', FALSE, 1),
    ('Jeg unngår helst konflikter selv om det skaper problemer.', 'I prefer to avoid conflicts even if it creates problems.', TRUE, 2),
    ('Uenigheter på jobb løses på en respektfull måte.', 'Disagreements at work are resolved in a respectful way.', FALSE, 3),
    ('Jeg vet hvordan jeg skal håndtere det når en kollega oppfører seg urettferdig.', 'I know how to handle it when a colleague behaves unfairly.', FALSE, 4),
    ('Konflikter på jobben min blir sjelden løst ordentlig.', 'Conflicts at my job are rarely resolved properly.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Growth & Mastery Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'team-member-assessment' AND d.slug = 'growth-mastery'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg har muligheter til å lære og utvikle meg på jobb.', 'I have opportunities to learn and develop at work.', FALSE, 1),
    ('Jeg føler meg stagnert i jobben min.', 'I feel stagnant in my job.', TRUE, 2),
    ('Jeg får anerkjennelse for arbeidet jeg gjør.', 'I receive recognition for the work I do.', FALSE, 3),
    ('Feil blir sett som læringsmuligheter, ikke noe å skamme seg over.', 'Mistakes are seen as learning opportunities, not something to be ashamed of.', FALSE, 4),
    ('Min karriereutvikling blir tatt på alvor av min leder.', 'My career development is taken seriously by my manager.', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- =====================================================
-- LEADER QUESTIONS (30)
-- =====================================================

-- Creating Safety Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'team-leader-assessment' AND d.slug = 'creating-safety'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Teamet mitt deler åpent når de er usikre eller har gjort feil.', 'My team openly shares when they are unsure or have made mistakes.', FALSE, 1),
    ('Jeg modellerer sårbarhet ved å innrømme mine egne feil.', 'I model vulnerability by admitting my own mistakes.', FALSE, 2),
    ('Jeg merker at noen i teamet holder tilbake meninger i møter.', 'I notice that some in the team hold back opinions in meetings.', TRUE, 3),
    ('Jeg reagerer rolig og konstruktivt når noen gjør feil.', 'I react calmly and constructively when someone makes a mistake.', FALSE, 4),
    ('Teamet mitt later til å være redde for å fortelle meg dårlige nyheter.', 'My team seems afraid to tell me bad news.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Inclusive Leadership Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'team-leader-assessment' AND d.slug = 'inclusive-leadership'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg sørger for at alle i teamet får mulighet til å bidra i diskusjoner.', 'I ensure that everyone in the team gets the opportunity to contribute in discussions.', FALSE, 1),
    ('Jeg oppsøker aktivt perspektiver som er annerledes enn mine egne.', 'I actively seek perspectives that are different from my own.', FALSE, 2),
    ('Det er noen i teamet jeg ubevisst gir mer oppmerksomhet enn andre.', 'There are some in the team I unconsciously give more attention than others.', TRUE, 3),
    ('Jeg feirer ulikhetene i teamet mitt.', 'I celebrate the differences in my team.', FALSE, 4),
    ('Noen teammedlemmer deltar sjelden i diskusjoner.', 'Some team members rarely participate in discussions.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Feedback Culture Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'team-leader-assessment' AND d.slug = 'feedback-culture'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg gir regelmessig konkret og konstruktiv tilbakemelding.', 'I regularly give specific and constructive feedback.', FALSE, 1),
    ('Jeg spør aktivt om tilbakemelding på min egen ledelse.', 'I actively ask for feedback on my own leadership.', FALSE, 2),
    ('Jeg synes det er vanskelig å gi korrigerende tilbakemelding.', 'I find it difficult to give corrective feedback.', TRUE, 3),
    ('Teamet mitt gir meg ærlig tilbakemelding.', 'My team gives me honest feedback.', FALSE, 4),
    ('Tilbakemeldinger jeg gir blir ofte misforstått eller tatt ille opp.', 'Feedback I give is often misunderstood or taken badly.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Delegation & Trust Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'team-leader-assessment' AND d.slug = 'delegation-trust'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg stoler på at teamet løser oppgaver uten at jeg trenger å følge opp i detalj.', 'I trust the team to complete tasks without me needing to follow up in detail.', FALSE, 1),
    ('Jeg delegerer oppgaver med tydelige forventninger.', 'I delegate tasks with clear expectations.', FALSE, 2),
    ('Jeg tar ofte tilbake oppgaver jeg har delegert fordi jeg gjør dem bedre selv.', 'I often take back tasks I have delegated because I do them better myself.', TRUE, 3),
    ('Teamet mitt har autonomi til å ta beslutninger innen sitt område.', 'My team has autonomy to make decisions within their area.', FALSE, 4),
    ('Jeg føler meg urolig når jeg ikke har oversikt over alt teamet gjør.', 'I feel uneasy when I do not have an overview of everything the team is doing.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Leader Conflict Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'team-leader-assessment' AND d.slug = 'leader-conflict'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg tar tak i konflikter mellom teammedlemmer tidlig.', 'I address conflicts between team members early.', FALSE, 1),
    ('Jeg er komfortabel med å fasilitere vanskelige samtaler.', 'I am comfortable facilitating difficult conversations.', FALSE, 2),
    ('Jeg håper ofte at konflikter løser seg selv.', 'I often hope that conflicts resolve themselves.', TRUE, 3),
    ('Jeg har gode verktøy for å mekle mellom parter i konflikt.', 'I have good tools for mediating between parties in conflict.', FALSE, 4),
    ('Konflikter i teamet mitt har en tendens til å eskalere.', 'Conflicts in my team tend to escalate.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Leader Wellbeing Questions (5)
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'team-leader-assessment' AND d.slug = 'leader-wellbeing'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg tar meg tid til egen refleksjon og hvile.', 'I take time for my own reflection and rest.', FALSE, 1),
    ('Jeg har et støttenettverk jeg kan diskutere lederutfordringer med.', 'I have a support network I can discuss leadership challenges with.', FALSE, 2),
    ('Jeg føler meg ofte overveldet av lederansvaret.', 'I often feel overwhelmed by the leadership responsibility.', TRUE, 3),
    ('Jeg har gode grenser mellom jobb og privatliv.', 'I have good boundaries between work and private life.', FALSE, 4),
    ('Jeg prioriterer teamets behov på bekostning av min egen helse.', 'I prioritize the teams needs at the expense of my own health.', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Update profiles user_type constraint to support new target groups
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_user_type_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_user_type_check 
    CHECK (user_type IS NULL OR user_type IN ('sibling', 'parent', 'both', 'team-member', 'team-leader', 'work-both', 'all'));
