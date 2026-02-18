create table if not exists public.accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (length(trim(name)) > 0),
  type text not null check (length(trim(type)) > 0),
  archived boolean not null default false,
  cached_total_usd_atomic text not null default '0' check (public.validate_amount_atomic(cached_total_usd_atomic)),
  cached_total_usd_decimals smallint not null default 12 check (cached_total_usd_decimals between 0 and 18),
  cached_total_updated_at timestamptz null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
