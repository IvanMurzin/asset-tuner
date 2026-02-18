create or replace function public.handle_auth_user_created()
returns trigger
language plpgsql
security definer
set search_path = public
as $func$
begin
  insert into public.profiles(user_id)
  values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$func$;
