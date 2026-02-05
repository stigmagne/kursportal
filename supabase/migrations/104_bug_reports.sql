-- Create bug_reports table for user-submitted bug/issue reports
CREATE TABLE IF NOT EXISTS "public"."bug_reports" (
    "id" uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    "user_id" uuid REFERENCES "auth"."users"("id") ON DELETE SET NULL,
    "email" text,
    "full_name" text,
    "title" text NOT NULL,
    "description" text NOT NULL,
    "page_url" text,
    "browser_info" text,
    "status" text DEFAULT 'open' CHECK (status IN ('open', 'in-progress', 'resolved', 'closed')),
    "priority" text DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    "admin_notes" text,
    "created_at" timestamptz DEFAULT now(),
    "updated_at" timestamptz DEFAULT now()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS "idx_bug_reports_user_id" ON "public"."bug_reports"("user_id");
CREATE INDEX IF NOT EXISTS "idx_bug_reports_status" ON "public"."bug_reports"("status");
CREATE INDEX IF NOT EXISTS "idx_bug_reports_created_at" ON "public"."bug_reports"("created_at" DESC);

-- Enable RLS
ALTER TABLE "public"."bug_reports" ENABLE ROW LEVEL SECURITY;

-- Users can insert their own reports
CREATE POLICY "Users can create bug reports"
    ON "public"."bug_reports"
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Users can view their own reports
CREATE POLICY "Users can view own bug reports"
    ON "public"."bug_reports"
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Admins can view all reports
CREATE POLICY "Admins can view all bug reports"
    ON "public"."bug_reports"
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.role = 'admin'
        )
    );

-- Admins can update reports (status, priority, notes)
CREATE POLICY "Admins can update bug reports"
    ON "public"."bug_reports"
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.role = 'admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.role = 'admin'
        )
    );

-- Grant permissions
GRANT SELECT, INSERT ON TABLE "public"."bug_reports" TO "authenticated";
GRANT UPDATE ON TABLE "public"."bug_reports" TO "authenticated";
