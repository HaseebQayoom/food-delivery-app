-- ============================================================
-- crave. Food Delivery App — Supabase Database Schema
-- Run this entire file in: Supabase Dashboard → SQL Editor
-- ============================================================

-- ── 1. Drop existing tables ────────────────────────────────

drop table if exists favorites        cascade;
drop table if exists dishes           cascade;
drop table if exists categories       cascade;
drop table if exists restaurants      cascade;
drop table if exists orders           cascade;
drop table if exists addresses        cascade;
drop table if exists payment_methods  cascade;
drop table if exists profiles         cascade;

-- ── 2. Tables ─────────────────────────────────────────────

create table restaurants (
  id                uuid primary key default gen_random_uuid(),
  name              text not null,
  image_url         text,
  cuisine_tags      text[] default '{}',
  rating            numeric(3,1) default 4.0,
  delivery_time_min integer default 30,
  min_order_rs      integer default 200,
  is_favorite       boolean default false,
  created_at        timestamptz default now()
);

create table categories (
  id   text primary key,
  name text not null
);

create table dishes (
  id              uuid primary key default gen_random_uuid(),
  name            text not null,
  image_url       text,
  restaurant_id   uuid references restaurants(id) on delete cascade,
  restaurant_name text not null,
  price_rs        integer not null,
  calories        integer not null,
  tag             text    default '',
  category_id     text,
  description     text    default '',
  is_available    boolean default true,
  rating          numeric(3,1) default 0.0,
  prep_time_min   integer default 0,
  popular         boolean default false,
  created_at      timestamptz default now()
);

