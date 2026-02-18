create index if not exists idx_support_messages_user_created_desc
  on public.support_messages(user_id, created_at desc);
