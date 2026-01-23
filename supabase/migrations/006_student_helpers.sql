-- Migration 006: Student Experience Helper Functions
-- Purpose: Add utility functions for student course navigation and progress

-- Helper function: Check if user can access a lesson (prerequisites met)
CREATE OR REPLACE FUNCTION can_access_lesson(p_user_id UUID, p_lesson_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_all_prerequisites_met BOOLEAN;
BEGIN
    -- Check if all prerequisite lessons are completed
    SELECT NOT EXISTS (
        SELECT 1 
        FROM lesson_prerequisites lp
        WHERE lp.lesson_id = p_lesson_id
        AND NOT EXISTS (
            SELECT 1 
            FROM lesson_completion lc
            WHERE lc.lesson_id = lp.prerequisite_lesson_id
            AND lc.user_id = p_user_id
        )
    ) INTO v_all_prerequisites_met;
    
    RETURN v_all_prerequisites_met;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function: Check if lesson is unlocked by drip schedule
CREATE OR REPLACE FUNCTION is_lesson_unlocked_by_drip(p_user_id UUID, p_lesson_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_drip_record RECORD;
    v_enrollment_date TIMESTAMPTZ;
    v_unlock_date TIMESTAMPTZ;
BEGIN
    -- Get drip schedule for this lesson
    SELECT * INTO v_drip_record
    FROM drip_schedules
    WHERE lesson_id = p_lesson_id;
    
    -- If no drip schedule, lesson is unlocked
    IF NOT FOUND THEN
        RETURN TRUE;
    END IF;
    
    -- Get user's enrollment date (join through lessons to get course_id)
    SELECT up.created_at INTO v_enrollment_date
    FROM user_progress up
    JOIN course_modules cm ON up.course_id = cm.course_id
    JOIN lessons l ON l.module_id = cm.id
    WHERE up.user_id = p_user_id
    AND l.id = p_lesson_id
    LIMIT 1;
    
    -- If not enrolled, lesson is locked
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- Check unlock conditions based on drip type
    IF v_drip_record.type = 'days_after_enrollment' THEN
        v_unlock_date := v_enrollment_date + (v_drip_record.days_after_enrollment || ' days')::INTERVAL;
        RETURN NOW() >= v_unlock_date;
    ELSIF v_drip_record.type = 'specific_date' THEN
        RETURN NOW() >= v_drip_record.unlock_date;
    END IF;
    
    -- Default: locked
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function: Calculate course progress percentage
CREATE OR REPLACE FUNCTION calculate_course_progress(p_user_id UUID, p_course_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_total_lessons INTEGER;
    v_completed_lessons INTEGER;
    v_progress INTEGER;
BEGIN
    -- Count total lessons in course
    SELECT COUNT(*) INTO v_total_lessons
    FROM lessons l
    JOIN course_modules cm ON l.module_id = cm.id
    WHERE cm.course_id = p_course_id;
    
    -- If no lessons, return 0
    IF v_total_lessons = 0 THEN
        RETURN 0;
    END IF;
    
    -- Count completed lessons (join through lessons to get course_id)
    SELECT COUNT(*) INTO v_completed_lessons
    FROM lesson_completion lc
    JOIN lessons l ON lc.lesson_id = l.id
    JOIN course_modules cm ON l.module_id = cm.id
    WHERE lc.user_id = p_user_id
    AND cm.course_id = p_course_id;
    
    -- Calculate percentage
    v_progress := ROUND((v_completed_lessons::DECIMAL / v_total_lessons::DECIMAL) * 100);
    
    RETURN v_progress;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function: Get next accessible lesson
CREATE OR REPLACE FUNCTION get_next_lesson(p_user_id UUID, p_current_lesson_id UUID)
RETURNS UUID AS $$
DECLARE
    v_module_id UUID;
    v_current_order INTEGER;
    v_next_lesson_id UUID;
    v_course_id UUID;
BEGIN
    -- Get current lesson info
    SELECT module_id, order_index INTO v_module_id, v_current_order
    FROM lessons
    WHERE id = p_current_lesson_id;
    
    -- Try to get next lesson in same module
    SELECT id INTO v_next_lesson_id
    FROM lessons
    WHERE module_id = v_module_id
    AND order_index > v_current_order
    ORDER BY order_index ASC
    LIMIT 1;
    
    -- If found and accessible, return it
    IF FOUND AND can_access_lesson(p_user_id, v_next_lesson_id) 
       AND is_lesson_unlocked_by_drip(p_user_id, v_next_lesson_id) THEN
        RETURN v_next_lesson_id;
    END IF;
    
    -- If not found in same module, try first lesson of next module
    SELECT cm.course_id INTO v_course_id
    FROM course_modules cm
    WHERE cm.id = v_module_id;
    
    SELECT l.id INTO v_next_lesson_id
    FROM lessons l
    JOIN course_modules cm ON l.module_id = cm.id
    WHERE cm.course_id = v_course_id
    AND cm.order_index > (SELECT order_index FROM course_modules WHERE id = v_module_id)
    ORDER BY cm.order_index ASC, l.order_index ASC
    LIMIT 1;
    
    -- Return next lesson if accessible
    IF FOUND AND can_access_lesson(p_user_id, v_next_lesson_id)
       AND is_lesson_unlocked_by_drip(p_user_id, v_next_lesson_id) THEN
        RETURN v_next_lesson_id;
    END IF;
    
    -- No next lesson available
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function: Get previous lesson
CREATE OR REPLACE FUNCTION get_previous_lesson(p_current_lesson_id UUID)
RETURNS UUID AS $$
DECLARE
    v_module_id UUID;
    v_current_order INTEGER;
    v_prev_lesson_id UUID;
    v_course_id UUID;
BEGIN
    -- Get current lesson info
    SELECT module_id, order_index INTO v_module_id, v_current_order
    FROM lessons
    WHERE id = p_current_lesson_id;
    
    -- Try to get previous lesson in same module
    SELECT id INTO v_prev_lesson_id
    FROM lessons
    WHERE module_id = v_module_id
    AND order_index < v_current_order
    ORDER BY order_index DESC
    LIMIT 1;
    
    -- If found, return it
    IF FOUND THEN
        RETURN v_prev_lesson_id;
    END IF;
    
    -- If not found in same module, try last lesson of previous module
    SELECT cm.course_id INTO v_course_id
    FROM course_modules cm
    WHERE cm.id = v_module_id;
    
    SELECT l.id INTO v_prev_lesson_id
    FROM lessons l
    JOIN course_modules cm ON l.module_id = cm.id
    WHERE cm.course_id = v_course_id
    AND cm.order_index < (SELECT order_index FROM course_modules WHERE id = v_module_id)
    ORDER BY cm.order_index DESC, l.order_index DESC
    LIMIT 1;
    
    -- Return previous lesson if found
    IF FOUND THEN
        RETURN v_prev_lesson_id;
    END IF;
    
    -- No previous lesson
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add index for faster lesson completion lookups
CREATE INDEX IF NOT EXISTS idx_lesson_completion_user 
ON lesson_completion(user_id, lesson_id);

CREATE INDEX IF NOT EXISTS idx_user_progress_user_course 
ON user_progress(user_id, course_id);

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION can_access_lesson TO authenticated;
GRANT EXECUTE ON FUNCTION is_lesson_unlocked_by_drip TO authenticated;
GRANT EXECUTE ON FUNCTION calculate_course_progress TO authenticated;
GRANT EXECUTE ON FUNCTION get_next_lesson TO authenticated;
GRANT EXECUTE ON FUNCTION get_previous_lesson TO authenticated;
