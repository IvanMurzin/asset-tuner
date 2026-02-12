-- Minimal seed data for local/dev usage.
-- For production, prefer running rates sync and expanding the asset catalog.

insert into public.assets (kind, code, name, decimals)
values
  ('fiat', 'USD', 'US Dollar', 2),
  ('fiat', 'EUR', 'Euro', 2),
  ('fiat', 'RUB', 'Russian Ruble', 2),
  ('fiat', 'GBP', 'British Pound', 2),
  ('fiat', 'CHF', 'Swiss Franc', 2),
  ('crypto', 'BTC', 'Bitcoin', 8),
  ('crypto', 'ETH', 'Ethereum', 18),
  ('crypto', 'USDT', 'Tether', 6),
  ('crypto', 'SOL', 'Solana', 9)
on conflict (kind, code) do update
set
  name = excluded.name,
  decimals = excluded.decimals;

-- Seed a tiny rates snapshot (so the app can render conversions before the first sync).
-- These values are placeholders; `rates_sync` will overwrite them.
insert into public.asset_rates_usd (asset_id, usd_price, as_of)
select a.id,
  case
    when a.kind = 'fiat' and a.code = 'USD' then 1
    when a.kind = 'fiat' and a.code = 'EUR' then 1.08
    when a.kind = 'fiat' and a.code = 'RUB' then 0.011
    when a.kind = 'fiat' and a.code = 'GBP' then 1.27
    when a.kind = 'fiat' and a.code = 'CHF' then 1.10
    when a.kind = 'crypto' and a.code = 'BTC' then 45000
    when a.kind = 'crypto' and a.code = 'ETH' then 2500
    when a.kind = 'crypto' and a.code = 'USDT' then 1
    when a.kind = 'crypto' and a.code = 'SOL' then 100
    else null
  end as usd_price,
  now() as as_of
from public.assets a
where (a.kind, a.code) in (
  ('fiat', 'USD'),
  ('fiat', 'EUR'),
  ('fiat', 'RUB'),
  ('fiat', 'GBP'),
  ('fiat', 'CHF'),
  ('crypto', 'BTC'),
  ('crypto', 'ETH'),
  ('crypto', 'USDT'),
  ('crypto', 'SOL')
)
and (
  (a.kind = 'fiat')
  or
  (a.kind = 'crypto')
)
and
  case
    when a.kind = 'fiat' and a.code = 'USD' then true
    when a.kind = 'fiat' and a.code = 'EUR' then true
    when a.kind = 'fiat' and a.code = 'RUB' then true
    when a.kind = 'fiat' and a.code = 'GBP' then true
    when a.kind = 'fiat' and a.code = 'CHF' then true
    when a.kind = 'crypto' and a.code = 'BTC' then true
    when a.kind = 'crypto' and a.code = 'ETH' then true
    when a.kind = 'crypto' and a.code = 'USDT' then true
    when a.kind = 'crypto' and a.code = 'SOL' then true
    else false
  end
on conflict (asset_id) do update
set
  usd_price = excluded.usd_price,
  as_of = excluded.as_of
where excluded.usd_price is not null;
