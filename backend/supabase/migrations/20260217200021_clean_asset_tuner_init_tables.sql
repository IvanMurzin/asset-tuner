create table if not exists public.webhook_events (
  id uuid primary key default gen_random_uuid(),
  source text not null,
  external_id text not null,
  received_at timestamptz not null default now(),
  payload jsonb not null,
  unique (source, external_id)
);
