-- Fiat picker RPC (returns full ranked fiat list regardless of assets select RLS limits)
-- and align base-currency entitlement check with ranked top-N policy.

create or replace function public.list_fiat_currencies_for_picker()
returns table(
  code text,
  name text,
  rank int
)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select
    a.code,
    a.name,
    coalesce(rk.rank, 999999)::int as rank
  from public.assets a
  left join public.asset_rankings rk
    on rk.asset_id = a.id
  where a.kind = 'fiat'
  order by coalesce(rk.rank, 999999), a.code;
$$;

revoke all on function public.list_fiat_currencies_for_picker() from public;
grant execute on function public.list_fiat_currencies_for_picker() to anon, authenticated, service_role;
