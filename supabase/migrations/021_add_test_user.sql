-- Migration 021: Add test user Stig Brekken
-- NOTE: This requires Supabase admin access to run
-- Alternative: Use the signup form at /signup

-- This is a manual SQL that needs to be run in Supabase Dashboard
-- or via Supabase CLI with admin privileges

-- Insert into auth.users (requires admin access)
-- You'll need to run this in Supabase Dashboard > SQL Editor

/*
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'stig@smeb.no',
  crypt('12345678', gen_salt('bf')),
  NOW(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name":"Stig Brekken"}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
);
*/

-- ALTERNATIVE: Use Supabase Dashboard
-- 1. Go to Authentication > Users
-- 2. Click "Add user"
-- 3. Enter:
--    Email: stig@smeb.no
--    Password: 12345678
--    Auto Confirm User: Yes
-- 4. Click "Create user"

-- After user is created, update profile
-- UPDATE profiles 
-- SET full_name = 'Stig Brekken'
-- WHERE id = (SELECT id FROM auth.users WHERE email = 'stig@smeb.no');

DO $$
BEGIN
  RAISE NOTICE 'To create user Stig Brekken:';
  RAISE NOTICE '1. Go to Supabase Dashboard > Authentication > Users';
  RAISE NOTICE '2. Click "Add user"';
  RAISE NOTICE '3. Email: stig@smeb.no, Password: 12345678';
  RAISE NOTICE '4. Check "Auto Confirm User"';
  RAISE NOTICE '5. Click "Create user"';
END $$;
