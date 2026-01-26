-- Migration: 037_assessment_system.sql
-- Purpose: Big 5-style assessment system for siblings and parents

-- Assessment types (sibling vs parent)
CREATE TABLE IF NOT EXISTS assessment_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    title_no TEXT NOT NULL,
    title_en TEXT,
    description_no TEXT,
    description_en TEXT,
    target_group TEXT NOT NULL, -- 'sibling' or 'parent'
    min_age INTEGER DEFAULT 18,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Assessment dimensions (what we measure)
CREATE TABLE IF NOT EXISTS assessment_dimensions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assessment_type_id UUID REFERENCES assessment_types(id) ON DELETE CASCADE,
    slug TEXT NOT NULL,
    name_no TEXT NOT NULL,
    name_en TEXT,
    description_no TEXT,
    description_en TEXT,
    order_index INTEGER DEFAULT 0,
    low_score_interpretation_no TEXT,
    high_score_interpretation_no TEXT,
    recommended_course_ids UUID[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(assessment_type_id, slug)
);

-- Assessment questions (statements rated 1-7)
CREATE TABLE IF NOT EXISTS assessment_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dimension_id UUID REFERENCES assessment_dimensions(id) ON DELETE CASCADE,
    statement_no TEXT NOT NULL,
    statement_en TEXT,
    is_reverse_scored BOOLEAN DEFAULT FALSE,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User assessment sessions
CREATE TABLE IF NOT EXISTS assessment_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    assessment_type_id UUID REFERENCES assessment_types(id),
    status TEXT DEFAULT 'in_progress', -- 'in_progress', 'completed'
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User responses (individual answers)
CREATE TABLE IF NOT EXISTS assessment_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES assessment_sessions(id) ON DELETE CASCADE,
    question_id UUID REFERENCES assessment_questions(id),
    score INTEGER CHECK (score >= 1 AND score <= 7),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(session_id, question_id)
);

-- Assessment results (calculated scores per dimension)
CREATE TABLE IF NOT EXISTS assessment_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES assessment_sessions(id) ON DELETE CASCADE,
    dimension_id UUID REFERENCES assessment_dimensions(id),
    raw_score NUMERIC(5,2),
    normalized_score NUMERIC(5,2), -- 0-100 scale
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(session_id, dimension_id)
);

-- Course recommendations based on assessment
CREATE TABLE IF NOT EXISTS assessment_recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES assessment_sessions(id) ON DELETE CASCADE,
    course_id UUID REFERENCES courses(id),
    priority INTEGER DEFAULT 1, -- 1 = highest priority
    reason_no TEXT,
    reason_en TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE assessment_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_dimensions ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_recommendations ENABLE ROW LEVEL SECURITY;

-- Public read for types, dimensions, questions
CREATE POLICY "Anyone can view assessment types"
    ON assessment_types FOR SELECT USING (true);

CREATE POLICY "Anyone can view assessment dimensions"
    ON assessment_dimensions FOR SELECT USING (true);

CREATE POLICY "Anyone can view assessment questions"
    ON assessment_questions FOR SELECT USING (true);

-- Users manage their own sessions
CREATE POLICY "Users can manage own sessions"
    ON assessment_sessions FOR ALL 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own responses"
    ON assessment_responses FOR ALL 
    USING (
        EXISTS (
            SELECT 1 FROM assessment_sessions 
            WHERE id = assessment_responses.session_id 
            AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can view own results"
    ON assessment_results FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM assessment_sessions 
            WHERE id = assessment_results.session_id 
            AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can view own recommendations"
    ON assessment_recommendations FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM assessment_sessions 
            WHERE id = assessment_recommendations.session_id 
            AND user_id = auth.uid()
        )
    );

-- Admin policies
CREATE POLICY "Admins can manage all assessment data"
    ON assessment_types FOR ALL
    USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can manage dimensions"
    ON assessment_dimensions FOR ALL
    USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can manage questions"
    ON assessment_questions FOR ALL
    USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- Indexes
