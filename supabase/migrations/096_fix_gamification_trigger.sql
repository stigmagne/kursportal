-- Fix for check_and_award_badges to handle unknown badge types
-- This prevents the 'case not found' error when issuing certificates

CREATE OR REPLACE FUNCTION check_and_award_badges(p_user_id UUID)
RETURNS VOID AS $$
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
          WHERE user_id = p_user_id AND status = 'completed';
          
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

        ELSE
          -- Handle unknown badge types or do nothing to prevent CASE errors
          NULL;
      END CASE;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
