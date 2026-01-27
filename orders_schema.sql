-- 1. Create the orders table
create table if not exists public.orders (
  id uuid default gen_random_uuid() primary key,
  user_id text, -- Can store Auth User ID or Guest ID string
  payment_id text,
  amount numeric,
  status text default 'pending', -- e.g., 'paid', 'pending', 'failed'
  shipping_details jsonb, -- Stores the full shipping address snapshot
  order_items jsonb, -- Stores the list of items purchased
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2. Enable Row Level Security (RLS)
alter table public.orders enable row level security;

-- 3. Create Policies

-- Allow anyone (Guest or Auth) to create an order
-- We check 'true' to allow anonymous inserts for guest checkout
drop policy if exists "Enable insert for everyone" on public.orders;
create policy "Enable insert for everyone" 
on public.orders for insert 
with check (true);

-- Allow anyone to VIEW orders (For your Admin Page)
-- NOTE: This is open to public. For production, restrict this to admin emails/roles!
drop policy if exists "Enable select for everyone" on public.orders;
create policy "Enable select for everyone" 
on public.orders for select 
using (true);

-- (Optional) If you want users to ONLY see their own orders, use this instead of the above:
-- create policy "Users can view own orders" 
-- on public.orders for select 
-- using ( auth.uid()::text = user_id );
