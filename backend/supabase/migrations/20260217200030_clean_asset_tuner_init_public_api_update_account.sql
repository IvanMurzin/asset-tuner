create or replace function public.api_update_account(
  p_user_id uuid,
  p_account_id uuid,
  p_name text default null,
  p_type text default null,
  p_archived boolean default null
)
returns public.accounts
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_account public.accounts;
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

  return v_account;
end;
$func$;
