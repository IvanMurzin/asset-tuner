drop function if exists public.api_update_subaccount(uuid, uuid, text, boolean);

create or replace function public.api_update_subaccount(
  p_user_id uuid,
  p_subaccount_id uuid,
  p_name text default null,
  p_archived boolean default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_subaccount public.subaccounts;
  v_result jsonb;
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
