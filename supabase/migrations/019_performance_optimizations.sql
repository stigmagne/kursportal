-- Migration 019: Performance Optimizations
-- Adds indexes for better query performance

-- Add missing indexes for frequently queried columns
CREATE INDEX IF NOT EXISTS idx_lesson_completion_user ON lesson_completion(user_id, completed_at DESC);
CREATE INDEX IF NOT EXISTS idx_certificates_user ON certificates(user_id, issued_at DESC);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_activity_user ON user_activity(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_badges_user ON user_badges(user_id, earned_at DESC);
CREATE INDEX IF NOT EXISTS idx_lesson_comments_user ON lesson_comments(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_lesson_comments_lesson ON lesson_comments(lesson_id, created_at DESC);

-- Add composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_courses_published_created ON courses(published, created_at DESC) WHERE published = true;
CREATE INDEX IF NOT EXISTS idx_lessons_module_order ON lessons(module_id, order_index);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz_order ON quiz_questions(quiz_id, order_index);
CREATE INDEX IF NOT EXISTS idx_quiz_answer_options_question_order ON quiz_answer_options(question_id, order_index);

-- Materialized view for course statistics
CREATE MATERIALIZED VIEW IF NOT EXISTS course_stats AS
SELECT 
  c.id as course_id,
  c.title,
  COUNT(DISTINCT lc.user_id) as unique_learners,
  COUNT(DISTINCT cert.user_id) as total_completions,
  ROUND(
    CASE 
      WHEN COUNT(DISTINCT lc.user_id) > 0 
      THEN (COUNT(DISTINCT cert.user_id)::DECIMAL / COUNT(DISTINCT lc.user_id)) * 100 
      ELSE 0 
    END, 
    2
  ) as completion_rate,
  AVG(qa.score) as avg_quiz_score,
  COUNT(DISTINCT com.id) as total_comments
FROM courses c
LEFT JOIN course_modules m ON c.id = m.course_id
LEFT JOIN lessons l ON m.id = l.module_id
LEFT JOIN lesson_completion lc ON l.id = lc.lesson_id
LEFT JOIN certificates cert ON c.id = cert.course_id
LEFT JOIN quizzes q ON l.id = q.lesson_id
LEFT JOIN quiz_attempts qa ON q.id = qa.quiz_id
LEFT JOIN lesson_comments com ON l.id = com.lesson_id
WHERE c.published = true
GROUP BY c.id, c.title;

-- Index on materialized view
CREATE UNIQUE INDEX IF NOT EXISTS idx_course_stats_id ON course_stats(course_id);

-- Function to refresh course stats
CREATE OR REPLACE FUNCTION refresh_course_stats()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY course_stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Materialized view for user learning stats
CREATE MATERIALIZED VIEW IF NOT EXISTS user_learning_stats AS
SELECT 
  u.id as user_id,
  COUNT(DISTINCT cert.course_id) as completed_courses,
  COUNT(DISTINCT lc.lesson_id) as completed_lessons,
  COUNT(DISTINCT qa.quiz_id) as quizzes_taken,
  ROUND(AVG(qa.score), 2) as avg_quiz_score,
  COUNT(DISTINCT ub.badge_id) as badges_earned,
  COUNT(DISTINCT com.id) as comments_posted,
  COUNT(DISTINCT ua.id) as total_activities
FROM auth.users u
LEFT JOIN certificates cert ON u.id = cert.user_id
LEFT JOIN lesson_completion lc ON u.id = lc.user_id
LEFT JOIN quiz_attempts qa ON u.id = qa.user_id
LEFT JOIN user_badges ub ON u.id = ub.user_id
LEFT JOIN lesson_comments com ON u.id = com.user_id
LEFT JOIN user_activity ua ON u.id = ua.user_id
GROUP BY u.id;

-- Index on materialized view
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_learning_stats_id ON user_learning_stats(user_id);

-- Function to refresh user stats
CREATE OR REPLACE FUNCTION refresh_user_stats()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY user_learning_stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Migration 019 completed: Performance optimizations with indexes and materialized views';
END $$;
