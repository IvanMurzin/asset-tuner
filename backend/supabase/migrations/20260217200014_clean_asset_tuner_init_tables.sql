create table if not exists public.subaccounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  account_id uuid not null references public.accounts(id) on delete cascade,
  asset_id uuid not null references public.assets(id) on delete restrict,
  name text not null check (length(trim(name)) > 0),
  archived boolean not null default false,
  current_amount_atomic text not null default '0' check (public.validate_amount_atomic(current_amount_atomic)),
  current_amount_decimals smallint not null check (current_amount_decimals between 0 and 18),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
