create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  plan text not null default 'free' check (plan in ('free', 'pro')),
  base_asset_id uuid null references public.assets(id) on delete set null,
  revenuecat_app_user_id text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
