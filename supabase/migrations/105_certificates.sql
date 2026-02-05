-- Certificates table for tracking user course completions
-- Each certificate has a unique verification code for QR validation

-- Drop existing table if it exists (in case of partial migration)
DROP TABLE IF EXISTS "public"."certificates" CASCADE;

CREATE TABLE "public"."certificates" (
    "id" uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    "user_id" uuid REFERENCES "auth"."users"("id") ON DELETE CASCADE NOT NULL,
    "course_id" text NOT NULL,
    "verification_code" text UNIQUE NOT NULL,
    "issued_at" timestamptz DEFAULT now(),
    "created_at" timestamptz DEFAULT now()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS "idx_certificates_user_id" ON "public"."certificates"("user_id");
CREATE INDEX IF NOT EXISTS "idx_certificates_verification_code" ON "public"."certificates"("verification_code");
CREATE INDEX IF NOT EXISTS "idx_certificates_course_id" ON "public"."certificates"("course_id");

-- Enable RLS
ALTER TABLE "public"."certificates" ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own certificates
CREATE POLICY "Users can view own certificates"
    ON "public"."certificates"
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Policy: Users can insert their own certificates (via server action)
CREATE POLICY "Users can create own certificates"
    ON "public"."certificates"
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Policy: Admins can view all certificates
CREATE POLICY "Admins can view all certificates"
    ON "public"."certificates"
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.id = auth.uid()
            AND profiles.role = 'admin'
        )
    );

-- Policy: Public verification (anyone can verify a certificate via verification_code)
-- This is handled via a special server action that doesn't rely on RLS

-- Grants
GRANT SELECT, INSERT ON TABLE "public"."certificates" TO "authenticated";
GRANT SELECT ON TABLE "public"."certificates" TO "anon";
