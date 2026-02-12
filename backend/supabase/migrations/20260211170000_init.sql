-- Asset Tuner: initial Supabase schema per docs/contracts/data_contract.md (2026-02-12)

create extension if not exists pgcrypto with schema extensions;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  base_currency text not null,
  plan text not null check (plan in ('free', 'paid')),
  entitlements jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists trg_profiles_set_updated_at on public.profiles;
create trigger trg_profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create table if not exists public.accounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.profiles(user_id) on delete cascade,
  name text not null check (length(trim(name)) > 0),
  type text not null check (type in ('bank', 'wallet', 'exchange', 'cash', 'other')),
  archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_accounts_user_updated_at on public.accounts(user_id, updated_at desc);

drop trigger if exists trg_accounts_set_updated_at on public.accounts;
create trigger trg_accounts_set_updated_at
before update on public.accounts
for each row execute function public.set_updated_at();

create table if not exists public.assets (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('fiat', 'crypto')),
  code text not null check (code = upper(code)),
  name text not null,
  decimals int null
);

create unique index if not exists uq_assets_kind_code on public.assets(kind, code);

create table if not exists public.subaccounts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.profiles(user_id) on delete cascade,
  account_id uuid not null references public.accounts(id) on delete cascade,
  asset_id uuid not null references public.assets(id) on delete restrict,
  name text not null check (length(trim(name)) > 0),
  archived boolean not null default false,
  sort_order int null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_subaccounts_account_id on public.subaccounts(account_id);
create index if not exists idx_subaccounts_user_id on public.subaccounts(user_id);

drop trigger if exists trg_subaccounts_set_updated_at on public.subaccounts;
create trigger trg_subaccounts_set_updated_at
before update on public.subaccounts
for each row execute function public.set_updated_at();

create table if not exists public.balance_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.profiles(user_id) on delete cascade,
  subaccount_id uuid not null references public.subaccounts(id) on delete cascade,
  entry_date date not null,
  snapshot_amount text not null check (snapshot_amount ~ '^-?[0-9]+(\.[0-9]+)?$'),
  diff_amount text null check (diff_amount is null or diff_amount ~ '^-?[0-9]+(\.[0-9]+)?$'),
  created_at timestamptz not null default now()
);

create index if not exists idx_balance_entries_subaccount_desc
  on public.balance_entries(subaccount_id, entry_date desc, created_at desc);
create index if not exists idx_balance_entries_subaccount_asc
  on public.balance_entries(subaccount_id, entry_date asc, created_at asc);

create table if not exists public.asset_rates_usd (
  asset_id uuid primary key references public.assets(id) on delete cascade,
  usd_price text not null check (usd_price ~ '^[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$' and usd_price::numeric > 0),
  as_of timestamptz not null
);

create index if not exists idx_asset_rates_usd_as_of on public.asset_rates_usd(as_of desc);

alter table public.profiles enable row level security;
alter table public.accounts enable row level security;
alter table public.assets enable row level security;
alter table public.subaccounts enable row level security;
alter table public.balance_entries enable row level security;
alter table public.asset_rates_usd enable row level security;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own
on public.profiles
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists accounts_select_own on public.accounts;
create policy accounts_select_own
on public.accounts
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists accounts_update_own on public.accounts;
create policy accounts_update_own
on public.accounts
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists subaccounts_select_own on public.subaccounts;
create policy subaccounts_select_own
on public.subaccounts
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists balance_entries_select_own on public.balance_entries;
create policy balance_entries_select_own
on public.balance_entries
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists assets_select_public on public.assets;
create policy assets_select_public
on public.assets
for select
to anon, authenticated
using (true);

drop policy if exists asset_rates_usd_select_public on public.asset_rates_usd;
create policy asset_rates_usd_select_public
on public.asset_rates_usd
for select
to anon, authenticated
using (true);

revoke all on table public.profiles from anon, authenticated;
revoke all on table public.accounts from anon, authenticated;
revoke all on table public.assets from anon, authenticated;
revoke all on table public.subaccounts from anon, authenticated;
revoke all on table public.balance_entries from anon, authenticated;
revoke all on table public.asset_rates_usd from anon, authenticated;

grant select on table public.profiles to authenticated;
grant select, update on table public.accounts to authenticated;
grant select on table public.subaccounts to authenticated;
grant select on table public.balance_entries to authenticated;
grant select on table public.assets to anon, authenticated;
grant select on table public.asset_rates_usd to anon, authenticated;

grant all on table public.profiles to service_role;
grant all on table public.accounts to service_role;
grant all on table public.assets to service_role;
grant all on table public.subaccounts to service_role;
grant all on table public.balance_entries to service_role;
grant all on table public.asset_rates_usd to service_role;

insert into storage.buckets (id, name, public)
values ('asset_icons', 'asset_icons', true)
on conflict (id) do nothing;

drop policy if exists storage_objects_select_asset_icons on storage.objects;
create policy storage_objects_select_asset_icons
on storage.objects
for select
to anon, authenticated
using (bucket_id = 'asset_icons');
