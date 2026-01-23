-- Seed Test Users for Category Testing
-- Run this in Supabase SQL Editor

-- Step 1: Temporarily relax the constraint
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS user_category_required;

-- Step 2: Create auth users (trigger will auto-create profiles)
DO $$
DECLARE
    user1_id UUID;
    user2_id UUID;
    user3_id UUID;
BEGIN
    -- User 1: Sibling
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        created_at,
        updated_at,
        confirmation_token,
        raw_app_meta_data,
        raw_user_meta_data
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(),
        'authenticated',
        'authenticated',
        'emma.sosken@test.no',
        crypt('Test123!', gen_salt('bf')),
        NOW(),
        NOW(),
        NOW(),
        '',
        '{"provider":"email","providers":["email"]}',
        '{"full_name":"Emma Søsken"}'
    )
    RETURNING id INTO user1_id;

    -- Update profile with category
    UPDATE public.profiles 
    SET user_category = 'søsken', full_name = 'Emma Søsken'
    WHERE id = user1_id;

    -- User 2: Parent
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        created_at,
        updated_at,
        confirmation_token,
        raw_app_meta_data,
        raw_user_meta_data
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(),
        'authenticated',
        'authenticated',
        'kari.foreldre@test.no',
        crypt('Test123!', gen_salt('bf')),
        NOW(),
        NOW(),
        NOW(),
        '',
        '{"provider":"email","providers":["email"]}',
        '{"full_name":"Kari Foreldre"}'
    )
    RETURNING id INTO user2_id;

    -- Update profile with category
    UPDATE public.profiles 
    SET user_category = 'foreldre', full_name = 'Kari Foreldre'
    WHERE id = user2_id;

    -- User 3: Healthcare Professional
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        created_at,
        updated_at,
        confirmation_token,
        raw_app_meta_data,
        raw_user_meta_data
    ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        gen_random_uuid(),
        'authenticated',
        'authenticated',
        'lars.helsepersonell@test.no',
        crypt('Test123!', gen_salt('bf')),
        NOW(),
        NOW(),
        NOW(),
        '',
        '{"provider":"email","providers":["email"]}',
        '{"full_name":"Dr. Lars Helsepersonell"}'
    )
    RETURNING id INTO user3_id;

    -- Update profile with category
    UPDATE public.profiles 
    SET user_category = 'helsepersonell', full_name = 'Dr. Lars Helsepersonell'
    WHERE id = user3_id;

    RAISE NOTICE 'Created 3 test users successfully!';
END $$;

-- Step 3: Re-add the constraint
ALTER TABLE public.profiles
ADD CONSTRAINT user_category_required 
CHECK (role = 'admin' OR user_category IS NOT NULL);

-- Display the created users
SELECT 
    full_name,
    CASE 
        WHEN user_category = 'søsken' THEN '🧒 Søsken'
        WHEN user_category = 'foreldre' THEN '👨‍👩‍👧 Foreldre'
        WHEN user_category = 'helsepersonell' THEN '👨‍⚕️ Helsepersonell'
        ELSE 'Not set'
    END as category,
    role,
    created_at
FROM public.profiles
WHERE role = 'member'
ORDER BY created_at DESC
LIMIT 5;

-- Test user credentials:
-- Email: emma.sosken@test.no | Password: Test123! | Category: Søsken
-- Email: kari.foreldre@test.no | Password: Test123! | Category: Foreldre  
-- Email: lars.helsepersonell@test.no | Password: Test123! | Category: Helsepersonell
