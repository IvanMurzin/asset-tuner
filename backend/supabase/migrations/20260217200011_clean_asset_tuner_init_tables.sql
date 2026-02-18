create table if not exists public.plan_limits (
  plan text primary key check (plan in ('free', 'pro')),
  max_accounts int null,
  max_subaccounts int null,
  fiat_limit int null,
  crypto_limit int null
);
