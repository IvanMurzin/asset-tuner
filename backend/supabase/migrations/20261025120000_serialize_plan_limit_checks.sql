-- QA-017: serialize plan-limit checks per user. Two parallel creates could both read the count
-- below the limit and both insert. A transaction-scoped advisory lock per user makes the
-- count-then-insert atomic. Bodies are the production definitions with only the lock added.

CREATE OR REPLACE FUNCTION public.api_create_account(p_user_id uuid, p_name text, p_type text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_profile public.profiles;
  v_limits public.plan_limits;
  v_count int;
  v_account public.accounts;
  v_base_asset public.assets;
  v_base_rate public.asset_rates_usd;
  v_result jsonb;
begin
  perform pg_advisory_xact_lock(hashtext('asset_tuner.user_limits'), hashtext(p_user_id::text));
  if p_name is null or length(trim(p_name)) = 0 then
    raise exception 'VALIDATION_ERROR: account name is required';
  end if;
  if p_type is null or length(trim(p_type)) = 0 then
    raise exception 'VALIDATION_ERROR: account type is required';
  end if;

  v_profile := public.api_ensure_profile(p_user_id);

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
$function$;

CREATE OR REPLACE FUNCTION public.api_create_subaccount(p_user_id uuid, p_account_id uuid, p_asset_id uuid, p_name text, p_initial_amount_atomic text, p_initial_amount_decimals smallint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_profile public.profiles;
  v_limits public.plan_limits;
  v_asset public.assets;
  v_count int;
  v_subaccount public.subaccounts;
  v_result jsonb;
begin
  perform pg_advisory_xact_lock(hashtext('asset_tuner.user_limits'), hashtext(p_user_id::text));
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
$function$;

CREATE OR REPLACE FUNCTION public.api_create_support_message(p_user_id uuid, p_name text, p_email text, p_subject text, p_message text, p_meta jsonb DEFAULT '{}'::jsonb, p_max_per_hour integer DEFAULT 5)
 RETURNS support_messages
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_row public.support_messages;

v_recent_count int;

v_subject text;

begin
  perform pg_advisory_xact_lock(hashtext('asset_tuner.user_limits'), hashtext(p_user_id::text));
  if p_name is null or length(trim(p_name)) = 0 then
    raise exception 'VALIDATION_ERROR: name is required';

end if;

if p_message is null or length(trim(p_message)) = 0 then
    raise exception 'VALIDATION_ERROR: message is required';

end if;

if p_max_per_hour is null or p_max_per_hour < 1 then
    raise exception 'VALIDATION_ERROR: p_max_per_hour must be >= 1';

end if;

select count(*)
  into v_recent_count
  from public.support_messages s
  where s.user_id = p_user_id
    and s.created_at >= now() - interval '1 hour';

if v_recent_count >= p_max_per_hour then
    raise exception 'RATE_LIMITED: support message limit reached';

end if;

v_subject := coalesce(nullif(trim(p_subject), ''), 'Contact developer');

insert into public.support_messages(
    user_id,
    name,
    email,
    subject,
    message,
    meta
  )
  values (
    p_user_id,
    trim(p_name),
    nullif(trim(p_email), ''),
    v_subject,
    trim(p_message),
    coalesce(p_meta, '{}'::jsonb)
  )
  returning * into v_row;

return v_row;

end;

$function$;
