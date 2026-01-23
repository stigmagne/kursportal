-- Migration 020: Email Notifications
-- Adds email preferences, queue, and templates

-- Email preferences per user
CREATE TABLE IF NOT EXISTS email_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  welcome_email BOOLEAN DEFAULT true,
  course_reminders BOOLEAN DEFAULT true,
  new_courses BOOLEAN DEFAULT true,
  certificates BOOLEAN DEFAULT true,
  comment_replies BOOLEAN DEFAULT true,
  weekly_summary BOOLEAN DEFAULT true,
  marketing BOOLEAN DEFAULT false,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Email queue for sending
CREATE TABLE IF NOT EXISTS email_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email_type TEXT NOT NULL, -- 'welcome', 'reminder', 'certificate', 'comment_reply', 'weekly_summary'
  recipient_email TEXT NOT NULL,
  subject TEXT NOT NULL,
  template_data JSONB, -- Data for email template
  status TEXT DEFAULT 'pending', -- 'pending', 'sent', 'failed'
  error_message TEXT,
  sent_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_email_queue_status ON email_queue(status, created_at);
CREATE INDEX IF NOT EXISTS idx_email_queue_user ON email_queue(user_id, created_at DESC);

-- Email templates
CREATE TABLE IF NOT EXISTS email_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  subject TEXT NOT NULL,
  html_body TEXT NOT NULL,
  text_body TEXT NOT NULL,
  variables JSONB, -- List of available variables
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE email_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE email_templates ENABLE ROW LEVEL SECURITY;

-- Users can view and update own preferences
CREATE POLICY "Users can view own email preferences"
  ON email_preferences FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own email preferences"
  ON email_preferences FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can view own email queue
CREATE POLICY "Users can view own email queue"
  ON email_queue FOR SELECT
  USING (auth.uid() = user_id);

-- Admins can view all
CREATE POLICY "Admins can view all email queue"
  ON email_queue FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Everyone can view templates (for preview)
CREATE POLICY "Anyone can view email templates"
  ON email_templates FOR SELECT
  USING (true);

-- Admins can manage templates
CREATE POLICY "Admins can manage email templates"
  ON email_templates FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Function to create default email preferences for new users
