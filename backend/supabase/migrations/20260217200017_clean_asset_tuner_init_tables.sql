create table if not exists public.balance_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  subaccount_id uuid not null references public.subaccounts(id) on delete cascade,
  amount_atomic text not null check (public.validate_amount_atomic(amount_atomic)),
  amount_decimals smallint not null check (amount_decimals between 0 and 18),
  note text null,
  created_at timestamptz not null default now()
);
