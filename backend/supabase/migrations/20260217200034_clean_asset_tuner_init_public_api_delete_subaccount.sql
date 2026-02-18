create or replace function public.api_delete_subaccount(
  p_user_id uuid,
  p_subaccount_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_account_id uuid;
begin
  select s.account_id into v_account_id
  from public.subaccounts s
  where s.id = p_subaccount_id
    and s.user_id = p_user_id;

  if not found then
    raise exception 'NOT_FOUND: subaccount not found';
  end if;

  delete from public.subaccounts s
  where s.id = p_subaccount_id
    and s.user_id = p_user_id;

  perform public.recompute_account_cached_total_usd(v_account_id);
end;
$func$;
