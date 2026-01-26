-- Migration: 046_workplace_journal_tools.sql
-- Purpose: Add workplace-specific journal tools

-- Tool 1: Daglig sjekk-inn
INSERT INTO journal_tool_types (
    name_no, name_en, slug, description_no, description_en, 
    category, icon, schema, target_groups, order_index
)
VALUES (
    'Daglig Sjekk-inn',
    'Daily Check-in',
    'daily-work-checkin',
    'Kort daglig refleksjon over hvordan du har det på jobb.',
    'Brief daily reflection on how you are doing at work.',
    'tracking',
    '📊',
    '{
        "type": "object",
        "properties": {
            "energy_level": {
                "type": "number",
                "minimum": 1,
                "maximum": 10,
                "title": "Energinivå i dag"
            },
            "safety_feeling": {
                "type": "number",
                "minimum": 1,
                "maximum": 10,
                "title": "Følte meg trygg på jobb"
            },
            "main_emotion": {
                "type": "string",
                "title": "Hovedfølelse i dag",
                "enum": ["rolig", "engasjert", "stresset", "frustrert", "motivert", "sliten", "fornøyd", "usikker"]
            },
            "highlight": {
                "type": "string",
                "title": "Dagens høydepunkt"
            }
        },
        "required": ["energy_level", "safety_feeling", "main_emotion"]
    }'::jsonb,
    ARRAY['team-member', 'team-leader'],
    1
)
ON CONFLICT (slug) DO NOTHING;

-- Tool 2: Trygghetsdagbok
INSERT INTO journal_tool_types (
    name_no, name_en, slug, description_no, description_en, 
    category, icon, schema, target_groups, order_index
)
VALUES (
    'Trygghetsdagbok',
    'Safety Journal',
    'safety-journal',
    'Loggfør situasjoner der du følte deg trygg eller utrygg på jobb.',
    'Log situations where you felt safe or unsafe at work.',
    'reflection',
    '🛡️',
    '{
        "type": "object",
        "properties": {
            "situation_type": {
                "type": "string",
                "title": "Type situasjon",
                "enum": ["trygg", "utrygg", "blandet"]
            },
            "what_happened": {
                "type": "string",
                "title": "Hva skjedde?"
            },
            "who_involved": {
                "type": "string",
                "title": "Hvem var involvert? (beskriv rolle, ikke navn)"
            },
            "body_reaction": {
                "type": "string",
                "title": "Hvordan reagerte kroppen din?"
            },
            "what_helped": {
                "type": "string",
                "title": "Hva hjalp (eller kunne hjulpet)?"
            },
            "learning": {
                "type": "string",
                "title": "Hva lærte du av dette?"
            }
        },
        "required": ["situation_type", "what_happened"]
    }'::jsonb,
    ARRAY['team-member', 'team-leader'],
    2
)
ON CONFLICT (slug) DO NOTHING;

-- Tool 3: Feedback-logg
INSERT INTO journal_tool_types (
    name_no, name_en, slug, description_no, description_en, 
    category, icon, schema, target_groups, order_index
)
VALUES (
    'Feedback-logg',
    'Feedback Log',
    'feedback-log',
    'Hold oversikt over tilbakemeldinger du gir og mottar.',
    'Keep track of feedback you give and receive.',
    'structured',
    '💬',
    '{
        "type": "object",
        "properties": {
            "direction": {
                "type": "string",
                "title": "Retning",
                "enum": ["gitt", "mottatt"]
            },
            "feedback_type": {
                "type": "string",
                "title": "Type tilbakemelding",
                "enum": ["positiv", "konstruktiv", "korrigerende"]
            },
            "context": {
                "type": "string",
                "title": "Kontekst (hva handlet det om)"
            },
            "how_delivered": {
                "type": "string",
                "title": "Hvordan ble det levert/mottatt?"
            },
            "reaction": {
                "type": "string",
                "title": "Reaksjon (din eller den andres)"
            },
            "what_to_improve": {
                "type": "string",
                "title": "Hva kunne vært gjort annerledes?"
            }
        },
        "required": ["direction", "feedback_type", "context"]
    }'::jsonb,
    ARRAY['team-member', 'team-leader'],
    3
)
ON CONFLICT (slug) DO NOTHING;

-- Tool 4: Konflikt-refleksjon
INSERT INTO journal_tool_types (
    name_no, name_en, slug, description_no, description_en, 
    category, icon, schema, target_groups, order_index
)
VALUES (
    'Konflikt-refleksjon',
    'Conflict Reflection',
    'conflict-reflection',
    'Analysér og lær av konfliktsituasjoner.',
    'Analyze and learn from conflict situations.',
    'structured',
    '⚡',
    '{
        "type": "object",
        "properties": {
            "conflict_level": {
                "type": "number",
                "minimum": 1,
                "maximum": 10,
                "title": "Alvorlighetsgrad (1-10)"
            },
            "parties_involved": {
                "type": "string",
                "title": "Parter involvert (roller, ikke navn)"
            },
            "trigger": {
                "type": "string",
                "title": "Hva utløste konflikten?"
            },
            "my_role": {
                "type": "string",
                "title": "Min rolle i konflikten"
            },
            "underlying_needs": {
                "type": "string",
                "title": "Underliggende behov (mitt og den andres)"
            },
            "resolution_attempt": {
                "type": "string",
                "title": "Hva prøvde jeg/vi?"
            },
            "outcome": {
                "type": "string",
                "title": "Utfall",
                "enum": ["løst", "pågående", "uløst", "eskalert"]
            },
            "next_steps": {
                "type": "string",
                "title": "Neste steg"
            }
        },
        "required": ["conflict_level", "trigger", "my_role"]
    }'::jsonb,
    ARRAY['team-member', 'team-leader'],
    4
)
ON CONFLICT (slug) DO NOTHING;

-- Tool 5: Grense-tracker
INSERT INTO journal_tool_types (
    name_no, name_en, slug, description_no, description_en, 
    category, icon, schema, target_groups, order_index
)
VALUES (
    'Grense-tracker',
    'Boundary Tracker',
    'boundary-tracker',
    'Følg med på hvordan du holder grensene dine på jobb.',
    'Track how you maintain your boundaries at work.',
    'tracking',
    '🚧',
    '{
        "type": "object",
        "properties": {
            "date": {
                "type": "string",
                "format": "date",
                "title": "Dato"
            },
            "said_no": {
                "type": "boolean",
                "title": "Sa jeg nei når jeg trengte det?"
            },
            "overtime": {
                "type": "boolean",
                "title": "Jobbet jeg overtid?"
            },
            "checked_email_after": {
                "type": "boolean",
                "title": "Sjekket jeg jobb-epost etter arbeidstid?"
            },
            "took_breaks": {
                "type": "boolean",
                "title": "Tok jeg pauser?"
            },
            "boundary_situation": {
                "type": "string",
                "title": "Beskriv en grense-situasjon i dag"
            },
            "how_handled": {
                "type": "string",
                "title": "Hvordan håndterte jeg det?"
            },
            "self_care_action": {
                "type": "string",
                "title": "Hva gjorde jeg for meg selv i dag?"
            }
        },
        "required": ["said_no", "overtime", "took_breaks"]
    }'::jsonb,
    ARRAY['team-member', 'team-leader'],
    5
)
ON CONFLICT (slug) DO NOTHING;
