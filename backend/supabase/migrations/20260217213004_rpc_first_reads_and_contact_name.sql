alter table public.support_messages
  add constraint chk_support_messages_name_nonempty
  check (length(trim(name)) > 0);
