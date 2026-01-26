-- Migration: 050_security_improvements.sql
-- Purpose: Security improvements from external review

-- =====================================================
-- 1. Increase invitation code entropy (8 -> 12 chars)
-- =====================================================
CREATE OR REPLACE FUNCTION generate_invitation_code()
RETURNS TEXT AS $$
DECLARE
  v_code TEXT;
  v_exists BOOLEAN;
BEGIN
  LOOP
    -- Generate 12-character code (uppercase letters and numbers)
    -- Using combination of two md5 hashes for more entropy
    v_code := upper(
        substring(md5(random()::text || clock_timestamp()::text) from 1 for 6) ||
        substring(md5(random()::text || clock_timestamp()::text) from 1 for 6)
    );
    
    -- Check if code already exists
    SELECT EXISTS(SELECT 1 FROM invitations WHERE code = v_code) INTO v_exists;
    
    IF NOT v_exists THEN
      EXIT;
    END IF;
  END LOOP;
  
  RETURN v_code;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. Additional RLS hardening on profiles
-- Ensure role column cannot be updated by regular users even with RLS
-- =====================================================
CREATE OR REPLACE FUNCTION prevent_user_role_self_update()
RETURNS TRIGGER AS $$
BEGIN
    -- If role is being changed and it's not service_role
    IF NEW.role IS DISTINCT FROM OLD.role THEN
        IF current_setting('request.jwt.claims', true)::json->>'role' = 'authenticated' THEN
            RAISE EXCEPTION 'Users cannot modify their own role';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if exists and recreate
DROP TRIGGER IF EXISTS prevent_role_update ON profiles;
CREATE TRIGGER prevent_role_update
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    WHEN (OLD.role IS DISTINCT FROM NEW.role)
    EXECUTE FUNCTION prevent_user_role_self_update();

-- =====================================================
-- 3. Revoke direct table access for role updates
-- =====================================================
-- Create a restricted policy that explicitly excludes role updates for non-admins
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile except role"
    ON profiles FOR UPDATE
    USING (id = auth.uid())
    WITH CHECK (
        id = auth.uid() AND
        (role IS NOT DISTINCT FROM (SELECT role FROM profiles WHERE id = auth.uid()))
    );
