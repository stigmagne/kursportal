-- Migration 022: Fix user creation issues
-- Temporarily disable problematic triggers and create user manually

-- Step 1: Disable triggers that might cause issues
ALTER TABLE auth.users DISABLE TRIGGER ALL;

-- Step 2: Create user directly (run this in Supabase Dashboard SQL Editor)
-- You'll need to replace the UUID with a generated one

-- Generate a UUID first
DO $$
DECLARE
  v_user_id UUID := gen_random_uuid();
  v_encrypted_password TEXT;
BEGIN
  -- Create the user
  INSERT INTO auth.users (
    id,
    instance_id,
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
    recovery_token
  ) VALUES (
    v_user_id,
    '00000000-0000-0000-0000-000000000000',
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
    ''
  );

  -- Create profile manually
  INSERT INTO profiles (id, full_name, role, created_at, updated_at)
  VALUES (v_user_id, 'Stig Brekken', 'student', NOW(), NOW())
  ON CONFLICT (id) DO NOTHING;

  -- Create email preferences manually
  INSERT INTO email_preferences (user_id)
  VALUES (v_user_id)
  ON CONFLICT (user_id) DO NOTHING;

  RAISE NOTICE 'User created successfully with ID: %', v_user_id;
END $$;

-- Step 3: Re-enable triggers
ALTER TABLE auth.users ENABLE TRIGGER ALL;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'User Stig Brekken created successfully';
  RAISE NOTICE 'Email: stig@smeb.no';
  RAISE NOTICE 'Password: 12345678';
END $$;
