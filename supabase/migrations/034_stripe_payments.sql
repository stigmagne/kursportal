-- 034_stripe_payments.sql

-- CUSTOMERS (Mapping Supabase Auth Users to Stripe Customers)
create table public.customers (
  id uuid references auth.users not null primary key,
  stripe_customer_id text
);

alter table public.customers enable row level security;
-- Only the user can view their own customer ID (usually not needed on client, but safe)
create policy "Users can view own customer record" on customers for select using (auth.uid() = id);


-- PRODUCTS (Synced from Stripe)
create table public.products (
  id text primary key,
  active boolean,
  name text,
  description text,
  image text,
  metadata jsonb
);

alter table public.products enable row level security;
create policy "Allow public read-only access to products" on products for select using (true);


-- PRICES (Synced from Stripe)
create type pricing_type as enum ('one_time', 'recurring');
create type pricing_plan_interval as enum ('day', 'week', 'month', 'year');

create table public.prices (
  id text primary key,
  product_id text references public.products,
  active boolean,
  description text,
  unit_amount bigint,
  currency text check (char_length(currency) = 3),
  type pricing_type,
  interval pricing_plan_interval,
  interval_count integer,
  trial_period_days integer,
  metadata jsonb
);

alter table public.prices enable row level security;
create policy "Allow public read-only access to prices" on prices for select using (true);


-- SUBSCRIPTIONS (Synced from Stripe)
create type subscription_status as enum ('trialing', 'active', 'canceled', 'incomplete', 'incomplete_expired', 'past_due', 'unpaid', 'paused');

create table public.subscriptions (
  id text primary key,
  user_id uuid references auth.users not null,
  status subscription_status,
  metadata jsonb,
  price_id text references public.prices,
  quantity integer,
  cancel_at_period_end boolean,
  created timestamp with time zone default timezone('utc'::text, now()) not null,
  current_period_start timestamp with time zone default timezone('utc'::text, now()) not null,
  current_period_end timestamp with time zone default timezone('utc'::text, now()) not null,
  ended_at timestamp with time zone,
  cancel_at timestamp with time zone,
  canceled_at timestamp with time zone,
  trial_start timestamp with time zone,
  trial_end timestamp with time zone
);

alter table public.subscriptions enable row level security;
create policy "Users can view own subscriptions" on subscriptions for select using (auth.uid() = user_id);

-- REALTIME
-- Enable realtime for these tables so the frontend can update immediately after checkout
alter publication supabase_realtime add table public.products;
alter publication supabase_realtime add table public.prices;
-- Subscriptions usually don't need public realtime, but specific user channel might. 
-- For now simple is better.
