create or replace function public.api_create_account(
  p_user_id uuid,
  p_name text,
  p_type text
)
returns public.accounts
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_profile public.profiles;
  v_limits public.plan_limits;
  v_count int;
  v_account public.accounts;
begin
  if p_name is null or length(trim(p_name)) = 0 then
    raise exception 'VALIDATION_ERROR: account name is required';
  end if;
  if p_type is null or length(trim(p_type)) = 0 then
    raise exception 'VALIDATION_ERROR: account type is required';
  end if;

  select * into v_profile from public.profiles where user_id = p_user_id;
  if not found then
    raise exception 'NOT_FOUND: profile not found';
  end if;

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

  return v_account;
end;
$func$;
