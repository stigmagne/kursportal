-- Notification webhooks for Slack, Discord, and Microsoft Teams
-- Migration: 055_notification_webhooks.sql

-- Notification settings table (singleton - one row)
CREATE TABLE IF NOT EXISTS notification_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Webhook URLs
  slack_webhook_url TEXT,
  discord_webhook_url TEXT,
  teams_webhook_url TEXT,
  -- Event toggles
  notify_on_signup BOOLEAN DEFAULT true,
  notify_on_course_complete BOOLEAN DEFAULT true,
  notify_on_quiz_pass BOOLEAN DEFAULT true,
  notify_on_comment BOOLEAN DEFAULT false,
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;

-- Only admins can view/edit notification settings
CREATE POLICY "Admins can view notification settings"
  ON notification_settings FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update notification settings"
  ON notification_settings FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can insert notification settings"
  ON notification_settings FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.role = 'admin'
    )
  );

-- Insert default row
INSERT INTO notification_settings (id) 
VALUES (gen_random_uuid())
ON CONFLICT DO NOTHING;

-- Notification log table for tracking sent notifications
CREATE TABLE IF NOT EXISTS notification_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT NOT NULL,
  channel TEXT NOT NULL, -- 'slack', 'discord', 'teams'
  payload JSONB,
  success BOOLEAN DEFAULT true,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for querying logs
CREATE INDEX IF NOT EXISTS idx_notification_log_created 
  ON notification_log(created_at DESC);

-- RLS for notification log
ALTER TABLE notification_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view notification logs"
  ON notification_log FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = auth.uid() 
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Service can insert notification logs"
  ON notification_log FOR INSERT
  TO authenticated
  WITH CHECK (true);
