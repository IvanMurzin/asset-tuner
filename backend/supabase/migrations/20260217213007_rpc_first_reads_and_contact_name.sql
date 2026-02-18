create or replace function public.api_ensure_profile(
  p_user_id uuid
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile public.profiles;

begin
  insert into public.profiles(user_id)
  values (p_user_id)
  on conflict (user_id) do nothing;

select *
  into v_profile
  from public.profiles p
  where p.user_id = p_user_id;

if not found then
    raise exception 'INTERNAL_ERROR: failed to ensure profile';

end if;

return v_profile;

end;

$$;
