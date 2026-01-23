-- Migration 011: Analytics Functions
-- RPC functions for admin analytics dashboard

-- ============================================================================
-- PLATFORM STATS
-- ============================================================================

-- Get overall platform statistics
CREATE OR REPLACE FUNCTION get_platform_stats()
RETURNS JSON AS $$
DECLARE
    result JSON;
    avg_completion DECIMAL;
BEGIN
    -- Calculate average completion rate across all enrollments
    SELECT COALESCE(AVG(prog), 0) INTO avg_completion
    FROM (
        SELECT calculate_course_progress(up.user_id, up.course_id) as prog
        FROM user_progress up
    ) as progress_data;

    SELECT json_build_object(
        'total_students', (SELECT COUNT(*) FROM public.profiles WHERE role = 'student'),
        'total_courses', (SELECT COUNT(*) FROM public.courses WHERE published = true),
        'total_enrollments', (SELECT COUNT(*) FROM public.user_progress),
        'total_certificates', (SELECT COUNT(*) FROM public.certificates),
        'avg_completion_rate', ROUND(avg_completion, 2)
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- COURSE ANALYTICS
-- ============================================================================

-- Get completion rates per course
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
        COUNT(DISTINCT cert.user_id) as completed,
        CASE 
            WHEN COUNT(DISTINCT up.user_id) > 0 
            THEN ROUND((COUNT(DISTINCT cert.user_id)::DECIMAL / COUNT(DISTINCT up.user_id) * 100), 2)
            ELSE 0 
        END as completion_rate
    FROM public.courses c
    LEFT JOIN public.user_progress up ON c.id = up.course_id
    LEFT JOIN public.certificates cert ON cert.course_id = c.id AND cert.user_id = up.user_id
    WHERE c.published = true
    GROUP BY c.id, c.title
    ORDER BY completion_rate DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- QUIZ ANALYTICS
-- ============================================================================

-- Get quiz statistics
CREATE OR REPLACE FUNCTION get_quiz_stats()
RETURNS TABLE (
    quiz_id UUID,
    quiz_title TEXT,
    course_title TEXT,
    total_attempts BIGINT,
    passed_attempts BIGINT,
    pass_rate DECIMAL,
    avg_score DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        q.id,
        q.title,
        c.title as course_title,
        COUNT(qa.id) as total_attempts,
        COUNT(CASE WHEN qa.passed THEN 1 END) as passed_attempts,
        CASE 
            WHEN COUNT(qa.id) > 0 
            THEN ROUND((COUNT(CASE WHEN qa.passed THEN 1 END)::DECIMAL / COUNT(qa.id) * 100), 2)
            ELSE 0 
        END as pass_rate,
        ROUND(COALESCE(AVG(qa.score), 0), 2) as avg_score
    FROM public.quizzes q
    JOIN public.lessons l ON q.lesson_id = l.id
    JOIN public.course_modules cm ON l.module_id = cm.id
    JOIN public.courses c ON cm.course_id = c.id
    LEFT JOIN public.quiz_attempts qa ON q.id = qa.quiz_id
    GROUP BY q.id, q.title, c.title
    HAVING COUNT(qa.id) > 0
    ORDER BY pass_rate DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- PERMISSIONS
-- ============================================================================

-- Grant execute to authenticated users (admin check in RLS)
GRANT EXECUTE ON FUNCTION get_platform_stats() TO authenticated;
GRANT EXECUTE ON FUNCTION get_course_completion_rates() TO authenticated;
GRANT EXECUTE ON FUNCTION get_quiz_stats() TO authenticated;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON FUNCTION get_platform_stats() IS 'Returns overall platform statistics for analytics';
COMMENT ON FUNCTION get_course_completion_rates() IS 'Returns completion rates for all published courses';
COMMENT ON FUNCTION get_quiz_stats() IS 'Returns quiz performance statistics';
