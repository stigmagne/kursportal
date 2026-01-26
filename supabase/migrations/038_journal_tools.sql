-- Migration: 038_journal_tools.sql
-- Purpose: Extend journal system with structured tools and measurements

-- Journal tool types (categories of tools)
CREATE TABLE IF NOT EXISTS journal_tool_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    name_no TEXT NOT NULL,
    name_en TEXT,
    description_no TEXT,
    description_en TEXT,
    icon TEXT DEFAULT '📝',
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Journal tools (specific tools available)
CREATE TABLE IF NOT EXISTS journal_tools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tool_type_id UUID REFERENCES journal_tool_types(id),
    slug TEXT UNIQUE NOT NULL,
    name_no TEXT NOT NULL,
    name_en TEXT,
    description_no TEXT,
    description_en TEXT,
    instructions_no TEXT,
    instructions_en TEXT,
    icon TEXT DEFAULT '✨',
    input_type TEXT NOT NULL, -- 'freetext', 'scale', 'structured', 'checklist'
    input_config JSONB DEFAULT '{}', -- config for scales, fields, etc
    nlp_prompts_no TEXT[], -- NLP-based prompts in Norwegian
    nlp_prompts_en TEXT[], -- NLP-based prompts in English
    order_index INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Journal tool entries (user's tool usage, encrypted like journals)
CREATE TABLE IF NOT EXISTS journal_tool_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    tool_id UUID REFERENCES journal_tools(id),
    content_encrypted TEXT NOT NULL, -- AES-256-GCM encrypted content
    iv TEXT NOT NULL, -- Initialization vector
    entry_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Journal measurements (for scale-based tools, stored for charting)
-- Note: The actual value is encrypted, but we store metadata for queries
CREATE TABLE IF NOT EXISTS journal_measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    tool_id UUID REFERENCES journal_tools(id),
    measurement_date DATE DEFAULT CURRENT_DATE,
    encrypted_value TEXT NOT NULL, -- Encrypted numeric value
    iv TEXT NOT NULL,
    time_of_day TEXT, -- 'morning', 'afternoon', 'evening'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE journal_tool_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_tools ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_tool_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_measurements ENABLE ROW LEVEL SECURITY;

-- Public read for tool definitions
CREATE POLICY "Anyone can view tool types"
    ON journal_tool_types FOR SELECT USING (true);

CREATE POLICY "Anyone can view tools"
    ON journal_tools FOR SELECT USING (is_active = true);

-- Users manage their own entries (strictly private)
CREATE POLICY "Users can manage own tool entries"
    ON journal_tool_entries FOR ALL 
    USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own measurements"
    ON journal_measurements FOR ALL 
    USING (auth.uid() = user_id);

-- Admin can manage tool definitions
CREATE POLICY "Admins can manage tool types"
    ON journal_tool_types FOR ALL
    USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "Admins can manage tools"
    ON journal_tools FOR ALL
    USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- Indexes
CREATE INDEX idx_journal_tool_entries_user ON journal_tool_entries(user_id);
CREATE INDEX idx_journal_tool_entries_date ON journal_tool_entries(entry_date);
CREATE INDEX idx_journal_measurements_user ON journal_measurements(user_id);
CREATE INDEX idx_journal_measurements_date ON journal_measurements(measurement_date);

-- Seed tool types
INSERT INTO journal_tool_types (slug, name_no, name_en, description_no, description_en, icon, order_index)
VALUES 
    ('reflection', 'Refleksjon', 'Reflection', 
     'Verktøy for daglig refleksjon og bearbeiding', 
     'Tools for daily reflection and processing', '🪞', 1),
    ('measurement', 'Målinger', 'Measurements',
     'Spor følelser og energi over tid',
     'Track emotions and energy over time', '📊', 2),
    ('gratitude', 'Takknemlighet', 'Gratitude',
     'Fokuser på det positive i hverdagen',
     'Focus on the positive in everyday life', '🙏', 3),
    ('coping', 'Mestring', 'Coping',
     'Verktøy for å håndtere vanskelige situasjoner',
     'Tools for handling difficult situations', '💪', 4)
ON CONFLICT (slug) DO NOTHING;

-- Seed journal tools
-- Emotion Diary (freetext with NLP prompts)
INSERT INTO journal_tools (tool_type_id, slug, name_no, name_en, description_no, description_en, instructions_no, icon, input_type, nlp_prompts_no)
SELECT 
    t.id,
    'emotion-diary',
    'Følelsesdagbok',
    'Emotion Diary',
    'Utforsk og bearbeid følelsene dine gjennom skriving',
    'Explore and process your emotions through writing',
    'Skriv fritt om hvordan du har det i dag. Det er ingen riktige eller gale svar.',
    '💭',
    'freetext',
    ARRAY[
        'Hva legger du merke til i kroppen din akkurat nå?',
        'Hvis følelsen din hadde en farge, hvilken ville det vært?',
        'Hva trenger du mest av alt akkurat nå?',
        'Hva ville du sagt til en venn som følte det du føler?',
        'Hvilken del av dagen ga deg mest energi?'
    ]
FROM journal_tool_types t WHERE t.slug = 'reflection'
ON CONFLICT (slug) DO NOTHING;

-- Emotion Scale (1-10 measurement)
INSERT INTO journal_tools (tool_type_id, slug, name_no, name_en, description_no, description_en, instructions_no, icon, input_type, input_config)
SELECT 
    t.id,
    'emotion-scale',
    'Følelsesskala',
    'Emotion Scale',
    'Vurder ulike følelser på en skala fra 1-10',
    'Rate different emotions on a scale from 1-10',
    'Velg hvor sterkt du opplever hver følelse akkurat nå.',
    '🎚️',
    'scale',
    '{
        "scales": [
            {"id": "happiness", "label_no": "Glede", "label_en": "Happiness", "min": 1, "max": 10, "emoji_low": "😔", "emoji_high": "😊"},
            {"id": "anxiety", "label_no": "Uro/Angst", "label_en": "Anxiety", "min": 1, "max": 10, "emoji_low": "😌", "emoji_high": "😰"},
            {"id": "energy", "label_no": "Energi", "label_en": "Energy", "min": 1, "max": 10, "emoji_low": "🔋", "emoji_high": "⚡"},
            {"id": "connection", "label_no": "Tilknytning", "label_en": "Connection", "min": 1, "max": 10, "emoji_low": "🏝️", "emoji_high": "🤗"},
            {"id": "hope", "label_no": "Håp", "label_en": "Hope", "min": 1, "max": 10, "emoji_low": "☁️", "emoji_high": "🌈"}
        ]
    }'::jsonb
