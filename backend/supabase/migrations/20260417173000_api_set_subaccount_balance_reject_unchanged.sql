create or replace function public.api_set_subaccount_balance(
  p_user_id uuid,
  p_subaccount_id uuid,
  p_amount_atomic text,
  p_amount_decimals smallint,
  p_note text default null
)
returns public.balance_entries
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_subaccount public.subaccounts;
  v_asset public.assets;
  v_latest_entry public.balance_entries;
  v_entry public.balance_entries;
begin
  if p_amount_decimals < 0 or p_amount_decimals > 18 then
    raise exception 'VALIDATION_ERROR: amount decimals must be in range 0..18';
  end if;
  if not public.validate_amount_atomic(p_amount_atomic) then
    raise exception 'VALIDATION_ERROR: invalid amount atomic';
  end if;

  select s.* into v_subaccount
  from public.subaccounts s
  where s.id = p_subaccount_id
    and s.user_id = p_user_id;
  if not found then
    raise exception 'NOT_FOUND: subaccount not found';
  end if;

  select * into v_asset from public.assets a where a.id = v_subaccount.asset_id;
  if not found then
    raise exception 'NOT_FOUND: asset not found';
  end if;

  if p_amount_decimals <> v_asset.decimals then
    raise exception 'VALIDATION_ERROR: amount decimals must match asset decimals';
  end if;

  select b.* into v_latest_entry
  from public.balance_entries b
  where b.user_id = p_user_id
    and b.subaccount_id = p_subaccount_id
  order by b.created_at desc, b.id desc
  limit 1;

  if found
     and v_latest_entry.amount_decimals = p_amount_decimals
     and v_latest_entry.amount_atomic = p_amount_atomic then
    raise exception 'VALIDATION_ERROR: amount_unchanged';
  end if;

  insert into public.balance_entries(
    user_id,
    subaccount_id,
    amount_atomic,
    amount_decimals,
    note
  )
  values (
    p_user_id,
    p_subaccount_id,
    p_amount_atomic,
    p_amount_decimals,
    p_note
  )
  returning * into v_entry;

  perform public.recompute_account_cached_total_usd(v_subaccount.account_id);

  return v_entry;
end;
$func$;
