drop function if exists public.api_create_subaccount(uuid, uuid, uuid, text, text, smallint);

create or replace function public.api_create_subaccount(
  p_user_id uuid,
  p_account_id uuid,
  p_asset_id uuid,
  p_name text,
  p_initial_amount_atomic text,
  p_initial_amount_decimals smallint
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_profile public.profiles;
  v_limits public.plan_limits;
  v_asset public.assets;
  v_count int;
  v_subaccount public.subaccounts;
  v_result jsonb;
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

  select jsonb_build_object(
    'id', s.id,
    'user_id', s.user_id,
    'account_id', s.account_id,
    'asset_id', s.asset_id,
    'name', s.name,
    'archived', s.archived,
    'current_amount_atomic', s.current_amount_atomic,
    'current_amount_decimals', s.current_amount_decimals,
    'created_at', s.created_at,
    'updated_at', s.updated_at,
    'asset', case
      when a.id is null then null
      else to_jsonb(a)
    end,
    'usd_rate', case
      when r.asset_id is null then null
      else jsonb_build_object(
        'asset_id', r.asset_id,
        'usd_price_atomic', r.usd_price_atomic,
        'usd_price_decimals', r.usd_price_decimals,
        'as_of', r.as_of
      )
    end
  )
  into v_result
  from public.subaccounts s
  left join public.assets a on a.id = s.asset_id
  left join public.asset_rates_usd r on r.asset_id = s.asset_id
  where s.id = v_subaccount.id;

  return v_result;
end;
$func$;
