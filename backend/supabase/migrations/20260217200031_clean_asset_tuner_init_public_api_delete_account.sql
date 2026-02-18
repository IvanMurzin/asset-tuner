create or replace function public.api_delete_account(
  p_user_id uuid,
  p_account_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $func$
begin
  delete from public.accounts a
  where a.id = p_account_id
    and a.user_id = p_user_id;

  if not found then
    raise exception 'NOT_FOUND: account not found';
  end if;
end;
$func$;
