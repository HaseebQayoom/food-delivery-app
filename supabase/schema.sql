-- ============================================================
-- crave. Food Delivery App — Supabase Database Schema
-- Run this entire file in: Supabase Dashboard → SQL Editor
-- ============================================================

-- ── 1. Tables ─────────────────────────────────────────────

create table if not exists restaurants (
  id               uuid primary key default gen_random_uuid(),
  name             text not null,
  image_url        text,
  cuisine_tags     text[] default '{}',
  rating           numeric(3,1) default 4.0,
  delivery_time_min integer default 30,
  min_order_rs     integer default 200,
  is_favorite      boolean default false,
  created_at       timestamptz default now()
);

create table if not exists dishes (
  id              uuid primary key default gen_random_uuid(),
  name            text not null,
  image_url       text,
  restaurant_id   uuid references restaurants(id) on delete cascade,
  restaurant_name text not null,
  price_rs        integer not null,
  calories        integer not null,
  tag             text default '',
  category_id     text,
  created_at      timestamptz default now()
);

create table if not exists profiles (
  id                   uuid primary key references auth.users(id) on delete cascade,
  full_name            text not null default '',
  email                text not null default '',
  phone                text default '',
  avatar_url           text,
  is_crave_plus_member boolean default false,
  total_orders         integer default 0,
  favorite_count       integer default 0,
  points               integer default 0,
  created_at           timestamptz default now()
);

create table if not exists addresses (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid references auth.users(id) on delete cascade not null,
  label        text not null,
  full_address text not null,
  lat          float8 not null default 0,
  lng          float8 not null default 0,
  is_default   boolean default false,
  created_at   timestamptz default now()
);

create table if not exists payment_methods (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users(id) on delete cascade not null,
  type       text not null,   -- card | cash | wallet
  label      text not null,
  last_four  text,
  is_default boolean default false,
  created_at timestamptz default now()
);

create table if not exists orders (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid references auth.users(id) on delete cascade not null,
  items            jsonb not null default '[]',
  status           text not null default 'placed', -- placed | preparing | picked | delivered
  restaurant_name  text not null,
  delivery_address text not null,
  placed_at        timestamptz default now(),
  subtotal_rs      integer not null,
  delivery_fee_rs  integer not null,
  total_rs         integer not null,
  discount_rs      integer default 0,
  courier_name     text,
  courier_phone    text,
  courier_lat      float8,
  courier_lng      float8
);

create table if not exists favorites (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users(id) on delete cascade not null,
  dish_id    uuid references dishes(id) on delete cascade,
  type       text not null default 'dish',
  created_at timestamptz default now(),
  unique (user_id, dish_id)
);

-- ── 2. Row Level Security ──────────────────────────────────

alter table restaurants    enable row level security;
alter table dishes         enable row level security;
alter table profiles       enable row level security;
alter table addresses      enable row level security;
alter table payment_methods enable row level security;
alter table orders         enable row level security;
alter table favorites      enable row level security;

-- restaurants — anyone can read
drop policy if exists "restaurants: public read" on restaurants;
create policy "restaurants: public read"
  on restaurants for select using (true);

-- dishes — anyone can read
drop policy if exists "dishes: public read" on dishes;
create policy "dishes: public read"
  on dishes for select using (true);

-- profiles — owner only
drop policy if exists "profiles: owner all" on profiles;
create policy "profiles: owner all"
  on profiles for all using (auth.uid() = id);

-- addresses — owner only
drop policy if exists "addresses: owner all" on addresses;
create policy "addresses: owner all"
  on addresses for all using (auth.uid() = user_id);

-- payment_methods — owner only
drop policy if exists "payment_methods: owner all" on payment_methods;
create policy "payment_methods: owner all"
  on payment_methods for all using (auth.uid() = user_id);

-- orders — owner only
drop policy if exists "orders: owner all" on orders;
create policy "orders: owner all"
  on orders for all using (auth.uid() = user_id);

-- favorites — owner only
drop policy if exists "favorites: owner all" on favorites;
create policy "favorites: owner all"
  on favorites for all using (auth.uid() = user_id);

-- ── 3. Profile auto-creation trigger ──────────────────────
-- Ensures a profiles row exists whenever a user signs up via Supabase Auth.

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.email, '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── 4. Seed Data ───────────────────────────────────────────

insert into restaurants (id, name, cuisine_tags, rating, delivery_time_min, min_order_rs)
values (
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'Crave Kitchen',
  '{Burgers,Pizza,Asian}',
  4.8,
  25,
  300
)
on conflict (id) do nothing;

insert into dishes (name, restaurant_id, restaurant_name, price_rs, calories, tag, category_id)
values
  -- Burgers & Wraps (9)
  ('Classic Smash Burger',    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 650,  720, 'BESTSELLER', '1'),
  ('Crispy Chicken Wrap',     'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 480,  530, 'NEW',        '1'),
  ('BBQ Bacon Burger',        'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 720,  780, 'POPULAR',    '1'),
  ('Zinger Burger',           'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 550,  620, '',           '1'),
  ('Club Sandwich',           'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 420,  490, 'NEW',        '1'),
  ('Loaded Fries',            'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 250,  380, 'TRENDING',   '1'),
  ('Double Cheese Burger',    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 780,  860, 'POPULAR',    '1'),
  ('Crispy Fish Burger',      'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 600,  590, 'NEW',        '1'),
  ('Mushroom Swiss Burger',   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 690,  730, '',           '1'),
  -- Pizza (5)
  ('Margherita Pizza',        'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 750,  850, '',           '2'),
  ('Pepperoni Pizza',         'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 850,  950, 'POPULAR',    '2'),
  ('BBQ Chicken Pizza',       'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 900,  980, 'BESTSELLER', '2'),
  ('Four Cheese Pizza',       'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 950, 1020, 'TRENDING',   '2'),
  ('Tandoori Chicken Pizza',  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 880,  940, 'BESTSELLER', '2'),
  -- Asian (7)
  ('Pad Thai Noodles',        'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 420,  480, 'POPULAR',    '3'),
  ('Chicken Biryani',         'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 450,  680, 'BESTSELLER', '3'),
  ('Shrimp Fried Rice',       'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 520,  540, '',           '3'),
  ('Chicken Tikka',           'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 580,  610, 'TRENDING',   '3'),
  ('Beef Chow Mein',          'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 490,  520, '',           '3'),
  ('Miso Ramen',              'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 460,  470, 'NEW',        '3'),
  ('Crispy Spring Rolls',     'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 320,  310, 'POPULAR',    '3'),
  -- Salads (4)
  ('Caesar Salad',            'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 350,  280, '',           '4'),
  ('Greek Salad',             'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 380,  240, '',           '4'),
  ('Quinoa Power Bowl',       'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 420,  310, 'TRENDING',   '4'),
  ('Pasta Salad',             'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 360,  390, '',           '4'),
  -- Desserts (5)
  ('Chocolate Lava Cake',     'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 280,  380, 'TRENDING',   '5'),
  ('Mango Cheesecake',        'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 290,  350, 'NEW',        '5'),
  ('Brownie Sundae',          'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 320,  420, 'POPULAR',    '5'),
  ('Oreo Milkshake',          'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 250,  440, 'POPULAR',    '5'),
  ('Cinnamon Waffle',         'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 300,  480, 'NEW',        '5');

