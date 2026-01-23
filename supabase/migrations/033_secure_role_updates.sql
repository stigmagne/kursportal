-- 033_secure_role_updates.sql

-- Function to prevent users from updating their own role
create or replace function public.forbid_role_change()
returns trigger as $$
begin
  -- If role is changing
  if new.role is distinct from old.role then
     -- Allow if it's the service_role (admin client)
     -- NOTE: auth.jwt() is null for service_role in some contexts, but let's check widely used patterns.
     -- However, 'service_role' key usually bypasses RLS. But triggers still fire.
     -- The most reliable way for Supabase to detect service role in PLPGSQL is often checking current_setting.
     -- But actually, if we simply want to deny normal users:
     
     -- Check if the request is coming from an authenticated user context
     if auth.role() = 'authenticated' then
        -- You should NOT be able to change your role, PERIOD.
        -- Even if you are an "admin" user logged in. "Admin" users should use the Admin Console 
        -- which we just updated to use the Service Role client (which has auth.role() = 'service_role').
        raise exception 'You are not allowed to change user roles directly.';
     end if;
  end if;
  return new;
end;
$$ language plpgsql security definer;

-- Trigger to protect the profiles table
drop trigger if exists on_profile_role_change on public.profiles;

create trigger on_profile_role_change
  before update on public.profiles
  for each row execute procedure public.forbid_role_change();
