-- Migration 085: Gamification System
-- Adds badges, XP tracking, and streak system

-- ============================================
-- 1. BADGES DEFINITION
-- ============================================

CREATE TABLE IF NOT EXISTS badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT UNIQUE NOT NULL,
    name_no TEXT NOT NULL,
    name_en TEXT NOT NULL,
    description_no TEXT,
    description_en TEXT,
    icon TEXT NOT NULL,              -- Lucide icon name (e.g., 'Sparkles', 'Trophy')
    icon_color TEXT DEFAULT '#000000', -- Hex color for the icon
    xp_reward INTEGER DEFAULT 0,
    criteria JSONB,                  -- {"type": "lessons_completed", "count": 5}
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Insert default badges with Lucide icons and neo-brutalist colors
INSERT INTO badges (slug, name_no, name_en, description_no, description_en, icon, icon_color, xp_reward, criteria, sort_order) VALUES
    ('newbie', 'Nybegynner', 'Newbie', 'Velkommen til plattformen!', 'Welcome to the platform!', 'Sparkles', '#22C55E', 10, '{"type": "registered"}', 1),
    ('lesson_5', 'Leksjonsmester', 'Lesson Master', 'Fullført 5 leksjoner', 'Completed 5 lessons', 'BookOpen', '#3B82F6', 25, '{"type": "lessons_completed", "count": 5}', 2),
    ('quiz_master', 'Quiz-ekspert', 'Quiz Expert', 'Bestått 10 quizer', 'Passed 10 quizzes', 'Brain', '#A855F7', 50, '{"type": "quizzes_passed", "count": 10}', 3),
    ('streak_7', 'Streak-helt', 'Streak Hero', '7 dagers sammenhengende aktivitet', '7 day activity streak', 'Flame', '#F97316', 50, '{"type": "streak", "days": 7}', 4),
    ('course_complete', 'Kurs-champion', 'Course Champion', 'Fullført ditt første kurs', 'Completed your first course', 'Trophy', '#EAB308', 100, '{"type": "courses_completed", "count": 1}', 5),
    ('commenter', 'Sosial sommerfugl', 'Social Butterfly', 'Skrevet 5 kommentarer', 'Written 5 comments', 'MessageCircle', '#EC4899', 25, '{"type": "comments_written", "count": 5}', 6)
ON CONFLICT (slug) DO NOTHING;

-- ============================================
-- 2. USER BADGES (Earned)
-- ============================================

CREATE TABLE IF NOT EXISTS user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, badge_id)
);

CREATE INDEX IF NOT EXISTS idx_user_badges_user ON user_badges(user_id);
CREATE INDEX IF NOT EXISTS idx_user_badges_badge ON user_badges(badge_id);

-- ============================================
-- 3. XP EVENTS LOG
-- ============================================

