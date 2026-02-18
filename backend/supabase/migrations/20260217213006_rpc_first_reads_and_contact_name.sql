create or replace function public.api_create_support_message(
  p_user_id uuid,
  p_name text,
  p_email text,
  p_subject text,
  p_message text,
  p_meta jsonb default '{}'::jsonb,
  p_max_per_hour int default 5
)
returns public.support_messages
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.support_messages;

v_recent_count int;

v_subject text;

begin
  if p_name is null or length(trim(p_name)) = 0 then
    raise exception 'VALIDATION_ERROR: name is required';

end if;

if p_message is null or length(trim(p_message)) = 0 then
    raise exception 'VALIDATION_ERROR: message is required';

end if;

if p_max_per_hour is null or p_max_per_hour < 1 then
    raise exception 'VALIDATION_ERROR: p_max_per_hour must be >= 1';

end if;

select count(*)
  into v_recent_count
  from public.support_messages s
  where s.user_id = p_user_id
    and s.created_at >= now() - interval '1 hour';

if v_recent_count >= p_max_per_hour then
    raise exception 'RATE_LIMITED: support message limit reached';

end if;

v_subject := coalesce(nullif(trim(p_subject), ''), 'Contact developer');

insert into public.support_messages(
    user_id,
    name,
    email,
    subject,
    message,
    meta
  )
  values (
    p_user_id,
    trim(p_name),
    nullif(trim(p_email), ''),
    v_subject,
    trim(p_message),
    coalesce(p_meta, '{}'::jsonb)
  )
  returning * into v_row;

return v_row;

end;

$$;
