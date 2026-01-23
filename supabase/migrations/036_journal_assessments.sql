-- Journal Assessments System
-- Adds support for repeatable self-assessments with zero-knowledge encryption

-- Assessment Templates (Admin-defined, unencrypted)
-- These are the "tests" that users can take repeatedly
CREATE TABLE IF NOT EXISTS public.assessment_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    questions JSONB NOT NULL DEFAULT '[]'::jsonb,
    -- Questions format:
    -- [
    --   {"id": "q1", "type": "scale", "text": "How do you feel?", "min": 1, "max": 10, "labels": {"1": "Very bad", "10": "Excellent"}},
    --   {"id": "q2", "type": "text", "text": "Describe your mood"},
    --   {"id": "q3", "type": "choice", "text": "Had negative thoughts?", "options": ["Yes", "No", "Unsure"]}
    -- ]
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS for assessment_templates
ALTER TABLE public.assessment_templates ENABLE ROW LEVEL SECURITY;

-- Admins can manage templates
CREATE POLICY "Admins can manage assessment templates"
    ON assessment_templates FOR ALL
    USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- All authenticated users can view active templates
CREATE POLICY "Users can view active assessment templates"
    ON assessment_templates FOR SELECT
    USING (is_active = true);


-- Journal Assessments (User responses, encrypted)
-- Stores the user's answers to assessments
CREATE TABLE IF NOT EXISTS public.journal_assessments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    template_id UUID REFERENCES assessment_templates(id) ON DELETE SET NULL,
    -- Encrypted responses (same ZK encryption as journals)
    responses_encrypted TEXT NOT NULL,
    iv TEXT NOT NULL,
    -- Optional: unencrypted numeric summary for future aggregation (opt-in)
    -- This allows showing trends without decryption
    -- Example: {"q1": 7, "q3": "Yes"}
    numeric_summary JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS for journal_assessments
ALTER TABLE public.journal_assessments ENABLE ROW LEVEL SECURITY;

-- Users can only access their own assessments (strict ZK policy)
CREATE POLICY "Users can only access own assessments"
    ON journal_assessments FOR ALL
    USING (auth.uid() = user_id);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_journal_assessments_user 
    ON public.journal_assessments(user_id);
CREATE INDEX IF NOT EXISTS idx_journal_assessments_template 
    ON public.journal_assessments(template_id);
CREATE INDEX IF NOT EXISTS idx_journal_assessments_created 
    ON public.journal_assessments(created_at DESC);

-- Seed a default assessment template
INSERT INTO public.assessment_templates (title, description, questions, is_active)
VALUES (
    'Daglig Sinnsstemning',
    'En kort daglig sjekk av hvordan du har det. Ta denne regelmessig for å spore din utvikling.',
    '[
        {"id": "mood", "type": "scale", "text": "Hvordan føler du deg akkurat nå?", "min": 1, "max": 10, "labels": {"1": "Veldig dårlig", "5": "Nøytral", "10": "Utmerket"}},
        {"id": "energy", "type": "scale", "text": "Hvor mye energi har du?", "min": 1, "max": 10, "labels": {"1": "Ingen energi", "10": "Full av energi"}},
        {"id": "anxiety", "type": "scale", "text": "Hvor mye angst eller uro kjenner du?", "min": 1, "max": 10, "labels": {"1": "Ingen", "10": "Svært mye"}},
        {"id": "sleep", "type": "choice", "text": "Hvordan sov du i natt?", "options": ["Veldig dårlig", "Dårlig", "Ok", "Bra", "Veldig bra"]},
        {"id": "thoughts", "type": "text", "text": "Er det noe spesielt på tankene dine i dag?"}
    ]'::jsonb,
    true
) ON CONFLICT DO NOTHING;
