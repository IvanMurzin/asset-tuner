create or replace function public.api_create_support_message(
  p_user_id uuid,
  p_email text,
  p_subject text,
  p_message text,
  p_meta jsonb default '{}'::jsonb
)
returns public.support_messages
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_row public.support_messages;
begin
  if p_subject is null or length(trim(p_subject)) = 0 then
    raise exception 'VALIDATION_ERROR: subject is required';
  end if;
  if p_message is null or length(trim(p_message)) = 0 then
    raise exception 'VALIDATION_ERROR: message is required';
  end if;

  insert into public.support_messages(
    user_id,
    email,
    subject,
    message,
    meta
  )
  values (
    p_user_id,
    nullif(trim(p_email), ''),
    trim(p_subject),
    trim(p_message),
    coalesce(p_meta, '{}'::jsonb)
  )
  returning * into v_row;

  return v_row;
end;
$func$;
