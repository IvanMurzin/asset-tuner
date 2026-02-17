begin;

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

create or replace function public.validate_amount_atomic(p_value text)
returns boolean
language sql
immutable
strict
as $$
  select p_value ~ '^-?\\d+$';
$$;

create or replace function public.atomic_to_numeric(p_amount_atomic text, p_decimals int)
returns numeric
language plpgsql
immutable
strict
as $$
begin
  if p_decimals < 0 or p_decimals > 18 then
    raise exception 'VALIDATION_ERROR: decimals must be in range 0..18';
  end if;
  if not public.validate_amount_atomic(p_amount_atomic) then
    raise exception 'VALIDATION_ERROR: invalid atomic integer string';
  end if;

  return p_amount_atomic::numeric / power(10::numeric, p_decimals);
end;
$$;

create or replace function public.numeric_to_atomic(p_value numeric, p_decimals int)
returns text
language plpgsql
immutable
strict
as $$
declare
  v_scaled numeric;
begin
  if p_decimals < 0 or p_decimals > 18 then
    raise exception 'VALIDATION_ERROR: decimals must be in range 0..18';
  end if;

  -- Round half away from zero via round(..., 0).
  v_scaled := round(p_value * power(10::numeric, p_decimals), 0);
  return v_scaled::text;
end;
$$;

create table if not exists public.assets (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('fiat', 'crypto')),
  code text not null check (code = upper(code)),
  name text not null,
  provider text not null,
  provider_ref text not null,
  rank int not null check (rank between 1 and 100),
  decimals smallint not null check (decimals between 0 and 18),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (kind, code)
);

create index if not exists idx_assets_kind_rank on public.assets(kind, rank);

create table if not exists public.asset_rates_usd (
  asset_id uuid primary key references public.assets(id) on delete cascade,
  usd_price_atomic text not null check (public.validate_amount_atomic(usd_price_atomic)),
  usd_price_decimals smallint not null check (usd_price_decimals between 0 and 18),
  as_of timestamptz not null,
  updated_at timestamptz not null default now()
);

create index if not exists idx_asset_rates_usd_as_of_desc on public.asset_rates_usd(as_of desc);

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  plan text not null default 'free' check (plan in ('free', 'pro')),
  base_asset_id uuid null references public.assets(id) on delete set null,
  revenuecat_app_user_id text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists uq_profiles_revenuecat_app_user_id
  on public.profiles(revenuecat_app_user_id)
  where revenuecat_app_user_id is not null;

create table if not exists public.plan_limits (
  plan text primary key check (plan in ('free', 'pro')),
  max_accounts int null,
  max_subaccounts int null,
  fiat_limit int null,
  crypto_limit int null
);

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

create index if not exists idx_accounts_user_archived on public.accounts(user_id, archived);

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

create index if not exists idx_subaccounts_user_id on public.subaccounts(user_id);
create index if not exists idx_subaccounts_account_id on public.subaccounts(account_id);

create table if not exists public.balance_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  subaccount_id uuid not null references public.subaccounts(id) on delete cascade,
  amount_atomic text not null check (public.validate_amount_atomic(amount_atomic)),
  amount_decimals smallint not null check (amount_decimals between 0 and 18),
  note text null,
  created_at timestamptz not null default now()
);

create index if not exists idx_balance_entries_subaccount_created_desc
  on public.balance_entries(subaccount_id, created_at desc);

create table if not exists public.support_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid null references auth.users(id) on delete set null,
  email text null,
  subject text not null check (length(trim(subject)) > 0),
  message text not null check (length(trim(message)) > 0),
  meta jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_support_messages_user_created_desc
  on public.support_messages(user_id, created_at desc);

create table if not exists public.webhook_events (
  id uuid primary key default gen_random_uuid(),
  source text not null,
  external_id text not null,
  received_at timestamptz not null default now(),
  payload jsonb not null,
  unique (source, external_id)
);

create table if not exists public.fiat_rank_seed (
  code text primary key check (code = upper(code)),
  rank int not null unique check (rank between 1 and 100),
  name text not null,
  decimals smallint not null check (decimals between 0 and 18)
);

