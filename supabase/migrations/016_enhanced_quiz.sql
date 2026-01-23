-- Migration 016: Enhanced Quiz System
-- Adds explanations, timer, quiz attempts tracking, and review mode

-- Add explanation field to quiz questions
ALTER TABLE quiz_questions
ADD COLUMN IF NOT EXISTS explanation TEXT;

-- Add time_limit to quizzes (in minutes)
ALTER TABLE quizzes
ADD COLUMN IF NOT EXISTS time_limit INTEGER;

-- Add randomize_questions option
ALTER TABLE quizzes
ADD COLUMN IF NOT EXISTS randomize_questions BOOLEAN DEFAULT FALSE;

-- Add show_explanations option (show after completion)
ALTER TABLE quizzes
ADD COLUMN IF NOT EXISTS show_explanations BOOLEAN DEFAULT TRUE;

-- Update existing quiz_attempts table to add answers column if not exists
-- (The table already exists from migration 009)
ALTER TABLE quiz_attempts
ADD COLUMN IF NOT EXISTS answers JSONB;

-- Add time_taken column if not exists
ALTER TABLE quiz_attempts
ADD COLUMN IF NOT EXISTS time_taken INTEGER;

CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user_quiz ON quiz_attempts(user_id, quiz_id, completed_at DESC);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_quiz ON quiz_attempts(quiz_id, completed_at DESC);

-- Enable RLS
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

-- Users can view own attempts
CREATE POLICY "Users can view own quiz attempts"
  ON quiz_attempts FOR SELECT
  USING (auth.uid() = user_id);

-- Users can create own attempts
CREATE POLICY "Users can create own quiz attempts"
  ON quiz_attempts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Admins can view all attempts
CREATE POLICY "Admins can view all quiz attempts"
  ON quiz_attempts FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Function to get user's best quiz score
CREATE OR REPLACE FUNCTION get_best_quiz_score(
  p_user_id UUID,
  p_quiz_id UUID
)
RETURNS DECIMAL AS $$
DECLARE
  v_best_score DECIMAL;
BEGIN
  SELECT MAX(score) INTO v_best_score
  FROM quiz_attempts
  WHERE user_id = p_user_id
  AND quiz_id = p_quiz_id;
  
  RETURN COALESCE(v_best_score, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get quiz attempt count
CREATE OR REPLACE FUNCTION get_quiz_attempt_count(
  p_user_id UUID,
  p_quiz_id UUID
)
RETURNS INTEGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM quiz_attempts
  WHERE user_id = p_user_id
  AND quiz_id = p_quiz_id;
  
  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Migration 016 completed: Enhanced Quiz System';
END $$;