CREATE TABLE IF NOT EXISTS xp_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,        -- 'lesson_complete', 'quiz_pass', 'streak_7', 'badge_earned'
    xp_amount INTEGER NOT NULL,
    description TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_xp_events_user ON xp_events(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_xp_events_type ON xp_events(event_type);

-- ============================================
-- 4. USER STREAKS
-- ============================================

CREATE TABLE IF NOT EXISTS user_streaks (
    user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date DATE,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 5. ADD XP COLUMNS TO PROFILES
-- ============================================

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS total_xp INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS level INTEGER DEFAULT 1;

-- ============================================
-- 6. RLS POLICIES
-- ============================================

-- Badges: Everyone can read
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view badges" ON badges;
CREATE POLICY "Anyone can view badges" ON badges
    FOR SELECT USING (true);

-- User badges: Users can view their own and others' badges
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view all earned badges" ON user_badges;
CREATE POLICY "Users can view all earned badges" ON user_badges
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "System can insert user badges" ON user_badges;
CREATE POLICY "System can insert user badges" ON user_badges
    FOR INSERT WITH CHECK (true);

-- XP Events: Users can view their own
ALTER TABLE xp_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own XP events" ON xp_events;
CREATE POLICY "Users can view own XP events" ON xp_events
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "System can insert XP events" ON xp_events;
CREATE POLICY "System can insert XP events" ON xp_events
    FOR INSERT WITH CHECK (true);

-- User streaks: Users can view their own
ALTER TABLE user_streaks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own streak" ON user_streaks;
CREATE POLICY "Users can view own streak" ON user_streaks
    FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "System can manage streaks" ON user_streaks;
CREATE POLICY "System can manage streaks" ON user_streaks
    FOR ALL USING (true);

-- ============================================
-- 7. XP CALCULATION FUNCTION
-- ============================================

CREATE OR REPLACE FUNCTION calculate_level(xp INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Level formula: level = floor(sqrt(xp / 100)) + 1
    -- Level 1: 0-99 XP
    -- Level 2: 100-399 XP
    -- Level 3: 400-899 XP
    -- etc.
    RETURN GREATEST(1, floor(sqrt(xp::float / 100)) + 1)::INTEGER;
END;
$$;

-- ============================================
-- 8. AWARD XP FUNCTION
-- ============================================

CREATE OR REPLACE FUNCTION award_xp(
    p_user_id UUID,
    p_event_type TEXT,
    p_xp_amount INTEGER,
    p_description TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    new_total INTEGER;
    new_level INTEGER;
BEGIN
    -- Insert XP event
    INSERT INTO xp_events (user_id, event_type, xp_amount, description, metadata)
    VALUES (p_user_id, p_event_type, p_xp_amount, p_description, p_metadata);

    -- Update total XP and level
    UPDATE profiles
    SET 
        total_xp = COALESCE(total_xp, 0) + p_xp_amount,
        level = calculate_level(COALESCE(total_xp, 0) + p_xp_amount)
    WHERE id = p_user_id
    RETURNING total_xp INTO new_total;

    RETURN new_total;
END;
$$;

-- ============================================
-- 9. UPDATE STREAK FUNCTION
-- ============================================

CREATE OR REPLACE FUNCTION update_user_streak(p_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    today DATE := CURRENT_DATE;
    streak_record user_streaks%ROWTYPE;
    new_streak INTEGER;
BEGIN
    -- Get current streak record
    SELECT * INTO streak_record FROM user_streaks WHERE user_id = p_user_id;

    IF NOT FOUND THEN
        -- First activity ever
        INSERT INTO user_streaks (user_id, current_streak, longest_streak, last_activity_date)
        VALUES (p_user_id, 1, 1, today);
        RETURN 1;
    END IF;

    -- Check if already updated today
    IF streak_record.last_activity_date = today THEN
        RETURN streak_record.current_streak;
    END IF;

    -- Check if streak continues (yesterday or today)
    IF streak_record.last_activity_date = today - 1 THEN
        new_streak := streak_record.current_streak + 1;
    ELSE
        -- Streak broken
        new_streak := 1;
    END IF;

    -- Update streak
    UPDATE user_streaks
    SET 
        current_streak = new_streak,
        longest_streak = GREATEST(longest_streak, new_streak),
        last_activity_date = today,
        updated_at = now()
    WHERE user_id = p_user_id;

    -- Award streak badges
    IF new_streak = 7 THEN
        PERFORM award_badge_if_not_earned(p_user_id, 'streak_7');
    END IF;

    RETURN new_streak;
END;
$$;

-- ============================================
-- 10. AWARD BADGE FUNCTION
-- ============================================

CREATE OR REPLACE FUNCTION award_badge_if_not_earned(
    p_user_id UUID,
    p_badge_slug TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_badge_id UUID;
    v_badge_xp INTEGER;
    v_badge_name TEXT;
    v_already_earned BOOLEAN;
BEGIN
    -- Get badge info
    SELECT id, xp_reward, name_no INTO v_badge_id, v_badge_xp, v_badge_name
    FROM badges WHERE slug = p_badge_slug;

    IF v_badge_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Check if already earned
    SELECT EXISTS(
        SELECT 1 FROM user_badges 
        WHERE user_id = p_user_id AND badge_id = v_badge_id
    ) INTO v_already_earned;

    IF v_already_earned THEN
        RETURN FALSE;
    END IF;

    -- Award badge
    INSERT INTO user_badges (user_id, badge_id)
    VALUES (p_user_id, v_badge_id);

    -- Award XP for badge
    IF v_badge_xp > 0 THEN
        PERFORM award_xp(p_user_id, 'badge_earned', v_badge_xp, 
            'Opptjent badge: ' || v_badge_name,
            jsonb_build_object('badge_slug', p_badge_slug));
    END IF;

    RETURN TRUE;
END;
$$;

-- ============================================
-- 11. TRIGGERS FOR XP ON LESSON COMPLETION
-- ============================================

CREATE OR REPLACE FUNCTION trigger_lesson_complete_xp()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    lesson_count INTEGER;
BEGIN
    -- Only award XP when marking as completed
    IF NEW.completed = TRUE AND (OLD.completed IS NULL OR OLD.completed = FALSE) THEN
        -- Award 10 XP for lesson completion
        PERFORM award_xp(NEW.user_id, 'lesson_complete', 10, 
            'Fullført leksjon',
            jsonb_build_object('lesson_id', NEW.lesson_id));

        -- Update streak
        PERFORM update_user_streak(NEW.user_id);

        -- Check for lesson badges
        SELECT COUNT(*) INTO lesson_count
        FROM lesson_progress
        WHERE user_id = NEW.user_id AND completed = TRUE;

        IF lesson_count >= 5 THEN
            PERFORM award_badge_if_not_earned(NEW.user_id, 'lesson_5');
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_lesson_xp ON lesson_progress;
CREATE TRIGGER trigger_lesson_xp
    AFTER INSERT OR UPDATE ON lesson_progress
    FOR EACH ROW
    EXECUTE FUNCTION trigger_lesson_complete_xp();

-- ============================================
-- 12. TRIGGER FOR XP ON QUIZ PASS
-- ============================================

CREATE OR REPLACE FUNCTION trigger_quiz_pass_xp()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    quiz_count INTEGER;
BEGIN
    -- Only award XP for passing scores (>= 70%)
    IF NEW.passed = TRUE AND (OLD IS NULL OR OLD.passed = FALSE) THEN
        -- Award 25 XP for quiz pass
        PERFORM award_xp(NEW.user_id, 'quiz_pass', 25,
            'Bestått quiz',
            jsonb_build_object('quiz_id', NEW.quiz_id, 'score', NEW.score));

        -- Check for quiz badges
        SELECT COUNT(*) INTO quiz_count
        FROM quiz_attempts
        WHERE user_id = NEW.user_id AND passed = TRUE;

        IF quiz_count >= 10 THEN
            PERFORM award_badge_if_not_earned(NEW.user_id, 'quiz_master');
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_quiz_xp ON quiz_attempts;
CREATE TRIGGER trigger_quiz_xp
    AFTER INSERT OR UPDATE ON quiz_attempts
    FOR EACH ROW
    EXECUTE FUNCTION trigger_quiz_pass_xp();

-- ============================================
-- 13. TRIGGER FOR NEWBIE BADGE ON REGISTRATION
-- ============================================

CREATE OR REPLACE FUNCTION trigger_newbie_badge()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Award newbie badge on profile creation
    PERFORM award_badge_if_not_earned(NEW.id, 'newbie');
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_newbie ON profiles;
CREATE TRIGGER trigger_newbie
    AFTER INSERT ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION trigger_newbie_badge();

-- ============================================
-- 14. TRIGGER FOR COMMENT BADGE
-- ============================================

CREATE OR REPLACE FUNCTION trigger_comment_badge()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    comment_count INTEGER;
BEGIN
    -- Award XP for first comment
    PERFORM award_xp(NEW.user_id, 'comment', 5,
        'Ny kommentar',
        jsonb_build_object('comment_id', NEW.id));

    -- Check for comment badge
    SELECT COUNT(*) INTO comment_count
    FROM lesson_comments
    WHERE user_id = NEW.user_id;

    IF comment_count >= 5 THEN
        PERFORM award_badge_if_not_earned(NEW.user_id, 'commenter');
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_comment_xp ON lesson_comments;
CREATE TRIGGER trigger_comment_xp
    AFTER INSERT ON lesson_comments
    FOR EACH ROW
    EXECUTE FUNCTION trigger_comment_badge();

-- ============================================
-- SUCCESS MESSAGE
-- ============================================

DO $$
BEGIN
    RAISE NOTICE 'Migration 085 completed: Gamification system installed with badges, XP, and streaks';
END $$;
