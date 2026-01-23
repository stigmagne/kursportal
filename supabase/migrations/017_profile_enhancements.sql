-- Migration 017: Profile Enhancements
-- Adds user activity log and badges system

-- User activity log
CREATE TABLE IF NOT EXISTS user_activity (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  activity_type TEXT NOT NULL, -- 'lesson_completed', 'quiz_passed', 'certificate_earned', 'comment_posted', 'course_enrolled'
  description TEXT NOT NULL,
  metadata JSONB, -- Additional data (course_id, lesson_id, score, etc.)
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_activity_user_created ON user_activity(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_activity_type ON user_activity(activity_type);

-- Enable RLS
ALTER TABLE user_activity ENABLE ROW LEVEL SECURITY;

-- Users can view own activity
CREATE POLICY "Users can view own activity"
  ON user_activity FOR SELECT
  USING (auth.uid() = user_id);

-- System can create activity (via triggers)
CREATE POLICY "System can create activity"
  ON user_activity FOR INSERT
  WITH CHECK (true);

-- Badges
CREATE TABLE IF NOT EXISTS badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT NOT NULL,
  icon TEXT NOT NULL, -- Emoji or icon name
  criteria JSONB NOT NULL, -- Conditions to earn badge
  tier TEXT DEFAULT 'bronze', -- bronze, silver, gold, platinum
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User badges (earned badges)
CREATE TABLE IF NOT EXISTS user_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  badge_id UUID REFERENCES badges(id) ON DELETE CASCADE NOT NULL,
  earned_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, badge_id)
);