CREATE INDEX idx_assessment_sessions_user ON assessment_sessions(user_id);
CREATE INDEX idx_assessment_responses_session ON assessment_responses(session_id);
CREATE INDEX idx_assessment_results_session ON assessment_results(session_id);
CREATE INDEX idx_assessment_questions_dimension ON assessment_questions(dimension_id);

-- Function to calculate and store results
CREATE OR REPLACE FUNCTION calculate_assessment_results(p_session_id UUID)
RETURNS VOID AS $$
DECLARE
    v_dimension RECORD;
    v_raw_score NUMERIC;
    v_question_count INTEGER;
    v_normalized_score NUMERIC;
BEGIN
    -- For each dimension in this assessment
    FOR v_dimension IN (
        SELECT DISTINCT d.id
        FROM assessment_dimensions d
        JOIN assessment_questions q ON q.dimension_id = d.id
        JOIN assessment_responses r ON r.question_id = q.id
        WHERE r.session_id = p_session_id
    ) LOOP
        -- Calculate raw score (average, handling reverse scoring)
        SELECT 
            AVG(
                CASE 
                    WHEN q.is_reverse_scored THEN 8 - r.score
                    ELSE r.score
                END
            ),
            COUNT(*)
        INTO v_raw_score, v_question_count
        FROM assessment_responses r
        JOIN assessment_questions q ON q.id = r.question_id
        WHERE r.session_id = p_session_id
        AND q.dimension_id = v_dimension.id;
        
        -- Normalize to 0-100 scale
        v_normalized_score := ((v_raw_score - 1) / 6) * 100;
        
        -- Upsert result
        INSERT INTO assessment_results (session_id, dimension_id, raw_score, normalized_score)
        VALUES (p_session_id, v_dimension.id, v_raw_score, v_normalized_score)
        ON CONFLICT (session_id, dimension_id) 
        DO UPDATE SET raw_score = EXCLUDED.raw_score, normalized_score = EXCLUDED.normalized_score;
    END LOOP;
    
    -- Mark session as completed
    UPDATE assessment_sessions 
    SET status = 'completed', completed_at = NOW()
    WHERE id = p_session_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Seed assessment types
INSERT INTO assessment_types (slug, title_no, title_en, description_no, description_en, target_group, min_age)
VALUES 
    ('sibling-assessment', 
     'Vurdering for Søsken', 
     'Sibling Assessment',
     'Denne vurderingen hjelper deg å forstå dine behov og gir personlige anbefalinger for din utviklingsreise.',
     'This assessment helps you understand your needs and provides personalized recommendations for your growth journey.',
     'sibling',
     18),
    ('parent-assessment',
     'Vurdering for Foreldre',
     'Parent Assessment', 
     'Denne vurderingen hjelper deg å forstå familiens dynamikk og gir anbefalinger for hvordan du kan støtte alle barna dine.',
     'This assessment helps you understand your family dynamics and provides recommendations for supporting all your children.',
     'parent',
     18)
ON CONFLICT (slug) DO NOTHING;

-- Seed dimensions for sibling assessment
WITH sibling_type AS (
    SELECT id FROM assessment_types WHERE slug = 'sibling-assessment'
)
INSERT INTO assessment_dimensions (assessment_type_id, slug, name_no, name_en, description_no, order_index, low_score_interpretation_no, high_score_interpretation_no)
SELECT 
    sibling_type.id,
    v.slug,
    v.name_no,
    v.name_en,
    v.description_no,
    v.order_index,
    v.low_score,
    v.high_score