FROM journal_tool_types t WHERE t.slug = 'measurement'
ON CONFLICT (slug) DO NOTHING;

-- Energy Barometer
INSERT INTO journal_tools (tool_type_id, slug, name_no, name_en, description_no, description_en, instructions_no, icon, input_type, input_config)
SELECT 
    t.id,
    'energy-barometer',
    'Energibarometer',
    'Energy Barometer',
    'Spor energinivået ditt gjennom dagen',
    'Track your energy level throughout the day',
    'Noter energinivået ditt på morgenen og kvelden.',
    '⚡',
    'scale',
    '{
        "scales": [
            {"id": "morning", "label_no": "Morgen", "label_en": "Morning", "min": 1, "max": 10, "emoji_low": "😴", "emoji_high": "🌅"},
            {"id": "evening", "label_no": "Kveld", "label_en": "Evening", "min": 1, "max": 10, "emoji_low": "😫", "emoji_high": "✨"}
        ],
        "track_time": true
    }'::jsonb
FROM journal_tool_types t WHERE t.slug = 'measurement'
ON CONFLICT (slug) DO NOTHING;

-- Gratitude Log
INSERT INTO journal_tools (tool_type_id, slug, name_no, name_en, description_no, description_en, instructions_no, icon, input_type, input_config, nlp_prompts_no)
SELECT 
    t.id,
    'gratitude-log',
    'Takknemlighetslogg',
    'Gratitude Log',
    'Tre ting du er takknemlig for i dag',
    'Three things you are grateful for today',
    'Skriv ned tre ting du er takknemlig for. De kan være små eller store.',
    '🙏',
    'structured',
    '{"fields": 3, "field_label": "Jeg er takknemlig for..."}'::jsonb,
    ARRAY[
        'Noe som fikk deg til å smile i dag',
        'En person som har betydd noe for deg',
        'Noe ved kroppen din du setter pris på',
        'Et øyeblikk av ro eller glede',
        'Noe du lærte i dag'
    ]
