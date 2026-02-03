-- Migration 095: Automatic Certificate Issuance Logic
-- Triggered when a user completes a lesson. Checks if all lessons in the course are completed.

CREATE OR REPLACE FUNCTION check_course_completion()
RETURNS TRIGGER AS $$
DECLARE
    v_course_id UUID;
    v_total_lessons INTEGER;
    v_completed_lessons INTEGER;
    v_certificate_exists BOOLEAN;
BEGIN
    -- Only proceed if the lesson is marked as completed
    IF NEW.completed = false THEN
        RETURN NEW;
    END IF;

    -- Get the course_id for the completed lesson
    SELECT cm.course_id INTO v_course_id
    FROM public.lessons l
    JOIN public.course_modules cm ON l.module_id = cm.id
    WHERE l.id = NEW.lesson_id;

    -- If no course found (shouldn't happen), exit
    IF v_course_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Check if certificate already exists to avoid unnecessary counting
    SELECT EXISTS (
        SELECT 1 FROM public.certificates
        WHERE user_id = NEW.user_id AND course_id = v_course_id
    ) INTO v_certificate_exists;

    IF v_certificate_exists THEN
        RETURN NEW;
    END IF;

    -- Count total lessons in the course
    SELECT COUNT(*) INTO v_total_lessons
    FROM public.lessons l
    JOIN public.course_modules cm ON l.module_id = cm.id
    WHERE cm.course_id = v_course_id;

    -- Count completed lessons for the user in this course
    SELECT COUNT(*) INTO v_completed_lessons
    FROM public.lesson_completion lc
    JOIN public.lessons l ON lc.lesson_id = l.id
    JOIN public.course_modules cm ON l.module_id = cm.id
    WHERE lc.user_id = NEW.user_id
    AND cm.course_id = v_course_id
    AND lc.completed = true;

    -- If all lessons are completed, issue certificate
    IF v_completed_lessons >= v_total_lessons THEN
        -- Insert certificate
        -- Note: certificate_number is handled by the trigger in 010_certificates.sql
        INSERT INTO public.certificates (user_id, course_id)
        VALUES (NEW.user_id, v_course_id)
        ON CONFLICT (user_id, course_id) DO NOTHING;
        
        -- Also mark the course as completed in user_progress
        INSERT INTO public.user_progress (user_id, course_id, status, completed_at, last_accessed)
        VALUES (NEW.user_id, v_course_id, 'completed', NOW(), NOW())
        ON CONFLICT (user_id, course_id) 
        DO UPDATE SET 
            status = 'completed',
            completed_at = COALESCE(user_progress.completed_at, NOW()),
            last_accessed = NOW();

        -- The notification trigger in 015_notifications_and_comments.sql 
        -- and email trigger in 020_email_notifications.sql 
        -- will automatically fire after insert into certificates.
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
DROP TRIGGER IF EXISTS trigger_check_course_completion ON public.lesson_completion;

CREATE TRIGGER trigger_check_course_completion
    AFTER INSERT OR UPDATE OF completed ON public.lesson_completion
    FOR EACH ROW
    EXECUTE FUNCTION check_course_completion();
