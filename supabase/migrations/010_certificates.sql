-- Migration 010: Certificate System
-- Auto-generate certificates when students complete courses

-- ============================================================================
-- TABLES
-- ============================================================================

-- Certificates table
CREATE TABLE IF NOT EXISTS public.certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    certificate_number TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, course_id) -- One certificate per user per course
);

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Generate unique certificate number (CERT-YYYY-NNNNNN)
CREATE OR REPLACE FUNCTION generate_certificate_number()
RETURNS TEXT AS $$
DECLARE
    year TEXT := TO_CHAR(NOW(), 'YYYY');
    sequence_num TEXT;
BEGIN
    SELECT LPAD((COUNT(*) + 1)::TEXT, 6, '0') INTO sequence_num
    FROM public.certificates;
    
    RETURN 'CERT-' || year || '-' || sequence_num;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger function to auto-set certificate number
CREATE OR REPLACE FUNCTION set_certificate_number_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.certificate_number IS NULL OR NEW.certificate_number = '' THEN
        NEW.certificate_number := generate_certificate_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

DROP TRIGGER IF EXISTS set_certificate_number ON public.certificates;
CREATE TRIGGER set_certificate_number
BEFORE INSERT ON public.certificates
FOR EACH ROW
EXECUTE FUNCTION set_certificate_number_trigger();

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_certificates_user ON public.certificates(user_id);
CREATE INDEX IF NOT EXISTS idx_certificates_course ON public.certificates(course_id);
CREATE INDEX IF NOT EXISTS idx_certificates_number ON public.certificates(certificate_number);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;

-- Users can view their own certificates
CREATE POLICY "Users can view own certificates" ON public.certificates
    FOR SELECT USING (auth.uid() = user_id);

-- Admins can manage all certificates
CREATE POLICY "Admins can manage certificates" ON public.certificates
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    );

-- Users can insert their own certificates (for auto-issue)
CREATE POLICY "Users can create own certificates" ON public.certificates
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Check if user has certificate for course
CREATE OR REPLACE FUNCTION has_certificate(p_user_id UUID, p_course_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.certificates
        WHERE user_id = p_user_id AND course_id = p_course_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get certificate details
CREATE OR REPLACE FUNCTION get_certificate_details(p_user_id UUID, p_course_id UUID)
RETURNS TABLE (
    certificate_number TEXT,
    issued_at TIMESTAMPTZ,
    course_title TEXT,
    student_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.certificate_number,
        c.issued_at,
        co.title,
        p.full_name
    FROM public.certificates c
    JOIN public.courses co ON c.course_id = co.id
    JOIN public.profiles p ON c.user_id = p.id
    WHERE c.user_id = p_user_id AND c.course_id = p_course_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE public.certificates IS 'Student course completion certificates';
COMMENT ON COLUMN public.certificates.certificate_number IS 'Unique certificate identifier (CERT-YYYY-NNNNNN)';
COMMENT ON FUNCTION generate_certificate_number() IS 'Generates sequential unique certificate numbers';
