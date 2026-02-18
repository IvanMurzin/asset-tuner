create or replace function public.api_update_subaccount(
  p_user_id uuid,
  p_subaccount_id uuid,
  p_name text default null,
  p_archived boolean default null
)
returns public.subaccounts
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_subaccount public.subaccounts;
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

  return v_subaccount;
end;
$func$;
