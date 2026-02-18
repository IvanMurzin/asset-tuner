create table if not exists public.assets (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('fiat', 'crypto')),
  code text not null check (code = upper(code)),
  name text not null,
  provider text not null,
  provider_ref text not null,
  rank int not null check (rank between 1 and 100),
  decimals smallint not null check (decimals between 0 and 18),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (kind, code)
);
