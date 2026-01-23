-- Migration 015: Notifications and Comments System
-- Part 1: Notifications

-- Notifications table
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  type TEXT NOT NULL, -- 'course_published', 'quiz_result', 'certificate_issued', 'comment_reply'
  title TEXT NOT NULL,
  message TEXT,
  link TEXT, -- URL to navigate to when clicked
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_read ON notifications(user_id, read, created_at DESC);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can only see their own notifications
CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- Function to create notification
CREATE OR REPLACE FUNCTION create_notification(
  p_user_id UUID,
  p_type TEXT,
  p_title TEXT,
  p_message TEXT DEFAULT NULL,
  p_link TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_notification_id UUID;
BEGIN
  INSERT INTO notifications (user_id, type, title, message, link)
  VALUES (p_user_id, p_type, p_title, p_message, p_link)
  RETURNING id INTO v_notification_id;
  
  RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: Notify when certificate is issued
CREATE OR REPLACE FUNCTION notify_certificate_issued()
RETURNS TRIGGER AS $$
DECLARE
  v_course_title TEXT;
BEGIN
  SELECT title INTO v_course_title
  FROM courses
  WHERE id = NEW.course_id;
  
  PERFORM create_notification(
    NEW.user_id,
    'certificate_issued',
    'Gratulerer! 🎉',
    'Du har fullført "' || v_course_title || '" og mottatt et sertifikat!',
    '/dashboard?tab=certificates'
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_certificate_notification
  AFTER INSERT ON certificates
  FOR EACH ROW
  EXECUTE FUNCTION notify_certificate_issued();

-- Part 2: Comments System

-- Comments table
CREATE TABLE lesson_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  parent_id UUID REFERENCES lesson_comments(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_comments_lesson ON lesson_comments(lesson_id, created_at DESC);
CREATE INDEX idx_comments_parent ON lesson_comments(parent_id);
CREATE INDEX idx_comments_user ON lesson_comments(user_id);

-- Enable RLS
ALTER TABLE lesson_comments ENABLE ROW LEVEL SECURITY;

-- Anyone can read comments
CREATE POLICY "Anyone can view comments"
  ON lesson_comments FOR SELECT
  USING (true);

-- Authenticated users can create comments
CREATE POLICY "Authenticated users can create comments"
  ON lesson_comments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own comments
CREATE POLICY "Users can update own comments"
  ON lesson_comments FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can delete their own comments
CREATE POLICY "Users can delete own comments"
  ON lesson_comments FOR DELETE
  USING (auth.uid() = user_id);

-- Trigger: Notify on reply
CREATE OR REPLACE FUNCTION notify_comment_reply()
RETURNS TRIGGER AS $$
DECLARE
  v_parent_user_id UUID;
  v_commenter_name TEXT;
  v_course_id UUID;
BEGIN
  IF NEW.parent_id IS NOT NULL THEN
    SELECT user_id INTO v_parent_user_id
    FROM lesson_comments
    WHERE id = NEW.parent_id;
    
    SELECT full_name INTO v_commenter_name
    FROM profiles
    WHERE id = NEW.user_id;
    
    SELECT module.course_id INTO v_course_id
    FROM lessons 
    JOIN course_modules module ON lessons.module_id = module.id 
    WHERE lessons.id = NEW.lesson_id;
    
    IF v_parent_user_id != NEW.user_id THEN
      PERFORM create_notification(
        v_parent_user_id,
        'comment_reply',
        'Nytt svar på kommentar',
        v_commenter_name || ' svarte på kommentaren din',
        '/courses/' || v_course_id || '/learn/' || NEW.lesson_id
      );
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_comment_reply_notification
  AFTER INSERT ON lesson_comments
  FOR EACH ROW
  EXECUTE FUNCTION notify_comment_reply();

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Migration 015 completed: Notifications and Comments system created';
END $$;
