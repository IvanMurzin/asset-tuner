alter table public.support_messages
  drop constraint if exists chk_support_messages_name_nonempty;
