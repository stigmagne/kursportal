-- Migration 013: Fix Analytics Bugs
-- Fixes issues with role filtering and completion counting

-- ============================================================================
-- PLATFORM STATS FIX
-- ============================================================================

CREATE OR REPLACE FUNCTION get_platform_stats()
RETURNS JSON AS $$
DECLARE
    result JSON;
    avg_completion DECIMAL;
BEGIN
    -- Calculate average completion rate across all enrollments
    -- Using user_progress status='completed' (100%) vs others (approximate or 0)
    -- Simplification: If status='completed', progress is 100. Else 0. 
    -- Ideally we'd have a specific progress % column, but for now this is better than nothing.
    SELECT COALESCE(AVG(
        CASE WHEN status = 'completed' THEN 100 ELSE 0 END
    ), 0) INTO avg_completion
    FROM user_progress;

    SELECT json_build_object(
        'total_students', (SELECT COUNT(*) FROM public.profiles WHERE role = 'member'), -- Fixed: was 'student'
        'total_courses', (SELECT COUNT(*) FROM public.courses WHERE published = true),
        'total_enrollments', (SELECT COUNT(*) FROM public.user_progress),
        'total_certificates', (SELECT COUNT(*) FROM public.certificates),
        'avg_completion_rate', ROUND(avg_completion, 2)
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- COURSE ANALYTICS FIX
-- ============================================================================

-- Get completion rates per course
-- Updated to use user_progress.status = 'completed' for completion count
-- Updated to include ALL courses (even drafts) if they have enrollments, or at least be more inclusive.
-- But for "Published Courses" stats, we usually only care about published ones.
-- However, for admin insights, seeing everything is better. 
-- Let's keep it to published courses for consistency with the "Published Courses" stat, 
-- or simply return all courses. The UI charts might get crowded if we return everything.
-- Let's stick to published=true for now but fix the completion logic.

CREATE OR REPLACE FUNCTION get_course_completion_rates()
RETURNS TABLE (
    course_id UUID,
    course_title TEXT,
    total_enrolled BIGINT,
    completed BIGINT,
    completion_rate DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.title,
        COUNT(DISTINCT up.user_id) as total_enrolled,
        COUNT(DISTINCT CASE WHEN up.status = 'completed' THEN up.user_id END) as completed, -- Fixed: use status column
        CASE 
            WHEN COUNT(DISTINCT up.user_id) > 0 
            THEN ROUND((COUNT(DISTINCT CASE WHEN up.status = 'completed' THEN up.user_id END)::DECIMAL / COUNT(DISTINCT up.user_id) * 100), 2)
            ELSE 0 
        END as completion_rate
    FROM public.courses c
    LEFT JOIN public.user_progress up ON c.id = up.course_id
    WHERE c.published = true -- Keep filtering for published courses
    GROUP BY c.id, c.title
    ORDER BY completion_rate DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions again just in case
GRANT EXECUTE ON FUNCTION get_platform_stats() TO authenticated;
GRANT EXECUTE ON FUNCTION get_course_completion_rates() TO authenticated;
