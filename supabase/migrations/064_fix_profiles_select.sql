-- Migration: Fix profiles SELECT access
-- Problem: Migration 061 dropped "Anyone can read profiles" assuming 
-- "Public profiles are viewable by everyone" existed, but it may not.
-- This breaks admin role checks since profiles can't be queried.

-- Re-create a SELECT policy for profiles so role checks work
DROP POLICY IF EXISTS "Users can view profiles" ON profiles;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
CREATE POLICY "Users can view profiles" ON profiles
    FOR SELECT USING (true);

-- End of migration