CREATE OR REPLACE FUNCTION create_default_email_preferences()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO email_preferences (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create preferences on user signup
DROP TRIGGER IF EXISTS trigger_create_email_preferences ON auth.users;
CREATE TRIGGER trigger_create_email_preferences
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_default_email_preferences();

-- Function to queue welcome email
CREATE OR REPLACE FUNCTION queue_welcome_email()
RETURNS TRIGGER AS $$
DECLARE
  v_email TEXT;
BEGIN
  -- Get user email
  SELECT email INTO v_email
  FROM auth.users
  WHERE id = NEW.id;
  
  -- Queue welcome email
  INSERT INTO email_queue (user_id, email_type, recipient_email, subject, template_data)
  VALUES (
    NEW.id,
    'welcome',
    v_email,
    'Velkommen til En Helt Syk Oppvekst!',
    jsonb_build_object(
      'user_name', NEW.raw_user_meta_data->>'full_name',
      'email', v_email
    )
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to queue welcome email on signup
DROP TRIGGER IF EXISTS trigger_queue_welcome_email ON auth.users;
CREATE TRIGGER trigger_queue_welcome_email
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION queue_welcome_email();

-- Function to queue certificate email
CREATE OR REPLACE FUNCTION queue_certificate_email()
RETURNS TRIGGER AS $$
DECLARE
  v_user_email TEXT;
  v_user_name TEXT;
  v_course_title TEXT;
  v_prefs RECORD;
BEGIN
  -- Get user info
  SELECT u.email, p.full_name INTO v_user_email, v_user_name
  FROM auth.users u
  LEFT JOIN profiles p ON u.id = p.id
  WHERE u.id = NEW.user_id;
  
  -- Get course title
  SELECT title INTO v_course_title
  FROM courses
  WHERE id = NEW.course_id;
  
  -- Check preferences
  SELECT * INTO v_prefs
  FROM email_preferences
  WHERE user_id = NEW.user_id;
  
  -- Queue email if enabled
  IF v_prefs.certificates THEN
    INSERT INTO email_queue (user_id, email_type, recipient_email, subject, template_data)
    VALUES (
      NEW.user_id,
      'certificate',
      v_user_email,
      'Gratulerer! Du har fullført ' || v_course_title,
      jsonb_build_object(
        'user_name', v_user_name,
        'course_title', v_course_title,
        'certificate_url', '/certificates/' || NEW.id::TEXT
      )
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to queue certificate email
DROP TRIGGER IF EXISTS trigger_queue_certificate_email ON certificates;
CREATE TRIGGER trigger_queue_certificate_email
  AFTER INSERT ON certificates
  FOR EACH ROW
  EXECUTE FUNCTION queue_certificate_email();

-- Function to queue comment reply email
CREATE OR REPLACE FUNCTION queue_comment_reply_email()
RETURNS TRIGGER AS $$
DECLARE
  v_parent_user_id UUID;
  v_parent_user_email TEXT;
  v_parent_user_name TEXT;
  v_commenter_name TEXT;
  v_lesson_title TEXT;
  v_prefs RECORD;
BEGIN
  -- Only for replies
  IF NEW.parent_id IS NULL THEN
    RETURN NEW;
  END IF;
  
  -- Get parent comment user
  SELECT user_id INTO v_parent_user_id
  FROM lesson_comments
  WHERE id = NEW.parent_id;
  
  -- Don't email yourself
  IF v_parent_user_id = NEW.user_id THEN
    RETURN NEW;
  END IF;
  
  -- Get user info
  SELECT u.email, p.full_name INTO v_parent_user_email, v_parent_user_name
  FROM auth.users u
  LEFT JOIN profiles p ON u.id = p.id
  WHERE u.id = v_parent_user_id;
  
  SELECT p.full_name INTO v_commenter_name
  FROM profiles p
  WHERE p.id = NEW.user_id;
  
  -- Get lesson title
  SELECT title INTO v_lesson_title
  FROM lessons
  WHERE id = NEW.lesson_id;
  
  -- Check preferences
  SELECT * INTO v_prefs
  FROM email_preferences
  WHERE user_id = v_parent_user_id;
  
  -- Queue email if enabled
  IF v_prefs.comment_replies THEN
    INSERT INTO email_queue (user_id, email_type, recipient_email, subject, template_data)
    VALUES (
      v_parent_user_id,
      'comment_reply',
      v_parent_user_email,
      v_commenter_name || ' svarte på kommentaren din',
      jsonb_build_object(
        'user_name', v_parent_user_name,
        'commenter_name', v_commenter_name,
        'lesson_title', v_lesson_title,
        'comment_text', NEW.content,
        'comment_url', '/courses/' || (SELECT course_id FROM course_modules WHERE id = (SELECT module_id FROM lessons WHERE id = NEW.lesson_id)) || '/learn/' || NEW.lesson_id::TEXT
      )
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to queue comment reply email
DROP TRIGGER IF EXISTS trigger_queue_comment_reply_email ON lesson_comments;
CREATE TRIGGER trigger_queue_comment_reply_email
  AFTER INSERT ON lesson_comments
  FOR EACH ROW
  EXECUTE FUNCTION queue_comment_reply_email();

-- Seed email templates
INSERT INTO email_templates (name, subject, html_body, text_body, variables) VALUES
(
  'welcome',
  'Velkommen til En Helt Syk Oppvekst!',
  '<h1>Velkommen, {{user_name}}!</h1><p>Vi er glade for å ha deg med oss. Start din læringsreise i dag!</p><a href="{{app_url}}/courses">Utforsk kurs</a>',
  'Velkommen, {{user_name}}! Vi er glade for å ha deg med oss. Start din læringsreise i dag! Besøk {{app_url}}/courses',
  '["user_name", "email", "app_url"]'::jsonb
),
(
  'certificate',
  'Gratulerer! Du har fullført {{course_title}}',
  '<h1>Gratulerer, {{user_name}}!</h1><p>Du har fullført kurset "{{course_title}}".</p><a href="{{app_url}}{{certificate_url}}">Se sertifikat</a>',
  'Gratulerer, {{user_name}}! Du har fullført kurset "{{course_title}}". Se sertifikat: {{app_url}}{{certificate_url}}',
  '["user_name", "course_title", "certificate_url", "app_url"]'::jsonb
),
(
  'comment_reply',
  '{{commenter_name}} svarte på kommentaren din',
  '<h1>Hei {{user_name}}!</h1><p>{{commenter_name}} svarte på kommentaren din i "{{lesson_title}}":</p><blockquote>{{comment_text}}</blockquote><a href="{{app_url}}{{comment_url}}">Se svar</a>',
  'Hei {{user_name}}! {{commenter_name}} svarte på kommentaren din i "{{lesson_title}}": {{comment_text}}. Se svar: {{app_url}}{{comment_url}}',
  '["user_name", "commenter_name", "lesson_title", "comment_text", "comment_url", "app_url"]'::jsonb
)
ON CONFLICT (name) DO NOTHING;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Migration 020 completed: Email notifications system';
END $$;
