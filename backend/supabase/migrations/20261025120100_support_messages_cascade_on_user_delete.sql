-- Account deletion promises that the user's data is permanently removed. Support messages keep the
-- sender's name, email and text, so they are deleted with the user instead of being orphaned.
alter table public.support_messages
  drop constraint if exists support_messages_user_id_fkey;

alter table public.support_messages
  add constraint support_messages_user_id_fkey
  foreign key (user_id) references auth.users(id) on delete cascade;