create or replace function public.recompute_account_cached_total_usd(p_account_id uuid)
returns table (
  account_id uuid,
  total_atomic text,
  total_decimals smallint,
  as_of timestamptz
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_total_numeric numeric := 0;
  v_total_atomic text := '0';
  v_as_of timestamptz;
  v_exists boolean := false;
  v_usd_decimals smallint := 12;
begin
  select exists(select 1 from public.accounts a where a.id = p_account_id) into v_exists;
  if not v_exists then
    raise exception 'NOT_FOUND: account not found';
  end if;

  select coalesce(
      sum(
        coalesce(
          public.atomic_to_numeric(s.current_amount_atomic, s.current_amount_decimals)
          * public.atomic_to_numeric(r.usd_price_atomic, r.usd_price_decimals),
          0
        )
      ),
      0
    ),
    max(r.as_of)
  into v_total_numeric, v_as_of
  from public.subaccounts s
  left join public.asset_rates_usd r on r.asset_id = s.asset_id
  where s.account_id = p_account_id;

  v_total_atomic := public.numeric_to_atomic(v_total_numeric, v_usd_decimals);

  update public.accounts a
  set
    cached_total_usd_atomic = v_total_atomic,
    cached_total_usd_decimals = v_usd_decimals,
    cached_total_updated_at = coalesce(v_as_of, now()),
    updated_at = now()
  where a.id = p_account_id;

  return query
  select p_account_id, v_total_atomic, v_usd_decimals, coalesce(v_as_of, now());
end;
$$;

create or replace function public.recompute_user_cached_totals(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
begin
  for v_account_id in
    select a.id
    from public.accounts a
    where a.user_id = p_user_id
  loop
    perform public.recompute_account_cached_total_usd(v_account_id);
  end loop;
end;
$$;

create or replace function public.recompute_all_cached_totals()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
begin
  for v_account_id in
    select a.id
    from public.accounts a
  loop
    perform public.recompute_account_cached_total_usd(v_account_id);
  end loop;
end;
$$;

create or replace function public.handle_auth_user_created()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles(user_id)
  values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

create or replace function public.handle_balance_entry_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
begin
  update public.subaccounts s
  set
    current_amount_atomic = new.amount_atomic,
    current_amount_decimals = new.amount_decimals,
    updated_at = now()
  where s.id = new.subaccount_id;

  select s.account_id
  into v_account_id
  from public.subaccounts s
  where s.id = new.subaccount_id;

  if v_account_id is not null then
    perform public.recompute_account_cached_total_usd(v_account_id);
  end if;

  return new;
end;
$$;

create or replace function public.api_profile_update_base_asset(
  p_user_id uuid,
  p_base_asset_id uuid
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile public.profiles;
  v_limits public.plan_limits;
  v_asset public.assets;
begin
  select *
  into v_profile
  from public.profiles
  where user_id = p_user_id;

  if not found then
    raise exception 'NOT_FOUND: profile not found';
  end if;

  select * into v_limits from public.plan_limits where plan = v_profile.plan;
  if not found then
    raise exception 'INTERNAL_ERROR: plan limits not configured';
  end if;

  select * into v_asset from public.assets where id = p_base_asset_id and is_active = true;
  if not found then
    raise exception 'NOT_FOUND: base asset not found';
  end if;

  if v_profile.plan = 'free' then
    if v_asset.kind <> 'fiat' then
      raise exception 'ASSET_NOT_ALLOWED_FOR_PLAN: free plan allows only fiat base asset';
    end if;
    if v_limits.fiat_limit is not null and v_asset.rank > v_limits.fiat_limit then
      raise exception 'ASSET_NOT_ALLOWED_FOR_PLAN: base asset rank exceeds free limit';
    end if;
  end if;

  update public.profiles
  set base_asset_id = p_base_asset_id,
      updated_at = now()
  where user_id = p_user_id
  returning * into v_profile;

  return v_profile;
end;
$$;

create or replace function public.api_create_account(
  p_user_id uuid,
  p_name text,
  p_type text
)
returns public.accounts
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile public.profiles;
  v_limits public.plan_limits;
  v_count int;
  v_account public.accounts;
begin
  if p_name is null or length(trim(p_name)) = 0 then
    raise exception 'VALIDATION_ERROR: account name is required';
  end if;
  if p_type is null or length(trim(p_type)) = 0 then
    raise exception 'VALIDATION_ERROR: account type is required';
  end if;

  select * into v_profile from public.profiles where user_id = p_user_id;
  if not found then
    raise exception 'NOT_FOUND: profile not found';
  end if;

  select * into v_limits from public.plan_limits where plan = v_profile.plan;
  if not found then
    raise exception 'INTERNAL_ERROR: plan limits not configured';
  end if;

  select count(*) into v_count from public.accounts where user_id = p_user_id;
  if v_limits.max_accounts is not null and v_count >= v_limits.max_accounts then
    raise exception 'LIMIT_ACCOUNTS_REACHED: max accounts reached';
  end if;

  insert into public.accounts(user_id, name, type)
  values (p_user_id, trim(p_name), trim(p_type))
  returning * into v_account;

  return v_account;
end;
$$;

create or replace function public.api_update_account(
  p_user_id uuid,
  p_account_id uuid,
  p_name text default null,
  p_type text default null,
  p_archived boolean default null
)
returns public.accounts
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account public.accounts;
begin
  if p_name is not null and length(trim(p_name)) = 0 then
    raise exception 'VALIDATION_ERROR: account name cannot be empty';
  end if;
  if p_type is not null and length(trim(p_type)) = 0 then
    raise exception 'VALIDATION_ERROR: account type cannot be empty';
  end if;

  update public.accounts a
  set
    name = case when p_name is null then a.name else trim(p_name) end,
    type = case when p_type is null then a.type else trim(p_type) end,
    archived = coalesce(p_archived, a.archived),
    updated_at = now()
  where a.id = p_account_id
    and a.user_id = p_user_id
  returning * into v_account;

  if not found then
    raise exception 'NOT_FOUND: account not found';
  end if;

  return v_account;
end;
$$;

create or replace function public.api_delete_account(
  p_user_id uuid,
  p_account_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.accounts a
  where a.id = p_account_id
    and a.user_id = p_user_id;

  if not found then
    raise exception 'NOT_FOUND: account not found';
  end if;
end;
$$;

create or replace function public.api_create_subaccount(
  p_user_id uuid,
  p_account_id uuid,
  p_asset_id uuid,
  p_name text,
  p_initial_amount_atomic text,
  p_initial_amount_decimals smallint
)
returns public.subaccounts
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile public.profiles;
  v_limits public.plan_limits;
  v_asset public.assets;
  v_count int;
  v_subaccount public.subaccounts;
begin
  if p_name is null or length(trim(p_name)) = 0 then
    raise exception 'VALIDATION_ERROR: subaccount name is required';
  end if;
  if p_initial_amount_decimals < 0 or p_initial_amount_decimals > 18 then
    raise exception 'VALIDATION_ERROR: amount decimals must be in range 0..18';
  end if;
  if not public.validate_amount_atomic(p_initial_amount_atomic) then
    raise exception 'VALIDATION_ERROR: invalid initial amount atomic';
  end if;

  perform 1
  from public.accounts a
  where a.id = p_account_id
    and a.user_id = p_user_id;
  if not found then
    raise exception 'NOT_FOUND: account not found';
  end if;

  select * into v_profile from public.profiles where user_id = p_user_id;
  if not found then
    raise exception 'NOT_FOUND: profile not found';
  end if;

  select * into v_limits from public.plan_limits where plan = v_profile.plan;
  if not found then
    raise exception 'INTERNAL_ERROR: plan limits not configured';
  end if;

  select count(*) into v_count from public.subaccounts where user_id = p_user_id;
  if v_limits.max_subaccounts is not null and v_count >= v_limits.max_subaccounts then
    raise exception 'LIMIT_SUBACCOUNTS_REACHED: max subaccounts reached';
  end if;

  select * into v_asset
  from public.assets a
  where a.id = p_asset_id
    and a.is_active = true;
  if not found then
    raise exception 'NOT_FOUND: asset not found';
  end if;

  if v_profile.plan = 'free' then
    if v_asset.kind = 'fiat' then
      if v_limits.fiat_limit is not null and v_asset.rank > v_limits.fiat_limit then
        raise exception 'ASSET_NOT_ALLOWED_FOR_PLAN: fiat rank exceeds free plan limit';
      end if;
    elsif v_asset.kind = 'crypto' then
      if v_limits.crypto_limit is not null and v_asset.rank > v_limits.crypto_limit then
        raise exception 'ASSET_NOT_ALLOWED_FOR_PLAN: crypto rank exceeds free plan limit';
      end if;
    else
      raise exception 'ASSET_NOT_ALLOWED_FOR_PLAN: unknown asset kind';
    end if;
  end if;

  if p_initial_amount_decimals <> v_asset.decimals then
    raise exception 'VALIDATION_ERROR: amount decimals must match asset decimals';
  end if;

  insert into public.subaccounts(
    user_id,
    account_id,
    asset_id,
    name,
    current_amount_atomic,
    current_amount_decimals
  )
  values (
    p_user_id,
    p_account_id,
    p_asset_id,
    trim(p_name),
    p_initial_amount_atomic,
    p_initial_amount_decimals
  )
  returning * into v_subaccount;

  insert into public.balance_entries(
    user_id,
    subaccount_id,
    amount_atomic,
    amount_decimals,
    note
  )
  values (
    p_user_id,
    v_subaccount.id,
    p_initial_amount_atomic,
    p_initial_amount_decimals,
    'Initial balance'
  );

  perform public.recompute_account_cached_total_usd(p_account_id);

  return v_subaccount;
end;
$$;

create or replace function public.api_update_subaccount(
  p_user_id uuid,
  p_subaccount_id uuid,
  p_name text default null,
  p_archived boolean default null
)
returns public.subaccounts
language plpgsql
security definer
set search_path = public
as $$
declare
  v_subaccount public.subaccounts;
begin
  if p_name is not null and length(trim(p_name)) = 0 then
    raise exception 'VALIDATION_ERROR: subaccount name cannot be empty';
  end if;

  update public.subaccounts s
  set
    name = case when p_name is null then s.name else trim(p_name) end,
    archived = coalesce(p_archived, s.archived),
    updated_at = now()
  where s.id = p_subaccount_id
    and s.user_id = p_user_id
  returning * into v_subaccount;

  if not found then
    raise exception 'NOT_FOUND: subaccount not found';
  end if;

  perform public.recompute_account_cached_total_usd(v_subaccount.account_id);

  return v_subaccount;
end;
$$;

create or replace function public.api_delete_subaccount(
  p_user_id uuid,
  p_subaccount_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_account_id uuid;
begin
  select s.account_id into v_account_id
  from public.subaccounts s
  where s.id = p_subaccount_id
    and s.user_id = p_user_id;

  if not found then
    raise exception 'NOT_FOUND: subaccount not found';
  end if;

  delete from public.subaccounts s
  where s.id = p_subaccount_id
    and s.user_id = p_user_id;

  perform public.recompute_account_cached_total_usd(v_account_id);
end;
$$;

create or replace function public.api_set_subaccount_balance(
  p_user_id uuid,
  p_subaccount_id uuid,
  p_amount_atomic text,
  p_amount_decimals smallint,
  p_note text default null
)
returns public.balance_entries
language plpgsql
security definer
set search_path = public
as $$
declare
  v_subaccount public.subaccounts;
  v_asset public.assets;
  v_entry public.balance_entries;
begin
  if p_amount_decimals < 0 or p_amount_decimals > 18 then
    raise exception 'VALIDATION_ERROR: amount decimals must be in range 0..18';
  end if;
  if not public.validate_amount_atomic(p_amount_atomic) then
    raise exception 'VALIDATION_ERROR: invalid amount atomic';
  end if;

  select s.* into v_subaccount
  from public.subaccounts s
  where s.id = p_subaccount_id
    and s.user_id = p_user_id;
  if not found then
    raise exception 'NOT_FOUND: subaccount not found';
  end if;

  select * into v_asset from public.assets a where a.id = v_subaccount.asset_id;
  if not found then
    raise exception 'NOT_FOUND: asset not found';
  end if;

  if p_amount_decimals <> v_asset.decimals then
    raise exception 'VALIDATION_ERROR: amount decimals must match asset decimals';
  end if;

  insert into public.balance_entries(
    user_id,
    subaccount_id,
    amount_atomic,
    amount_decimals,
    note
  )
  values (
    p_user_id,
    p_subaccount_id,
    p_amount_atomic,
    p_amount_decimals,
    p_note
  )
  returning * into v_entry;

  perform public.recompute_account_cached_total_usd(v_subaccount.account_id);

  return v_entry;
end;
$$;

create or replace function public.api_create_support_message(
  p_user_id uuid,
  p_email text,
  p_subject text,
  p_message text,
  p_meta jsonb default '{}'::jsonb
)
returns public.support_messages
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.support_messages;
begin
  if p_subject is null or length(trim(p_subject)) = 0 then
    raise exception 'VALIDATION_ERROR: subject is required';
  end if;
  if p_message is null or length(trim(p_message)) = 0 then
    raise exception 'VALIDATION_ERROR: message is required';
  end if;

  insert into public.support_messages(
    user_id,
    email,
    subject,
    message,
    meta
  )
  values (
    p_user_id,
    nullif(trim(p_email), ''),
    trim(p_subject),
    trim(p_message),
    coalesce(p_meta, '{}'::jsonb)
  )
  returning * into v_row;

  return v_row;
end;
$$;

create or replace function public.api_apply_revenuecat_event(
  p_source text,
  p_external_id text,
  p_app_user_id text,
  p_payload jsonb,
  p_is_pro boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_inserted_id uuid;
  v_user_id uuid;
  v_user_id_by_app uuid;
  v_target_user_id uuid;
  v_plan text;
begin
  if p_source is null or length(trim(p_source)) = 0 then
    raise exception 'VALIDATION_ERROR: source is required';
  end if;
  if p_external_id is null or length(trim(p_external_id)) = 0 then
    raise exception 'VALIDATION_ERROR: external_id is required';
  end if;
  if p_app_user_id is null or length(trim(p_app_user_id)) = 0 then
    raise exception 'VALIDATION_ERROR: app_user_id is required';
  end if;

  insert into public.webhook_events(source, external_id, payload)
  values (trim(p_source), trim(p_external_id), coalesce(p_payload, '{}'::jsonb))
  on conflict (source, external_id) do nothing
  returning id into v_inserted_id;

  if v_inserted_id is null then
    return jsonb_build_object(
      'processed', false,
      'reason', 'duplicate'
    );
  end if;

  select p.user_id
  into v_user_id_by_app
  from public.profiles p
  where p.revenuecat_app_user_id = p_app_user_id
  limit 1;

  begin
    v_user_id := p_app_user_id::uuid;
  exception
    when invalid_text_representation then
      v_user_id := null;
  end;

  if v_user_id_by_app is not null then
    v_target_user_id := v_user_id_by_app;
  elsif v_user_id is not null and exists(select 1 from public.profiles where user_id = v_user_id) then
    v_target_user_id := v_user_id;
  else
    return jsonb_build_object(
      'processed', true,
      'updated', false,
      'reason', 'profile_not_found'
    );
  end if;

  v_plan := case when p_is_pro then 'pro' else 'free' end;

  update public.profiles p
  set
    plan = v_plan,
    revenuecat_app_user_id = p_app_user_id,
    updated_at = now()
  where p.user_id = v_target_user_id;

  return jsonb_build_object(
    'processed', true,
    'updated', true,
    'user_id', v_target_user_id,
    'plan', v_plan
  );
end;
$$;

drop trigger if exists trg_assets_set_updated_at on public.assets;
create trigger trg_assets_set_updated_at
before update on public.assets
for each row execute function public.set_updated_at();

drop trigger if exists trg_asset_rates_usd_set_updated_at on public.asset_rates_usd;
create trigger trg_asset_rates_usd_set_updated_at
before update on public.asset_rates_usd
for each row execute function public.set_updated_at();

drop trigger if exists trg_profiles_set_updated_at on public.profiles;
create trigger trg_profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

drop trigger if exists trg_accounts_set_updated_at on public.accounts;
create trigger trg_accounts_set_updated_at
before update on public.accounts
for each row execute function public.set_updated_at();

drop trigger if exists trg_subaccounts_set_updated_at on public.subaccounts;
create trigger trg_subaccounts_set_updated_at
before update on public.subaccounts
for each row execute function public.set_updated_at();

drop trigger if exists trg_auth_user_created on auth.users;
create trigger trg_auth_user_created
after insert on auth.users
for each row execute function public.handle_auth_user_created();

drop trigger if exists trg_balance_entries_after_insert on public.balance_entries;
create trigger trg_balance_entries_after_insert
after insert on public.balance_entries
for each row execute function public.handle_balance_entry_insert();

alter table public.assets enable row level security;
alter table public.asset_rates_usd enable row level security;
alter table public.profiles enable row level security;
alter table public.plan_limits enable row level security;
alter table public.accounts enable row level security;
alter table public.subaccounts enable row level security;
alter table public.balance_entries enable row level security;
alter table public.support_messages enable row level security;
alter table public.webhook_events enable row level security;
alter table public.fiat_rank_seed enable row level security;

alter table public.assets force row level security;
alter table public.asset_rates_usd force row level security;
alter table public.profiles force row level security;
alter table public.plan_limits force row level security;
alter table public.accounts force row level security;
alter table public.subaccounts force row level security;
alter table public.balance_entries force row level security;
alter table public.support_messages force row level security;
alter table public.webhook_events force row level security;
alter table public.fiat_rank_seed force row level security;

revoke all on table public.assets from anon, authenticated;
revoke all on table public.asset_rates_usd from anon, authenticated;
revoke all on table public.profiles from anon, authenticated;
revoke all on table public.plan_limits from anon, authenticated;
revoke all on table public.accounts from anon, authenticated;
revoke all on table public.subaccounts from anon, authenticated;
revoke all on table public.balance_entries from anon, authenticated;
revoke all on table public.support_messages from anon, authenticated;
revoke all on table public.webhook_events from anon, authenticated;
revoke all on table public.fiat_rank_seed from anon, authenticated;

grant all on table public.assets to service_role;
grant all on table public.asset_rates_usd to service_role;
grant all on table public.profiles to service_role;
grant all on table public.plan_limits to service_role;
grant all on table public.accounts to service_role;
grant all on table public.subaccounts to service_role;
grant all on table public.balance_entries to service_role;
grant all on table public.support_messages to service_role;
grant all on table public.webhook_events to service_role;
grant all on table public.fiat_rank_seed to service_role;

revoke all on function public.api_profile_update_base_asset(uuid, uuid) from public, anon, authenticated;
revoke all on function public.api_create_account(uuid, text, text) from public, anon, authenticated;
revoke all on function public.api_update_account(uuid, uuid, text, text, boolean) from public, anon, authenticated;
revoke all on function public.api_delete_account(uuid, uuid) from public, anon, authenticated;
revoke all on function public.api_create_subaccount(uuid, uuid, uuid, text, text, smallint) from public, anon, authenticated;
revoke all on function public.api_update_subaccount(uuid, uuid, text, boolean) from public, anon, authenticated;
revoke all on function public.api_delete_subaccount(uuid, uuid) from public, anon, authenticated;
revoke all on function public.api_set_subaccount_balance(uuid, uuid, text, smallint, text) from public, anon, authenticated;
revoke all on function public.api_create_support_message(uuid, text, text, text, jsonb) from public, anon, authenticated;
revoke all on function public.api_apply_revenuecat_event(text, text, text, jsonb, boolean) from public, anon, authenticated;
revoke all on function public.recompute_account_cached_total_usd(uuid) from public, anon, authenticated;
revoke all on function public.recompute_user_cached_totals(uuid) from public, anon, authenticated;
revoke all on function public.recompute_all_cached_totals() from public, anon, authenticated;

grant execute on function public.api_profile_update_base_asset(uuid, uuid) to service_role;
grant execute on function public.api_create_account(uuid, text, text) to service_role;
grant execute on function public.api_update_account(uuid, uuid, text, text, boolean) to service_role;
grant execute on function public.api_delete_account(uuid, uuid) to service_role;
grant execute on function public.api_create_subaccount(uuid, uuid, uuid, text, text, smallint) to service_role;
grant execute on function public.api_update_subaccount(uuid, uuid, text, boolean) to service_role;
grant execute on function public.api_delete_subaccount(uuid, uuid) to service_role;
grant execute on function public.api_set_subaccount_balance(uuid, uuid, text, smallint, text) to service_role;
grant execute on function public.api_create_support_message(uuid, text, text, text, jsonb) to service_role;
grant execute on function public.api_apply_revenuecat_event(text, text, text, jsonb, boolean) to service_role;
grant execute on function public.recompute_account_cached_total_usd(uuid) to service_role;
grant execute on function public.recompute_user_cached_totals(uuid) to service_role;
grant execute on function public.recompute_all_cached_totals() to service_role;

commit;
