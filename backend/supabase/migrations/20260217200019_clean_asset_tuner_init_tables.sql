create table if not exists public.support_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid null references auth.users(id) on delete set null,
  email text null,
  subject text not null check (length(trim(subject)) > 0),
  message text not null check (length(trim(message)) > 0),
  meta jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