FROM sibling_type, (VALUES
    ('emotional-regulation', 'Emosjonell regulering', 'Emotional Regulation', 
     'Evnen til å gjenkjenne, forstå og håndtere egne følelser', 1,
     'Du kan ha nytte av verktøy for å bedre forstå og håndtere følelsene dine',
     'Du har god kontakt med følelsene dine og mestrer dem godt'),
    ('social-support', 'Sosial støtte', 'Social Support',
     'Opplevelsen av å bli sett, hørt og støttet av andre', 2,
     'Du kan føle deg ensom i din situasjon. Vi anbefaler kurs om å bygge støttenettverk',
     'Du opplever god støtte fra mennesker rundt deg'),
    ('role-responsibility', 'Roller og ansvar', 'Roles and Responsibilities',
     'Opplevelsen av ansvar og forventninger i familien', 3,
     'Du kan ha nytte av å jobbe med grensesetting og egen rolle',
     'Du har en sunn balanse mellom ansvar og egentid'),
    ('identity', 'Identitet', 'Identity',
     'Opplevelsen av egen identitet utenfor familierollen', 4,
     'Du kan ha nytte av å utforske hvem du er utenom "søskenrollen"',
     'Du har en sterk følelse av egen identitet'),
    ('future-orientation', 'Fremtidsorientering', 'Future Orientation',
     'Tanker og følelser om fremtiden', 5,
     'Du kan ha bekymringer om fremtiden som det er verdt å jobbe med',
     'Du har et positivt og realistisk syn på fremtiden'),
    ('communication', 'Kommunikasjon', 'Communication',
     'Åpenhet og kommunikasjon i familien', 6,
     'Det kan være utfordrende å snakke om vanskelige ting i familien',
     'Du opplever god kommunikasjon i familien')
) AS v(slug, name_no, name_en, description_no, order_index, low_score, high_score)
ON CONFLICT (assessment_type_id, slug) DO NOTHING;

-- Seed dimensions for parent assessment
WITH parent_type AS (
    SELECT id FROM assessment_types WHERE slug = 'parent-assessment'
)
INSERT INTO assessment_dimensions (assessment_type_id, slug, name_no, name_en, description_no, order_index, low_score_interpretation_no, high_score_interpretation_no)
SELECT 
    parent_type.id,
    v.slug,
    v.name_no,
    v.name_en,
    v.description_no,
    v.order_index,
    v.low_score,
    v.high_score
FROM parent_type, (VALUES
    ('attention-balance', 'Oppmerksomhetsbalanse', 'Attention Balance', 
     'Evnen til å fordele oppmerksomhet mellom alle barna', 1,
     'Du kan ha nytte av strategier for å gi alle barna kvalitetstid',
     'Du mestrer godt å balansere oppmerksomhet mellom barna'),
    ('sibling-awareness', 'Søskenbevissthet', 'Sibling Awareness',
     'Forståelse for det friske barnets behov og opplevelser', 2,
     'Det kan være verdt å lære mer om hvordan søsken påvirkes',
     'Du er bevisst på det friske barnets behov og opplevelser'),
    ('family-communication', 'Familiekommunikasjon', 'Family Communication',
     'Åpen dialog om sykdom, følelser og utfordringer', 3,
     'Familien kan ha nytte av bedre kommunikasjonsstrategier',
     'Familien har god og åpen kommunikasjon'),
    ('parental-wellbeing', 'Foreldres velvære', 'Parental Wellbeing',
     'Din egen mestring og egenomsorg som forelder', 4,
     'Du kan ha nytte av å fokusere mer på egen egenomsorg',
     'Du tar godt vare på deg selv som forelder'),
    ('partner-relationship', 'Parrelasjonen', 'Partner Relationship',
     'Ivaretakelse av parforholdet under press', 5,
     'Parforholdet kan trenge ekstra oppmerksomhet',
     'Dere ivaretar parforholdet godt tross utfordringene'),
    ('guilt-processing', 'Skyldfølelse', 'Guilt Processing',
     'Håndtering av skyld og skam som forelder', 6,
     'Du kan ha nytte av å bearbeide vanskelige følelser',
     'Du har et sunt forhold til foreldrerollen')
) AS v(slug, name_no, name_en, description_no, order_index, low_score, high_score)
ON CONFLICT (assessment_type_id, slug) DO NOTHING;

