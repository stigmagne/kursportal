
-- Check current user (assuming we know the email or can list recent users)
SELECT id, email, role, user_category, subgroup FROM auth.users u
JOIN public.profiles p ON u.id = p.id
ORDER BY created_at DESC LIMIT 5;

-- Check published courses and their target groups
SELECT id, title, published, target_groups FROM courses WHERE published = true;
