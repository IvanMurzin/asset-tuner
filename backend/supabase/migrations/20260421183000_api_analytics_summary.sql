create or replace function public.api_analytics_summary(
  p_user_id uuid,
  p_updates_limit int default 200
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile public.profiles;
  v_base_asset public.assets;
  v_base_rate public.asset_rates_usd;
  v_base_currency text := 'USD';
  v_base_decimals int := 2;
  v_base_usd_price numeric := 1;
  v_as_of timestamptz;
  v_breakdown jsonb := '[]'::jsonb;
  v_updates jsonb := '[]'::jsonb;
  v_updates_limit int := coalesce(p_updates_limit, 200);
begin
  if v_updates_limit < 1 or v_updates_limit > 500 then
    raise exception 'VALIDATION_ERROR: updatesLimit must be in range 1..500';
  end if;

  v_profile := public.api_ensure_profile(p_user_id);

  if v_profile.base_asset_id is not null then
    select *
    into v_base_asset
    from public.assets a
    where a.id = v_profile.base_asset_id;
  end if;

  if v_base_asset.id is null then
    select *
    into v_base_asset
    from public.assets a
    where a.kind = 'fiat'
      and a.code = 'USD'
    limit 1;
  end if;

  if v_base_asset.id is not null then
    v_base_currency := v_base_asset.code;
    v_base_decimals := v_base_asset.decimals;
  end if;

  if v_base_currency <> 'USD' then
    select *
    into v_base_rate
    from public.asset_rates_usd r
    where r.asset_id = v_base_asset.id;

    if v_base_rate.asset_id is null then
      v_base_usd_price := null;
    else
      v_base_usd_price := public.atomic_to_numeric(
        v_base_rate.usd_price_atomic,
        v_base_rate.usd_price_decimals
      );
    end if;
  end if;

  with active_accounts as (
    select a.id
    from public.accounts a
    where a.user_id = p_user_id
      and not a.archived
  )
  select max(r.as_of)
  into v_as_of
  from public.subaccounts s
  join active_accounts aa
    on aa.id = s.account_id
  left join public.asset_rates_usd r
    on r.asset_id = s.asset_id
  where s.user_id = p_user_id;

  if v_base_rate.as_of is not null and (v_as_of is null or v_base_rate.as_of > v_as_of) then
    v_as_of := v_base_rate.as_of;
  end if;

  with active_accounts as (
    select a.id
    from public.accounts a
    where a.user_id = p_user_id
      and not a.archived
  ),
  per_asset as (
    select
      s.asset_id,
      a.code as asset_code,
      a.decimals as asset_decimals,
      sum(public.atomic_to_numeric(s.current_amount_atomic, s.current_amount_decimals)) as original_amount_numeric,
      sum(
        public.atomic_to_numeric(s.current_amount_atomic, s.current_amount_decimals)
        * public.atomic_to_numeric(r.usd_price_atomic, r.usd_price_decimals)
      ) as total_usd_numeric
    from public.subaccounts s
    join active_accounts aa
      on aa.id = s.account_id
    join public.assets a
      on a.id = s.asset_id
    left join public.asset_rates_usd r
      on r.asset_id = s.asset_id
    where s.user_id = p_user_id
    group by s.asset_id, a.code, a.decimals
  ),
  priced as (
    select
      p.asset_id,
      p.asset_code,
      p.asset_decimals,
      p.original_amount_numeric,
      case
        when v_base_usd_price is null then null
        else p.total_usd_numeric / v_base_usd_price
      end as value_numeric
    from per_asset p
    where p.original_amount_numeric <> 0
  )
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'asset_id', p.asset_id,
        'asset_code', p.asset_code,
        'original_amount_atomic', public.numeric_to_atomic(p.original_amount_numeric, p.asset_decimals),
        'original_amount_decimals', p.asset_decimals,
        'value_atomic', public.numeric_to_atomic(p.value_numeric, v_base_decimals),
        'value_decimals', v_base_decimals
      )
      order by p.value_numeric desc, p.asset_code asc
    ),
    '[]'::jsonb
  )
  into v_breakdown
  from priced p
  where p.value_numeric is not null;

  with active_accounts as (
    select a.id, a.name
    from public.accounts a
    where a.user_id = p_user_id
      and not a.archived
  ),
  entries as (
    select
      b.id,
      b.subaccount_id,
      b.created_at,
      s.account_id,
      aa.name as account_name,
      s.name as subaccount_name,
      s.asset_id,
      a.code as asset_code,
      a.decimals as asset_decimals,
      public.atomic_to_numeric(b.amount_atomic, b.amount_decimals) as amount_numeric,
      lag(public.atomic_to_numeric(b.amount_atomic, b.amount_decimals)) over (
        partition by b.subaccount_id
        order by b.created_at asc, b.id asc
      ) as prev_amount_numeric,
      case
        when r.asset_id is null then null
        else public.atomic_to_numeric(r.usd_price_atomic, r.usd_price_decimals)
      end as asset_usd_price
    from public.balance_entries b
    join public.subaccounts s
      on s.id = b.subaccount_id
     and s.user_id = p_user_id
    join active_accounts aa
      on aa.id = s.account_id
    join public.assets a
      on a.id = s.asset_id
    left join public.asset_rates_usd r
      on r.asset_id = s.asset_id
    where b.user_id = p_user_id
  ),
  diffed as (
    select
      e.id,
      e.account_id,
      e.account_name,
      e.subaccount_id,
      e.subaccount_name,
      e.asset_id,
      e.asset_code,
      e.asset_decimals,
      e.created_at,
      e.amount_numeric - e.prev_amount_numeric as diff_numeric,
      case
        when v_base_usd_price is null or e.asset_usd_price is null then null
        else (e.amount_numeric - e.prev_amount_numeric) * e.asset_usd_price / v_base_usd_price
      end as diff_base_numeric
    from entries e
    where e.prev_amount_numeric is not null
  ),
  filtered as (
    select *
    from diffed d
    where d.diff_numeric <> 0
      and d.diff_base_numeric is not null
    order by d.created_at desc, d.id desc
    limit v_updates_limit
  )
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'account_id', f.account_id,
        'account_name', f.account_name,
        'subaccount_id', f.subaccount_id,
        'subaccount_name', f.subaccount_name,
        'asset_id', f.asset_id,
        'asset_code', f.asset_code,
        'diff_atomic', public.numeric_to_atomic(f.diff_numeric, f.asset_decimals),
        'diff_decimals', f.asset_decimals,
        'diff_base_atomic', public.numeric_to_atomic(f.diff_base_numeric, v_base_decimals),
        'diff_base_decimals', v_base_decimals,
        'created_at', f.created_at
      )
      order by f.created_at desc, f.id desc
    ),
    '[]'::jsonb
  )
  into v_updates
  from filtered f;

  return jsonb_build_object(
    'base_currency', v_base_currency,
    'base_asset_id', v_base_asset.id,
    'as_of', v_as_of,
    'breakdown', v_breakdown,
    'updates', v_updates
  );
end;
$$;

revoke all on function public.api_analytics_summary(uuid, int) from public, anon, authenticated;
grant execute on function public.api_analytics_summary(uuid, int) to service_role;
