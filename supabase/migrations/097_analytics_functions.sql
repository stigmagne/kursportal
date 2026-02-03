-- Function to get daily active users for the last 30 days
-- Used for the Admin Analytics Dashboard

CREATE OR REPLACE FUNCTION get_daily_activity_stats(days_lookback INTEGER DEFAULT 30)
RETURNS TABLE (
    date TEXT,
    active_users INTEGER,
    completions INTEGER
) AS $$
BEGIN
    RETURN QUERY
    WITH date_series AS (
        SELECT generate_series(
            CURRENT_DATE - (days_lookback - 1) * INTERVAL '1 day',
            CURRENT_DATE,
            '1 day'
        )::DATE AS day
    )
    SELECT 
        to_char(ds.day, 'YYYY-MM-DD') as date,
        COUNT(DISTINCT up.user_id)::INTEGER as active_users,
        COUNT(DISTINCT CASE WHEN up.status = 'completed' AND date_trunc('day', up.completed_at) = ds.day THEN up.user_id END)::INTEGER as completions
    FROM date_series ds
    LEFT JOIN user_progress up 
        ON date_trunc('day', up.last_accessed) = ds.day
    GROUP BY ds.day
    ORDER BY ds.day ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
