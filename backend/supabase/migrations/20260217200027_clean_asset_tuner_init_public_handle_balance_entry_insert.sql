create or replace function public.handle_balance_entry_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_account_id uuid;
begin
  update public.subaccounts s
  set
    current_amount_atomic = new.amount_atomic,
    current_amount_decimals = new.amount_decimals,
    updated_at = now()
  where s.id = new.subaccount_id;

  select s.account_id
  into v_account_id
  from public.subaccounts s
  where s.id = new.subaccount_id;

  if v_account_id is not null then
    perform public.recompute_account_cached_total_usd(v_account_id);
  end if;

  return new;
end;
$func$;
