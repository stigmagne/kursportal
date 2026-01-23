INSERT INTO public.profiles (id, full_name, user_category)
SELECT 
  au.id, 
  COALESCE(au.raw_user_meta_data->>'full_name', 'Unknown User'),
  'søsken'
FROM auth.users au
LEFT JOIN public.profiles pp ON au.id = pp.id
WHERE pp.id IS NULL;

-- Notify
DO $$
BEGIN
  RAISE NOTICE 'Synced missing profiles from auth.users';
END $$;
