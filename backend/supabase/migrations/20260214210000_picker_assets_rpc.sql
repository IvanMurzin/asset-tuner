-- Single RPC for picker catalog: returns all assets for kind with is_unlocked by plan.
-- Bypasses RLS so client receives full list; locked/unlocked is determined by plan.

create or replace function public.list_assets_for_picker(p_kind text)
returns table(
  id uuid,
  kind text,
  code text,
  name text,
  rank int,
  is_unlocked boolean
)
language plpgsql
volatile
security definer
set search_path = public, pg_temp
as $$
declare
  v_kind text;
begin
  v_kind := lower(trim(coalesce(p_kind, '')));
  if v_kind not in ('fiat', 'crypto') then
    raise exception 'Invalid p_kind: %', p_kind
      using errcode = '22023';
  end if;

  set local row_security = off;

  return query
  select
    a.id,
    a.kind,
    a.code,
    a.name,
    coalesce(rk.rank, 999999)::int as rank,
    case
      when public.current_plan_allow_all() then true
      else coalesce(rk.rank, 999999)::int <= public.current_plan_limit(a.kind)
    end as is_unlocked
  from public.assets a
  left join public.asset_rankings rk
    on rk.asset_id = a.id
  where a.kind = v_kind
  order by coalesce(rk.rank, 999999), a.code;
end;
$$;

revoke all on function public.list_assets_for_picker(text) from public;
grant execute on function public.list_assets_for_picker(text) to anon, authenticated, service_role;

-- Align free plan with "first 5" for both fiat and crypto.
insert into public.plan_limits (plan, fiat_limit, crypto_limit, allow_all)
values
  ('free', 5, 5, false),
  ('paid', 100, 100, false)
on conflict (plan) do update
set
  fiat_limit = excluded.fiat_limit,
  crypto_limit = excluded.crypto_limit,
  allow_all = excluded.allow_all;

drop function if exists public.list_fiat_currencies_for_picker();
drop function if exists public.list_assets_for_subaccount_picker(text);
