-- Nextplay: tablas con prefijo nextplay_ para no chocar con tu otra app

create table nextplay_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  household_id uuid not null default gen_random_uuid(),
  name text not null,
  role text not null default 'admin' check (role in ('admin','member')),
  avatar_gradient text default 'linear-gradient(155deg,#FF8556,#D6431A)',
  created_at timestamptz default now()
);

create table nextplay_ratings (
  user_id uuid references nextplay_profiles(id) on delete cascade,
  title_id text not null,
  stars int not null check (stars between 1 and 5),
  created_at timestamptz default now(),
  primary key (user_id, title_id)
);

create table nextplay_list (
  user_id uuid references nextplay_profiles(id) on delete cascade,
  title_id text not null,
  added_at timestamptz default now(),
  primary key (user_id, title_id)
);

alter table nextplay_profiles enable row level security;
alter table nextplay_ratings enable row level security;
alter table nextplay_list enable row level security;

create policy "own profile" on nextplay_profiles for select using (auth.uid() = id or household_id = (select household_id from nextplay_profiles where id = auth.uid()));
create policy "insert own profile" on nextplay_profiles for insert with check (auth.uid() = id);
create policy "update own profile" on nextplay_profiles for update using (auth.uid() = id);

create policy "own ratings" on nextplay_ratings for select using (auth.uid() = user_id);
create policy "write own ratings" on nextplay_ratings for insert with check (auth.uid() = user_id);
create policy "update own ratings" on nextplay_ratings for update using (auth.uid() = user_id);

create policy "own list" on nextplay_list for select using (auth.uid() = user_id);
create policy "write own list" on nextplay_list for insert with check (auth.uid() = user_id);
create policy "delete own list" on nextplay_list for delete using (auth.uid() = user_id);
