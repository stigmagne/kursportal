-- Migration 007 FIX: Correct admin access while preserving user self-management

-- Drop the problematic policies
DROP POLICY IF EXISTS "Users can read all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can manage all profiles" ON public.profiles;

-- Policy 1: Everyone can read all profiles (needed for user lists)
CREATE POLICY "Anyone can read profiles" 
ON public.profiles FOR SELECT
USING (true);

-- Policy 2: Users can update their own profile
CREATE POLICY "Users can update own profile"
ON public.profiles FOR UPDATE
USING (auth.uid() = id);

-- Policy 3: Admins can do everything
CREATE POLICY "Admins have full access"
ON public.profiles FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
);
