create table if not exists public.asset_rates_usd (
  asset_id uuid primary key references public.assets(id) on delete cascade,
  usd_price_atomic text not null check (public.validate_amount_atomic(usd_price_atomic)),
  usd_price_decimals smallint not null check (usd_price_decimals between 0 and 18),
  as_of timestamptz not null,
  updated_at timestamptz not null default now()
);
