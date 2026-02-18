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
as $func$
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
$func$;