create table profiles (
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

create table addresses (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid references auth.users(id) on delete cascade not null,
  label        text not null,
  full_address text not null,
  lat          float8 not null default 0,
  lng          float8 not null default 0,
  is_default   boolean default false,
  created_at   timestamptz default now()
);

create table payment_methods (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users(id) on delete cascade not null,
  type       text not null,
  label      text not null,
  last_four  text,
  is_default boolean default false,
  created_at timestamptz default now()
);

create table orders (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid references auth.users(id) on delete cascade not null,
  items            jsonb not null default '[]',
  status           text not null default 'placed',
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

create table favorites (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid references auth.users(id) on delete cascade not null,
  dish_id    uuid references dishes(id) on delete cascade,
  type       text not null default 'dish',
  created_at timestamptz default now(),
  unique (user_id, dish_id)
);

-- ── 3. Row Level Security ──────────────────────────────────

alter table restaurants     enable row level security;
alter table dishes          enable row level security;
alter table categories      enable row level security;
alter table profiles        enable row level security;
alter table addresses       enable row level security;
alter table payment_methods enable row level security;
alter table orders          enable row level security;
alter table favorites       enable row level security;

drop policy if exists "restaurants: public read"       on restaurants;
create policy "restaurants: public read"
  on restaurants for select using (true);

drop policy if exists "dishes: public read"            on dishes;
create policy "dishes: public read"
  on dishes for select using (true);

drop policy if exists "dishes: authenticated write"    on dishes;
create policy "dishes: authenticated write"
  on dishes for all using (auth.uid() is not null);

drop policy if exists "categories: public read"        on categories;
create policy "categories: public read"
  on categories for select using (true);

drop policy if exists "categories: authenticated write" on categories;
create policy "categories: authenticated write"
  on categories for all using (auth.uid() is not null);

drop policy if exists "profiles: owner all"            on profiles;
create policy "profiles: owner all"
  on profiles for all using (auth.uid() = id);

drop policy if exists "addresses: owner all"           on addresses;
create policy "addresses: owner all"
  on addresses for all using (auth.uid() = user_id);

drop policy if exists "payment_methods: owner all"     on payment_methods;
create policy "payment_methods: owner all"
  on payment_methods for all using (auth.uid() = user_id);

drop policy if exists "orders: owner all"              on orders;
create policy "orders: owner all"
  on orders for all using (auth.uid() = user_id);

drop policy if exists "orders: admin read all"         on orders;
create policy "orders: admin read all"
  on orders for select using (auth.uid() is not null);

drop policy if exists "orders: admin update status"    on orders;
create policy "orders: admin update status"
  on orders for update using (auth.uid() is not null);

drop policy if exists "favorites: owner all"           on favorites;
create policy "favorites: owner all"
  on favorites for all using (auth.uid() = user_id);

-- ── 4. Profile auto-creation trigger ──────────────────────

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

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── 5. Storage bucket for dish images ─────────────────────

insert into storage.buckets (id, name, public)
values ('dish-images', 'dish-images', true)
on conflict (id) do nothing;

drop policy if exists "dish images: public read"   on storage.objects;
create policy "dish images: public read"
  on storage.objects for select using (bucket_id = 'dish-images');

drop policy if exists "dish images: auth upload"   on storage.objects;
create policy "dish images: auth upload"
  on storage.objects for insert
  with check (bucket_id = 'dish-images' and auth.uid() is not null);

drop policy if exists "dish images: auth update"   on storage.objects;
create policy "dish images: auth update"
  on storage.objects for update
  using (bucket_id = 'dish-images' and auth.uid() is not null);

drop policy if exists "dish images: auth delete"   on storage.objects;
create policy "dish images: auth delete"
  on storage.objects for delete
  using (bucket_id = 'dish-images' and auth.uid() is not null);

-- ── 6. Storage bucket for user avatars ────────────────────

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "avatars: public read"   on storage.objects;
create policy "avatars: public read"
  on storage.objects for select using (bucket_id = 'avatars');

drop policy if exists "avatars: owner upload"  on storage.objects;
create policy "avatars: owner upload"
  on storage.objects for insert
  with check (bucket_id = 'avatars' and auth.uid() is not null
              and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "avatars: owner update"  on storage.objects;
create policy "avatars: owner update"
  on storage.objects for update
  using (bucket_id = 'avatars' and auth.uid() is not null
         and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "avatars: owner delete"  on storage.objects;
create policy "avatars: owner delete"
  on storage.objects for delete
  using (bucket_id = 'avatars' and auth.uid() is not null
         and (storage.foldername(name))[1] = auth.uid()::text);

-- ── 7. Seed Data ───────────────────────────────────────────

insert into categories (id, name) values
  ('1', 'Burgers & Wraps'),
  ('2', 'Pizza'),
  ('3', 'Asian'),
  ('4', 'Salads'),
  ('5', 'Desserts');

insert into restaurants (id, name, cuisine_tags, rating, delivery_time_min, min_order_rs)
values (
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'Crave Kitchen',
  '{Burgers,Pizza,Asian}',
  4.8, 25, 300
);

insert into dishes (name, image_url, restaurant_id, restaurant_name, price_rs, calories, tag, category_id) values

  -- Burgers & Wraps
  ('Classic Smash Burger',
   'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 650,  720, 'BESTSELLER', '1'),

  ('Crispy Chicken Wrap',
   'https://images.unsplash.com/photo-1571331421405-51b8feea1033?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 480,  530, 'NEW',        '1'),

  ('BBQ Bacon Burger',
   'https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 720,  780, 'POPULAR',    '1'),

  ('Zinger Burger',
   'https://images.unsplash.com/photo-1607013251379-e6eecfffe234?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 550,  620, '',           '1'),

  ('Club Sandwich',
   'https://images.unsplash.com/photo-1553909489-cd47e0907980?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 420,  490, 'NEW',        '1'),

  ('Loaded Fries',
   'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 250,  380, 'TRENDING',   '1'),

  ('Double Cheese Burger',
   'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 780,  860, 'POPULAR',    '1'),

  ('Crispy Fish Burger',
   'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 600,  590, 'NEW',        '1'),

  ('Mushroom Swiss Burger',
   'https://images.unsplash.com/photo-1512152272829-e3139592d56f?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 690,  730, '',           '1'),

  -- Pizza
  ('Margherita Pizza',
   'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 750,  850, '',           '2'),

  ('Pepperoni Pizza',
   'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 850,  950, 'POPULAR',    '2'),

  ('BBQ Chicken Pizza',
   'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 900,  980, 'BESTSELLER', '2'),

  ('Four Cheese Pizza',
   'https://images.unsplash.com/photo-1559978137-8c560d91e9e1?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 950, 1020, 'TRENDING',   '2'),

  ('Tandoori Chicken Pizza',
   'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 880,  940, 'BESTSELLER', '2'),

  -- Asian
  ('Pad Thai Noodles',
   'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 420,  480, 'POPULAR',    '3'),

  ('Chicken Biryani',
   'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 450,  680, 'BESTSELLER', '3'),

  ('Shrimp Fried Rice',
   'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 520,  540, '',           '3'),

  ('Chicken Tikka',
   'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 580,  610, 'TRENDING',   '3'),

  ('Beef Chow Mein',
   'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 490,  520, '',           '3'),

  ('Miso Ramen',
   'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 460,  470, 'NEW',        '3'),

  ('Crispy Spring Rolls',
   'https://images.unsplash.com/photo-1559847844-5315695dadae?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 320,  310, 'POPULAR',    '3'),

  -- Salads
  ('Caesar Salad',
   'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 350,  280, '',           '4'),

  ('Greek Salad',
   'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 380,  240, '',           '4'),

  ('Quinoa Power Bowl',
   'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 420,  310, 'TRENDING',   '4'),

  ('Pasta Salad',
   'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 360,  390, '',           '4'),

  -- Desserts
  ('Chocolate Lava Cake',
   'https://images.unsplash.com/photo-1624353365286-3f8d62daad51?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 280,  380, 'TRENDING',   '5'),

  ('Mango Cheesecake',
   'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 290,  350, 'NEW',        '5'),

  ('Brownie Sundae',
   'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 320,  420, 'POPULAR',    '5'),

  ('Oreo Milkshake',
   'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 250,  440, 'POPULAR',    '5'),

  ('Cinnamon Waffle',
   'https://images.unsplash.com/photo-1562376552-0d160a2f238d?w=400&h=300&fit=crop&auto=format',
   'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Crave Kitchen', 300,  480, 'NEW',        '5');
