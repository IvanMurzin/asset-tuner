-- Rates & Coverage Expansion: plan-aware RLS for assets and asset_rates_usd.

create or replace function public.current_request_plan()
returns text
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_uid uuid;
  v_plan text;
begin
  v_uid := auth.uid();

  if v_uid is null then
    return 'free';
  end if;

  select p.plan
  into v_plan
  from public.profiles p
  where p.user_id = v_uid;

  if v_plan = 'paid' then
    return 'paid';
  end if;

  return 'free';
end;
$$;

create or replace function public.current_plan_allow_all()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select coalesce(
    (
      select pl.allow_all
      from public.plan_limits pl
      where pl.plan = public.current_request_plan()
    ),
    false
  );
$$;

create or replace function public.current_plan_limit(p_kind text)
returns int
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_plan text;
  v_fiat_limit int;
  v_crypto_limit int;
begin
  if p_kind not in ('fiat', 'crypto') then
    return 0;
  end if;

  v_plan := public.current_request_plan();

  select pl.fiat_limit, pl.crypto_limit
  into v_fiat_limit, v_crypto_limit
  from public.plan_limits pl
  where pl.plan = v_plan;

  if p_kind = 'fiat' then
    return coalesce(v_fiat_limit, case when v_plan = 'paid' then 100 else 10 end);
  end if;

  return coalesce(v_crypto_limit, case when v_plan = 'paid' then 100 else 10 end);
end;
$$;

create or replace function public.asset_visible_for_current_user(
  p_kind text,
  p_code text,
  p_provider_ref text
)
returns boolean
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_rank int;
  v_limit int;
begin
  if p_kind not in ('fiat', 'crypto') then
    return false;
  end if;

  if public.current_plan_allow_all() then
    return true;
  end if;

  v_limit := public.current_plan_limit(p_kind);

  select ar.rank
  into v_rank
  from public.asset_rankings ar
  where ar.kind = p_kind
    and ar.code = p_code
    and ar.provider_ref is not distinct from p_provider_ref
  order by ar.rank asc
  limit 1;

  return coalesce(v_rank, 999999) <= v_limit;
end;
$$;

create or replace function public.asset_visible_by_id_for_current_user(p_asset_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_kind text;
  v_code text;
  v_provider_ref text;
begin
  select a.kind, a.code, a.provider_ref
  into v_kind, v_code, v_provider_ref
  from public.assets a
  where a.id = p_asset_id;

  if v_kind is null then
    return false;
  end if;

  return public.asset_visible_for_current_user(v_kind, v_code, v_provider_ref);
end;
$$;

revoke all on function public.current_request_plan() from public;
revoke all on function public.current_plan_allow_all() from public;
revoke all on function public.current_plan_limit(text) from public;
revoke all on function public.asset_visible_for_current_user(text, text, text) from public;
revoke all on function public.asset_visible_by_id_for_current_user(uuid) from public;

grant execute on function public.current_request_plan() to anon, authenticated, service_role;
grant execute on function public.current_plan_allow_all() to anon, authenticated, service_role;
grant execute on function public.current_plan_limit(text) to anon, authenticated, service_role;
grant execute on function public.asset_visible_for_current_user(text, text, text) to anon, authenticated, service_role;
grant execute on function public.asset_visible_by_id_for_current_user(uuid) to anon, authenticated, service_role;

drop policy if exists assets_select_public on public.assets;
create policy assets_select_public
on public.assets
for select
to anon, authenticated
using (public.asset_visible_for_current_user(kind, code, provider_ref));

drop policy if exists asset_rates_usd_select_public on public.asset_rates_usd;
create policy asset_rates_usd_select_public
on public.asset_rates_usd
for select
to anon, authenticated
using (public.asset_visible_by_id_for_current_user(asset_id));
