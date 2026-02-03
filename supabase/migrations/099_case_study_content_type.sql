-- Migration 099: Add Case Study Content Type
-- Adds 'case_study' to content_type enum and adds storage column

-- 1. Add 'case_study' to content_type enum
-- Postgres doesn't support IF NOT EXISTS for enum values directly in a simple way in older versions, 
-- but we can use a safe block.
DO $$
BEGIN
    ALTER TYPE content_type ADD VALUE IF NOT EXISTS 'case_study';
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Add case_study_data column to lesson_content
ALTER TABLE public.lesson_content
ADD COLUMN IF NOT EXISTS case_study_data JSONB;

COMMENT ON COLUMN public.lesson_content.case_study_data IS 'Structured data for case studies: { "situation": "...", "reflection": "...", "learning_point": "..." }';

-- 3. Seed Data (Find appropriate modules/courses to attach to, or create placeholders)
-- For safety, we will insert them into the first available module of a relevant course if it exists, 
-- or generic if not. We'll use a DO block to find a suitable parent.

DO $$
DECLARE
    v_module_id UUID;
    v_lesson_id UUID;
BEGIN
    -- Try to find a module in a Construction Worker or Site Manager course
    SELECT cm.id INTO v_module_id
    FROM public.course_modules cm
    JOIN public.courses c ON c.id = cm.course_id
    WHERE c.slug LIKE '%tomrer%' OR c.slug LIKE '%betong%' OR c.slug LIKE '%bas%'
    LIMIT 1;

    -- If no specific module found, verify if we can use ANY module, otherwise skip seeding to avoid errors
    IF v_module_id IS NULL THEN
        SELECT id INTO v_module_id FROM public.course_modules LIMIT 1;
    END IF;

    IF v_module_id IS NOT NULL THEN
        -- Case 1: Fallulykken i stillaset
        INSERT INTO public.lessons (module_id, title, description, order_index, duration_minutes)
        VALUES (v_module_id, 'HMS Case: Fallulykken', 'Lær av en reell arbeidsulykke', 100, 10)
        RETURNING id INTO v_lesson_id;

        INSERT INTO public.lesson_content (lesson_id, type, order_index, case_study_data)
        VALUES (v_lesson_id, 'case_study', 0, '{
            "situation": "Under arbeid på fasade i 3. etasje skulle stillaset endres. Bas ga beskjed om å ferdigstille raskt før lunsj. En lærling fjernet et rekkverk for å komme til, men glemte å sikre seg. Da han lente seg ut for å ta imot utstyr, mistet han balansen og falt 6 meter rett ned på betongunderlag.",
            "reflection": "Hvilke vurderinger gjorde eller glemte Bas i denne situasjonen? Hvordan kunne tidspresset vært håndtert annerledes?",
            "learning_point": "Bas har et særlig ansvar for å ikke presse på fart som går på bekostning av sikkerhet. Ved endring av stillas SKALfallsikring benyttes hvis kollektiv sikring fjernes. Lærlinger skal aldri utføre risikoarbeid uten direkte tilsyn."
        }');

        -- Case 2: Lekkasjen på badet
        INSERT INTO public.lessons (module_id, title, description, order_index, duration_minutes)
        VALUES (v_module_id, 'Byggfeil Case: Lekkasjen', 'En kostbar feil som kunne vært unngått', 101, 10)
        RETURNING id INTO v_lesson_id;

        INSERT INTO public.lesson_content (lesson_id, type, order_index, case_study_data)
        VALUES (v_lesson_id, 'case_study', 0, '{
            "situation": "I et nytt boligprosjekt oppsto det vannlekkasje fra badet ned i stuen etter 6 måneder. Undersøkelser viste at membranen rundt sluket ikke var tett. Håndverkeren hadde stresset med å bli ferdig før helgen og slurvet med å rengjøre slukmansjetten før oppsmøring.",
            "reflection": "Hva er konsekvensen av ''bare litt støv'' i membranen? Hvorfor er proffe håndverkere ekstra nøye med akkurat dette?",
            "learning_point": "60% av byggfeil er vannrelaterte. Rene overflater og nøyaktighet rundt sluk er kritisk. Det tar 5 minutter ekstra å gjøre det rett, men koster 100.000 kroner å fikse det etterpå."
        }');

        -- Case 3: Krangel om kran-tid
        INSERT INTO public.lessons (module_id, title, description, order_index, duration_minutes)
        VALUES (v_module_id, 'Konflikt Case: Krangel om kran-tid', 'Håndtering av ressurser på byggeplass', 102, 10)
        RETURNING id INTO v_lesson_id;

        INSERT INTO public.lesson_content (lesson_id, type, order_index, case_study_data)
        VALUES (v_lesson_id, 'case_study', 0, '{
            "situation": "Betonglaget og Tømrerlaget trenger begge tårnkranen kl 09:00. Bas for Tømrer mener de har booket den, men Bas for Betong sier de må støpe NÅ før betongen herder. Det oppstår høylytt krangel og kranfører stopper arbeidet i forvirring.",
            "reflection": "Hvordan påvirker denne konflikten hele byggeplassen? Hvordan burde dette vært løst i forkant?",
            "learning_point": "Ressurskonflikter må løses i morgenmøter (driftsmøter), ikke i ''kampens hete''. Hvis akutt behov oppstår, må Basene kommunisere rolig for å finne løsning, eller kontakte byggeleder. Skriking stopper produksjonen."
        }');
    END IF;
END $$;