-- Seed questions for sibling assessment (5 per dimension = 30 total)
-- Emotional Regulation
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'sibling-assessment' AND d.slug = 'emotional-regulation'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg klarer å sette ord på følelsene mine', 'I can put words to my feelings', FALSE, 1),
    ('Jeg blir ofte overveldet av følelsene mine', 'I often feel overwhelmed by my emotions', TRUE, 2),
    ('Jeg har gode strategier for å roe meg ned når jeg er opprørt', 'I have good strategies to calm down when upset', FALSE, 3),
    ('Det er vanskelig for meg å forstå hva jeg føler', 'It is difficult for me to understand what I feel', TRUE, 4),
    ('Jeg tillater meg selv å føle både positive og negative følelser', 'I allow myself to feel both positive and negative emotions', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Social Support
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'sibling-assessment' AND d.slug = 'social-support'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg har noen jeg kan snakke med om mine utfordringer', 'I have someone I can talk to about my challenges', FALSE, 1),
    ('Jeg føler meg ofte ensom med mine erfaringer', 'I often feel alone with my experiences', TRUE, 2),
    ('Mine venner forstår min familiesituasjon', 'My friends understand my family situation', FALSE, 3),
    ('Jeg får den støtten jeg trenger fra familien min', 'I get the support I need from my family', FALSE, 4),
    ('Jeg føler at andre ikke forstår hva jeg går gjennom', 'I feel that others do not understand what I am going through', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Role and Responsibility  
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'sibling-assessment' AND d.slug = 'role-responsibility'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg tar ofte på meg mer ansvar enn jeg burde', 'I often take on more responsibility than I should', TRUE, 1),
    ('Jeg har nok tid til mine egne aktiviteter og interesser', 'I have enough time for my own activities and interests', FALSE, 2),
    ('Jeg føler at jeg må være den sterke i familien', 'I feel like I have to be the strong one in the family', TRUE, 3),
    ('Det er greit for meg å si nei når noen trenger hjelp', 'It is okay for me to say no when someone needs help', FALSE, 4),
    ('Jeg føler meg skyldig når jeg prioriterer meg selv', 'I feel guilty when I prioritize myself', TRUE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Identity
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'sibling-assessment' AND d.slug = 'identity'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg vet hvem jeg er uavhengig av familiesituasjonen', 'I know who I am regardless of my family situation', FALSE, 1),
    ('Min identitet er sterkt knyttet til å være søsken', 'My identity is strongly tied to being a sibling', TRUE, 2),
    ('Jeg har egne drømmer og mål for fremtiden', 'I have my own dreams and goals for the future', FALSE, 3),
    ('Jeg føler at familiesituasjonen definerer meg', 'I feel that the family situation defines me', TRUE, 4),
    ('Jeg har interesser og aktiviteter som er helt mine egne', 'I have interests and activities that are entirely my own', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Future Orientation
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'sibling-assessment' AND d.slug = 'future-orientation'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg ser lyst på fremtiden', 'I look positively towards the future', FALSE, 1),
    ('Jeg bekymrer meg ofte for hva som vil skje med familien', 'I often worry about what will happen to my family', TRUE, 2),
    ('Jeg tror jeg kan oppnå det jeg ønsker i livet', 'I believe I can achieve what I want in life', FALSE, 3),
    ('Tanker om fremtiden gjør meg engstelig', 'Thoughts about the future make me anxious', TRUE, 4),
    ('Jeg har konkrete planer for min egen fremtid', 'I have concrete plans for my own future', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Communication
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'sibling-assessment' AND d.slug = 'communication'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('I familien min snakker vi åpent om vanskelige ting', 'In my family we talk openly about difficult things', FALSE, 1),
    ('Det er ting jeg ikke kan si til foreldrene mine', 'There are things I cannot say to my parents', TRUE, 2),
    ('Jeg føler at mine behov blir hørt hjemme', 'I feel my needs are heard at home', FALSE, 3),
    ('Vi unngår å snakke om følelser i familien', 'We avoid talking about feelings in our family', TRUE, 4),
    ('Jeg kan være ærlig om hvordan jeg har det', 'I can be honest about how I am doing', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Parent assessment questions (similar structure, abbreviated for brevity)
-- Attention Balance
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'parent-assessment' AND d.slug = 'attention-balance'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg klarer å gi kvalitetstid til hvert barn', 'I manage to give quality time to each child', FALSE, 1),
    ('Jeg bekymrer meg for at det friske barnet får for lite oppmerksomhet', 'I worry that the healthy child gets too little attention', TRUE, 2),
    ('Jeg har rutiner som sikrer individuell tid med alle barna', 'I have routines that ensure individual time with all children', FALSE, 3),
    ('Det meste av min energi går til barnet med diagnose', 'Most of my energy goes to the child with a diagnosis', TRUE, 4),
    ('Alle barna mine føler seg like viktige', 'All my children feel equally important', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Sibling Awareness
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'parent-assessment' AND d.slug = 'sibling-awareness'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg forstår hvordan familiesituasjonen påvirker det friske barnet', 'I understand how the family situation affects the healthy child', FALSE, 1),
    ('Jeg er usikker på hva det friske barnet egentlig føler', 'I am unsure what the healthy child actually feels', TRUE, 2),
    ('Jeg legger merke til tegn på at søsken sliter', 'I notice signs that the sibling is struggling', FALSE, 3),
    ('Det friske barnet klager aldri, så jeg antar det går bra', 'The healthy child never complains, so I assume it is fine', TRUE, 4),
    ('Jeg sjekker aktivt inn med det friske barnet om hvordan det har det', 'I actively check in with the healthy child about how they are doing', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Family Communication
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'parent-assessment' AND d.slug = 'family-communication'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Vi snakker åpent om diagnosen/sykdommen i familien', 'We talk openly about the diagnosis/illness in the family', FALSE, 1),
    ('Jeg synes det er vanskelig å snakke med barna om sykdommen', 'I find it difficult to talk to the children about the illness', TRUE, 2),
    ('Barna kan stille spørsmål og få ærlige svar', 'The children can ask questions and get honest answers', FALSE, 3),
    ('Vi beskytter barna ved å ikke fortelle for mye', 'We protect the children by not telling them too much', TRUE, 4),
    ('Alle i familien får dele sine følelser', 'Everyone in the family gets to share their feelings', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Parental Wellbeing
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'parent-assessment' AND d.slug = 'parental-wellbeing'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg får nok tid til egenomsorg', 'I get enough time for self-care', FALSE, 1),
    ('Jeg føler meg ofte utslitt', 'I often feel exhausted', TRUE, 2),
    ('Jeg har et støttenettverk jeg kan lene meg på', 'I have a support network I can lean on', FALSE, 3),
    ('Mine egne behov kommer alltid sist', 'My own needs always come last', TRUE, 4),
    ('Jeg gjør ting som gir meg energi regelmessig', 'I regularly do things that give me energy', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Partner Relationship
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'parent-assessment' AND d.slug = 'partner-relationship'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Min partner og jeg støtter hverandre godt', 'My partner and I support each other well', FALSE, 1),
    ('Parforholdet har lidd under familiesituasjonen', 'The relationship has suffered from the family situation', TRUE, 2),
    ('Vi finner tid til å være kjærester, ikke bare foreldre', 'We find time to be a couple, not just parents', FALSE, 3),
    ('Vi er ofte uenige om hvordan vi skal håndtere situasjonen', 'We often disagree about how to handle the situation', TRUE, 4),
    ('Vi snakker åpent om hvordan vi har det som par', 'We talk openly about how we are doing as a couple', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;

-- Guilt Processing
WITH dim AS (
    SELECT d.id FROM assessment_dimensions d 
    JOIN assessment_types t ON t.id = d.assessment_type_id 
    WHERE t.slug = 'parent-assessment' AND d.slug = 'guilt-processing'
)
INSERT INTO assessment_questions (dimension_id, statement_no, statement_en, is_reverse_scored, order_index)
SELECT dim.id, v.statement_no, v.statement_en, v.is_reverse, v.idx
FROM dim, (VALUES
    ('Jeg har et sunt forhold til skyldfølelse som forelder', 'I have a healthy relationship with guilt as a parent', FALSE, 1),
    ('Jeg føler meg ofte som en dårlig forelder', 'I often feel like a bad parent', TRUE, 2),
    ('Jeg aksepterer at jeg gjør så godt jeg kan', 'I accept that I am doing the best I can', FALSE, 3),
    ('Skyldfølelse preger hverdagen min', 'Guilt characterizes my everyday life', TRUE, 4),
    ('Jeg er snill mot meg selv når ting er vanskelige', 'I am kind to myself when things are difficult', FALSE, 5)
) AS v(statement_no, statement_en, is_reverse, idx)
ON CONFLICT DO NOTHING;