CREATE INDEX IF NOT EXISTS idx_user_badges_user ON user_badges(user_id, earned_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_badges_badge ON user_badges(badge_id);

-- Enable RLS
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

-- Everyone can view badges
CREATE POLICY "Anyone can view badges"
  ON badges FOR SELECT
  USING (true);

-- Users can view own earned badges
CREATE POLICY "Users can view own badges"
  ON user_badges FOR SELECT
  USING (auth.uid() = user_id);

-- System can award badges
CREATE POLICY "System can award badges"
  ON user_badges FOR INSERT
  WITH CHECK (true);

-- Seed initial badges
INSERT INTO badges (name, description, icon, criteria, tier) VALUES
('Første Steg', 'Fullført ditt første kurs', '🎯', '{"type": "courses_completed", "count": 1}', 'bronze'),
('Kurs-samler', 'Fullført 5 kurs', '📚', '{"type": "courses_completed", "count": 5}', 'silver'),
('Kurs-mester', 'Fullført 10 kurs', '🏆', '{"type": "courses_completed", "count": 10}', 'gold'),
('Quiz-nybegynner', 'Bestått ditt første quiz', '✅', '{"type": "quizzes_passed", "count": 1}', 'bronze'),
('Quiz-ekspert', 'Få 100% på 5 quizer', '💯', '{"type": "perfect_quizzes", "count": 5}', 'gold'),
('Dedikert Lærer', 'Logg inn 7 dager på rad', '🔥', '{"type": "login_streak", "days": 7}', 'silver'),
('Sertifikat-samler', 'Tjen 3 sertifikater', '📜', '{"type": "certificates_earned", "count": 3}', 'silver'),
('Sosial Butterfly', 'Post 10 kommentarer', '💬', '{"type": "comments_posted", "count": 10}', 'bronze'),
('Hjelpsom', 'Post 25 kommentarer', '🤝', '{"type": "comments_posted", "count": 25}', 'silver'),
('Rask Lærer', 'Fullfør et kurs på under 1 uke', '⚡', '{"type": "course_speed", "days": 7}', 'gold')
ON CONFLICT (name) DO NOTHING;

-- Function to check and award badges
CREATE OR REPLACE FUNCTION check_and_award_badges(p_user_id UUID)
RETURNS void AS $$
DECLARE
  v_badge RECORD;
  v_count INTEGER;
  v_has_badge BOOLEAN;
BEGIN
  -- Loop through all badges
  FOR v_badge IN SELECT * FROM badges LOOP
    -- Check if user already has this badge
    SELECT EXISTS(
      SELECT 1 FROM user_badges
      WHERE user_id = p_user_id AND badge_id = v_badge.id
    ) INTO v_has_badge;
    
    IF NOT v_has_badge THEN
      -- Check criteria based on type
      CASE v_badge.criteria->>'type'
        WHEN 'courses_completed' THEN
          SELECT COUNT(DISTINCT course_id) INTO v_count
          FROM user_progress
          WHERE user_id = p_user_id AND completed = true;
          
          IF v_count >= (v_badge.criteria->>'count')::INTEGER THEN
            INSERT INTO user_badges (user_id, badge_id) VALUES (p_user_id, v_badge.id);
          END IF;
          
        WHEN 'quizzes_passed' THEN
          SELECT COUNT(*) INTO v_count
          FROM quiz_attempts
          WHERE user_id = p_user_id AND passed = true;
          
          IF v_count >= (v_badge.criteria->>'count')::INTEGER THEN
            INSERT INTO user_badges (user_id, badge_id) VALUES (p_user_id, v_badge.id);
          END IF;
          
        WHEN 'perfect_quizzes' THEN
          SELECT COUNT(*) INTO v_count
          FROM quiz_attempts
          WHERE user_id = p_user_id AND score = 100;
          
          IF v_count >= (v_badge.criteria->>'count')::INTEGER THEN
            INSERT INTO user_badges (user_id, badge_id) VALUES (p_user_id, v_badge.id);
          END IF;
          
        WHEN 'certificates_earned' THEN
          SELECT COUNT(*) INTO v_count
          FROM certificates
          WHERE user_id = p_user_id;
          
          IF v_count >= (v_badge.criteria->>'count')::INTEGER THEN
            INSERT INTO user_badges (user_id, badge_id) VALUES (p_user_id, v_badge.id);
          END IF;
          
        WHEN 'comments_posted' THEN
          SELECT COUNT(*) INTO v_count
          FROM lesson_comments
          WHERE user_id = p_user_id;
          
          IF v_count >= (v_badge.criteria->>'count')::INTEGER THEN
            INSERT INTO user_badges (user_id, badge_id) VALUES (p_user_id, v_badge.id);
          END IF;
      END CASE;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to log lesson completion
CREATE OR REPLACE FUNCTION log_lesson_completion()
RETURNS TRIGGER AS $$
DECLARE
  v_lesson_title TEXT;
  v_course_title TEXT;
BEGIN
  SELECT l.title, c.title INTO v_lesson_title, v_course_title
  FROM lessons l
  JOIN course_modules m ON l.module_id = m.id
  JOIN courses c ON m.course_id = c.id
  WHERE l.id = NEW.lesson_id;
  
  INSERT INTO user_activity (user_id, activity_type, description, metadata)
  VALUES (
    NEW.user_id,
    'lesson_completed',
    'Fullførte "' || v_lesson_title || '" i ' || v_course_title,
    jsonb_build_object('lesson_id', NEW.lesson_id, 'course_id', (
      SELECT course_id FROM course_modules WHERE id = (SELECT module_id FROM lessons WHERE id = NEW.lesson_id)
    ))
  );
  
  -- Check for badges
  PERFORM check_and_award_badges(NEW.user_id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_lesson_completion
  AFTER INSERT ON lesson_completion
  FOR EACH ROW
  EXECUTE FUNCTION log_lesson_completion();

-- Trigger to log quiz completion
CREATE OR REPLACE FUNCTION log_quiz_completion()
RETURNS TRIGGER AS $$
DECLARE
  v_quiz_title TEXT;
BEGIN
  SELECT title INTO v_quiz_title
  FROM quizzes
  WHERE id = NEW.quiz_id;
  
  INSERT INTO user_activity (user_id, activity_type, description, metadata)
  VALUES (
    NEW.user_id,
    CASE WHEN NEW.passed THEN 'quiz_passed' ELSE 'quiz_failed' END,
    CASE 
      WHEN NEW.passed THEN 'Bestod "' || v_quiz_title || '" med ' || NEW.score::TEXT || '%'
      ELSE 'Forsøkte "' || v_quiz_title || '" (' || NEW.score::TEXT || '%)'
    END,
    jsonb_build_object('quiz_id', NEW.quiz_id, 'score', NEW.score, 'passed', NEW.passed)
  );
  
  -- Check for badges
  PERFORM check_and_award_badges(NEW.user_id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_quiz_completion
  AFTER INSERT ON quiz_attempts
  FOR EACH ROW
  EXECUTE FUNCTION log_quiz_completion();

-- Trigger to log certificate earned
CREATE OR REPLACE FUNCTION log_certificate_earned()
RETURNS TRIGGER AS $$
DECLARE
  v_course_title TEXT;
BEGIN
  SELECT title INTO v_course_title
  FROM courses
  WHERE id = NEW.course_id;
  
  INSERT INTO user_activity (user_id, activity_type, description, metadata)
  VALUES (
    NEW.user_id,
    'certificate_earned',
    'Mottok sertifikat for "' || v_course_title || '"',
    jsonb_build_object('course_id', NEW.course_id, 'certificate_id', NEW.id)
  );
  
  -- Check for badges
  PERFORM check_and_award_badges(NEW.user_id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_certificate_earned
  AFTER INSERT ON certificates
  FOR EACH ROW
  EXECUTE FUNCTION log_certificate_earned();

-- Trigger to log comment posted
CREATE OR REPLACE FUNCTION log_comment_posted()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_activity (user_id, activity_type, description, metadata)
  VALUES (
    NEW.user_id,
    'comment_posted',
    'Postet en kommentar',
    jsonb_build_object('comment_id', NEW.id, 'lesson_id', NEW.lesson_id)
  );
  
  -- Check for badges
  PERFORM check_and_award_badges(NEW.user_id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_comment_posted
  AFTER INSERT ON lesson_comments
  FOR EACH ROW
  EXECUTE FUNCTION log_comment_posted();

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Migration 017 completed: Profile enhancements with badges and activity log';
END $$;
