-- Full catalog RPC for subaccount picker.
-- Returns all assets for requested kind with plan-aware unlock flag.

create or replace function public.list_assets_for_subaccount_picker(p_kind text)
returns table(
  id uuid,
  kind text,
  code text,
  name text,
  rank int,
  is_unlocked boolean
)
language plpgsql
stable
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

revoke all on function public.list_assets_for_subaccount_picker(text) from public;
grant execute on function public.list_assets_for_subaccount_picker(text) to anon, authenticated, service_role;
