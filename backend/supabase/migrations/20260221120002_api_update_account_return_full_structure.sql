drop function if exists public.api_update_account(uuid, uuid, text, text, boolean);

create or replace function public.api_update_account(
  p_user_id uuid,
  p_account_id uuid,
  p_name text default null,
  p_type text default null,
  p_archived boolean default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_account public.accounts;
  v_profile public.profiles;
  v_base_asset public.assets;
  v_base_rate public.asset_rates_usd;
  v_result jsonb;
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

  v_profile := public.api_ensure_profile(p_user_id);
  if v_profile.base_asset_id is not null then
    select * into v_base_asset from public.assets a where a.id = v_profile.base_asset_id;
    if v_base_asset.id is not null then
      select * into v_base_rate from public.asset_rates_usd r where r.asset_id = v_base_asset.id;
    end if;
  end if;

  select jsonb_build_object(
    'id', t.id,
    'name', t.name,
    'type', t.type,
    'archived', t.archived,
    'subaccounts_count', t.subaccounts_count,
    'totals', jsonb_build_object(
      'total_usd_atomic', public.numeric_to_atomic(t.total_usd_numeric, 12),
      'total_usd_decimals', 12,
      'total_in_base_atomic', case
        when v_base_asset.id is null then null
        when v_base_rate.asset_id is null then null
        when v_base_rate.usd_price_atomic = '0' then null
        else public.numeric_to_atomic(
          t.total_usd_numeric
          / public.atomic_to_numeric(v_base_rate.usd_price_atomic, v_base_rate.usd_price_decimals),
          v_base_asset.decimals
        )
      end,
      'total_in_base_decimals', case
        when v_base_asset.id is null then null
        else v_base_asset.decimals
      end,
      'base_asset_id', case
        when v_base_asset.id is null then null
        else v_base_asset.id
      end,
      'base_asset_code', case
        when v_base_asset.id is null then null
        else v_base_asset.code
      end
    ),
    'cache', jsonb_build_object(
      'cached_total_usd_atomic', t.cached_total_usd_atomic,
      'cached_total_usd_decimals', t.cached_total_usd_decimals,
      'cached_total_updated_at', t.cached_total_updated_at
    ),
    'created_at', t.created_at,
    'updated_at', t.updated_at
  )
  into v_result
  from (
    select
      a.id,
      a.name,
      a.type,
      a.archived,
      a.cached_total_usd_atomic,
      a.cached_total_usd_decimals,
      a.cached_total_updated_at,
      a.created_at,
      a.updated_at,
      count(s.id) filter (where not s.archived) as subaccounts_count,
      coalesce(
        sum(
          public.atomic_to_numeric(s.current_amount_atomic, s.current_amount_decimals)
          * coalesce(public.atomic_to_numeric(r.usd_price_atomic, r.usd_price_decimals), 0::numeric)
        ) filter (where not s.archived),
        0::numeric
      ) as total_usd_numeric
    from public.accounts a
    left join public.subaccounts s
      on s.account_id = a.id
     and s.user_id = p_user_id
    left join public.asset_rates_usd r
      on r.asset_id = s.asset_id
    where a.id = v_account.id
      and a.user_id = p_user_id
    group by a.id
  ) t;

  return v_result;
end;
$func$;
