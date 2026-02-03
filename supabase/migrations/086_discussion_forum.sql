-- Migration 086: Course Discussion Forum
-- Adds course-level discussions and replies

-- ============================================
-- 1. COURSE DISCUSSIONS
-- ============================================

CREATE TABLE IF NOT EXISTS course_discussions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    is_pinned BOOLEAN DEFAULT false,
    is_locked BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_discussions_course ON course_discussions(course_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_discussions_user ON course_discussions(user_id);
CREATE INDEX IF NOT EXISTS idx_discussions_pinned ON course_discussions(course_id, is_pinned DESC, created_at DESC);

-- ============================================
-- 2. DISCUSSION REPLIES
-- ============================================

CREATE TABLE IF NOT EXISTS discussion_replies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    discussion_id UUID NOT NULL REFERENCES course_discussions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    parent_reply_id UUID REFERENCES discussion_replies(id) ON DELETE CASCADE,
    is_solution BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_replies_discussion ON discussion_replies(discussion_id, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_replies_parent ON discussion_replies(parent_reply_id);
CREATE INDEX IF NOT EXISTS idx_replies_user ON discussion_replies(user_id);

-- ============================================
-- 3. DISCUSSION LIKES (optional engagement)
-- ============================================

CREATE TABLE IF NOT EXISTS discussion_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    discussion_id UUID REFERENCES course_discussions(id) ON DELETE CASCADE,
    reply_id UUID REFERENCES discussion_replies(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    -- Either discussion_id or reply_id must be set
    CONSTRAINT likes_target_check CHECK (
        (discussion_id IS NOT NULL AND reply_id IS NULL) OR
        (discussion_id IS NULL AND reply_id IS NOT NULL)
    ),
    UNIQUE(user_id, discussion_id),
    UNIQUE(user_id, reply_id)
);

-- ============================================
-- 4. RLS POLICIES FOR DISCUSSIONS
-- ============================================

ALTER TABLE course_discussions ENABLE ROW LEVEL SECURITY;

-- Anyone can view discussions in courses they have access to
DROP POLICY IF EXISTS "Users can view discussions" ON course_discussions;
CREATE POLICY "Users can view discussions" ON course_discussions
    FOR SELECT USING (
        EXISTS (
            -- Rely on courses RLS to determine visibility
            SELECT 1 FROM courses c
            WHERE c.id = course_id
        )
    );

-- Authenticated users can create discussions
DROP POLICY IF EXISTS "Users can create discussions" ON course_discussions;
CREATE POLICY "Users can create discussions" ON course_discussions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own discussions
DROP POLICY IF EXISTS "Users can update own discussions" ON course_discussions;
CREATE POLICY "Users can update own discussions" ON course_discussions
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own discussions, admins can delete any
DROP POLICY IF EXISTS "Users can delete own discussions" ON course_discussions;
CREATE POLICY "Users can delete own discussions" ON course_discussions
    FOR DELETE USING (
        auth.uid() = user_id 
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================
-- 5. RLS POLICIES FOR REPLIES
-- ============================================

ALTER TABLE discussion_replies ENABLE ROW LEVEL SECURITY;

-- Anyone can view replies in visible discussions
DROP POLICY IF EXISTS "Users can view replies" ON discussion_replies;
CREATE POLICY "Users can view replies" ON discussion_replies
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM course_discussions cd
            WHERE cd.id = discussion_id
        )
    );

-- Authenticated users can create replies (unless locked)
DROP POLICY IF EXISTS "Users can create replies" ON discussion_replies;
CREATE POLICY "Users can create replies" ON discussion_replies
    FOR INSERT WITH CHECK (
        auth.uid() = user_id
        AND EXISTS (
            SELECT 1 FROM course_discussions cd
            WHERE cd.id = discussion_id
            AND cd.is_locked = false
        )
    );

-- Users can update their own replies
DROP POLICY IF EXISTS "Users can update own replies" ON discussion_replies;
CREATE POLICY "Users can update own replies" ON discussion_replies
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own replies
DROP POLICY IF EXISTS "Users can delete own replies" ON discussion_replies;
CREATE POLICY "Users can delete own replies" ON discussion_replies
    FOR DELETE USING (
        auth.uid() = user_id 
        OR EXISTS (SELECT 1 FROM profiles WHERE id = (select auth.uid()) AND role = 'admin')
    );

-- ============================================
-- 6. RLS POLICIES FOR LIKES
-- ============================================

ALTER TABLE discussion_likes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view likes" ON discussion_likes;
CREATE POLICY "Anyone can view likes" ON discussion_likes
    FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can manage own likes" ON discussion_likes;
CREATE POLICY "Users can manage own likes" ON discussion_likes
    FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- 7. REPLY COUNT VIEW
-- ============================================

CREATE OR REPLACE VIEW discussion_with_counts AS
SELECT 
    cd.*,
    (SELECT COUNT(*) FROM discussion_replies dr WHERE dr.discussion_id = cd.id) as reply_count,
    (SELECT COUNT(*) FROM discussion_likes dl WHERE dl.discussion_id = cd.id) as like_count,
    p.full_name as author_name,
    p.avatar_url as author_avatar
FROM course_discussions cd
JOIN profiles p ON cd.user_id = p.id;

-- ============================================
-- 8. TRIGGER FOR UPDATED_AT
-- ============================================

CREATE OR REPLACE FUNCTION update_discussion_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_discussion_updated ON course_discussions;
CREATE TRIGGER trigger_discussion_updated
    BEFORE UPDATE ON course_discussions
    FOR EACH ROW
    EXECUTE FUNCTION update_discussion_updated_at();

DROP TRIGGER IF EXISTS trigger_reply_updated ON discussion_replies;
CREATE TRIGGER trigger_reply_updated
    BEFORE UPDATE ON discussion_replies
    FOR EACH ROW
    EXECUTE FUNCTION update_discussion_updated_at();

-- ============================================
-- 9. XP FOR DISCUSSION ACTIVITY
-- ============================================

CREATE OR REPLACE FUNCTION trigger_discussion_xp()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Award 10 XP for creating a discussion
    PERFORM award_xp(NEW.user_id, 'discussion_created', 10,
        'Opprettet diskusjon',
        jsonb_build_object('discussion_id', NEW.id));
    
    -- Update streak
    PERFORM update_user_streak(NEW.user_id);
    
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_discussion_activity ON course_discussions;
CREATE TRIGGER trigger_discussion_activity
    AFTER INSERT ON course_discussions
    FOR EACH ROW
    EXECUTE FUNCTION trigger_discussion_xp();

CREATE OR REPLACE FUNCTION trigger_reply_xp()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Award 5 XP for replying
    PERFORM award_xp(NEW.user_id, 'reply_created', 5,
        'Svarte på diskusjon',
        jsonb_build_object('reply_id', NEW.id));
    
    -- Update streak
    PERFORM update_user_streak(NEW.user_id);
    
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_reply_activity ON discussion_replies;
CREATE TRIGGER trigger_reply_activity
    AFTER INSERT ON discussion_replies
    FOR EACH ROW
    EXECUTE FUNCTION trigger_reply_xp();

-- ============================================
-- SUCCESS MESSAGE
-- ============================================

DO $$
BEGIN
    RAISE NOTICE 'Migration 086 completed: Discussion forum with replies, likes, and XP integration';
END $$;