FROM journal_tool_types t WHERE t.slug = 'gratitude'
ON CONFLICT (slug) DO NOTHING;

-- Worry Box
INSERT INTO journal_tools (tool_type_id, slug, name_no, name_en, description_no, description_en, instructions_no, icon, input_type, nlp_prompts_no)
SELECT 
    t.id,
    'worry-box',
    'Bekymringsboks',
    'Worry Box',
    'Legg fra deg bekymringene dine',
    'Set down your worries',
    'Skriv ned det som bekymrer deg. Tenk på dette som å legge bekymringen i en boks så du kan slippe den for nå.',
    '📦',
    'freetext',
    ARRAY[
        'Hva er det verste som kan skje? Og hvor sannsynlig er det?',
        'Hva kan du gjøre med dette? Hva er utenfor din kontroll?',
        'Hva ville du sagt til en venn med samme bekymring?',
        'Kan du parkere denne bekymringen til i morgen?'
    ]
FROM journal_tool_types t WHERE t.slug = 'coping'
ON CONFLICT (slug) DO NOTHING;

-- Mastery Moments
INSERT INTO journal_tools (tool_type_id, slug, name_no, name_en, description_no, description_en, instructions_no, icon, input_type, input_config, nlp_prompts_no)
SELECT 
    t.id,
    'mastery-moments',
    'Mestringssituasjoner',
    'Mastery Moments',
    'Loggfør øyeblikk hvor du mestret noe vanskelig',
    'Log moments where you mastered something difficult',
    'Beskriv en situasjon hvor du håndterte noe utfordrende.',
    '🏆',
    'structured',
    '{
        "fields": [
            {"id": "situation", "label_no": "Hva skjedde?", "type": "textarea"},
            {"id": "feeling", "label_no": "Hva følte du?", "type": "textarea"},
            {"id": "action", "label_no": "Hva gjorde du?", "type": "textarea"},
            {"id": "learning", "label_no": "Hva lærte du om deg selv?", "type": "textarea"}
        ]
    }'::jsonb,
    ARRAY[
        'Husker du en gang du overrasket deg selv?',
        'Når har du kjent deg sterk i det siste?',
        'Hva ville du vært stolt av å fortelle til noen?'
    ]
FROM journal_tool_types t WHERE t.slug = 'coping'
ON CONFLICT (slug) DO NOTHING;

-- Relationship Reflection
INSERT INTO journal_tools (tool_type_id, slug, name_no, name_en, description_no, description_en, instructions_no, icon, input_type, input_config, nlp_prompts_no)
SELECT 
    t.id,
    'relationship-reflection',
    'Relasjonsrefleksjon',
    'Relationship Reflection',
    'Reflekter over familierelasjoner og dynamikk',
    'Reflect on family relationships and dynamics',
    'Ta deg tid til å reflektere over hvordan du opplever relasjonene i familien.',
    '👨‍👩‍👧‍👦',
    'structured',
    '{
        "fields": [
            {"id": "today", "label_no": "Hvordan var familiedynamikken i dag?", "type": "textarea"},
            {"id": "felt_seen", "label_no": "Følte du deg sett og hørt?", "type": "scale", "min": 1, "max": 5},
            {"id": "need", "label_no": "Hva trengte du som du ikke fikk?", "type": "textarea"},
            {"id": "gave", "label_no": "Hva ga du til andre i dag?", "type": "textarea"}
        ]
    }'::jsonb,
    ARRAY[
        'Hva ønsker du mer av i familien?',
        'Når føler du deg mest tilkoblet?',
        'Hva setter du pris på ved familien din?'
    ]
FROM journal_tool_types t WHERE t.slug = 'reflection'
ON CONFLICT (slug) DO NOTHING;
