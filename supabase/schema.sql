-- Enable necessary extensions
create extension if not exists "uuid-ossp";

-- PROFILES (Publicly visible profile info, mostly for admin)
create type user_role as enum ('admin', 'member');

create table public.profiles (
  id uuid references auth.users not null primary key,
  role user_role default 'member',
  full_name text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Access policies for Profiles
alter table public.profiles enable row level security;

create policy "Public profiles are viewable by everyone"
  on profiles for select using ( true );

create policy "Users can insert their own profile"
  on profiles for insert with check ( auth.uid() = id );

create policy "Users can update own profile"
  on profiles for update using ( auth.uid() = id );

-- COURSES (Content)
create table public.courses (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  description text,
  content text, -- Markdown content stored as text
  published boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  author_id uuid references public.profiles(id)
);

alter table public.courses enable row level security;

-- Admins can do everything with courses
create policy "Admins can manage courses"
  on courses for all
  using ( exists (select 1 from profiles where id = auth.uid() and role = 'admin') );

-- Members can view published courses
create policy "Members can view published courses"
  on courses for select
  using ( published = true );

-- QUIZZES
create table public.quizzes (
  id uuid default uuid_generate_v4() primary key,
  course_id uuid references public.courses(id) on delete cascade,
  title text,
  questions jsonb not null, -- Array of {question, options, correctAnswer}
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.quizzes enable row level security;
-- Same policies as courses usually, or separate logic
create policy "Admins manage quizzes" on quizzes for all
using ( exists (select 1 from profiles where id = auth.uid() and role = 'admin') );

create policy "Members view quizzes for published courses" on quizzes for select
using ( exists (select 1 from courses where id = quizzes.course_id and published = true) );

-- USER PROGRESS
create table public.user_progress (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) not null,
  course_id uuid references public.courses(id) not null,
  status text default 'started', -- 'started', 'completed'
  completed_at timestamp with time zone,
  quiz_scores jsonb default '{}'::jsonb, -- Map of quiz_id -> score
  unique(user_id, course_id)
);

alter table public.user_progress enable row level security;

create policy "Users manage their own progress"
  on user_progress for all
  using ( auth.uid() = user_id );

create policy "Admins can view all progress"
  on user_progress for select
  using ( exists (select 1 from profiles where id = auth.uid() and role = 'admin') );

-- JOURNALS (Zero-Knowledge Encrypted)
create table public.journals (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.profiles(id) not null,
  content_encrypted text not null, -- The ciphertext
  iv text not null, -- Initialization vector (base64 encoded)
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table public.journals enable row level security;

-- STRICT POLICY: Only the user can see their own journal rows
-- Even if admin has DB access, they only see ciphertext.
-- RLS prevents leaking even the *existence* or count of entries to other users.
create policy "Users can only access own journals"
  on journals for all
  using ( auth.uid() = user_id );

-- TRIGGERS
-- Auto-create profile on signup
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, new.raw_user_meta_data->>'full_name', 'member');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
