-- Rates & Coverage Expansion: provider-layer tables, ranking helpers, and assets mapping.

create table if not exists public.fx_rates_usd (
  code text primary key check (code = upper(code)),
  usd_price numeric not null check (usd_price > 0),
  as_of timestamptz not null,
  source text not null default 'openexchangerates'
);

create index if not exists idx_fx_rates_usd_as_of on public.fx_rates_usd(as_of desc);

create table if not exists public.cg_coins_cache (
  coingecko_id text primary key,
  symbol text not null,
  symbol_upper text not null check (symbol_upper = upper(symbol_upper)),
  name text null,
  updated_at timestamptz not null
);

create index if not exists idx_cg_coins_cache_symbol_upper on public.cg_coins_cache(symbol_upper);

create table if not exists public.cg_top_coins (
  coingecko_id text primary key,
  symbol_upper text not null check (symbol_upper = upper(symbol_upper)),
  name text null,
  rank int not null check (rank > 0),
  market_cap numeric null,
  updated_at timestamptz not null
);

create index if not exists idx_cg_top_coins_rank on public.cg_top_coins(rank);

create table if not exists public.crypto_rates_usd (
  coingecko_id text primary key,
  usd_price numeric not null check (usd_price > 0),
  as_of timestamptz not null,
  source text not null default 'coingecko'
);

create index if not exists idx_crypto_rates_usd_as_of on public.crypto_rates_usd(as_of desc);

alter table public.assets
  add column if not exists provider_ref text null;

create index if not exists idx_assets_provider_ref on public.assets(provider_ref);

create unique index if not exists uq_assets_provider_ref_crypto
  on public.assets(provider_ref)
  where kind = 'crypto' and provider_ref is not null;

alter table public.assets
  drop constraint if exists chk_assets_crypto_provider_ref_required;

alter table public.assets
  add constraint chk_assets_crypto_provider_ref_required
  check (kind <> 'crypto' or provider_ref is not null) not valid;

update public.assets
set provider_ref = case code
  when 'BTC' then 'bitcoin'
  when 'ETH' then 'ethereum'
  when 'USDT' then 'tether'
  when 'SOL' then 'solana'
  else provider_ref
end
where kind = 'crypto'
  and provider_ref is null
  and code in ('BTC', 'ETH', 'USDT', 'SOL');

create table if not exists public.plan_limits (
  plan text primary key check (plan in ('free', 'paid')),
  fiat_limit int not null check (fiat_limit >= 0),
  crypto_limit int not null check (crypto_limit >= 0),
  allow_all boolean not null default false
);

insert into public.plan_limits (plan, fiat_limit, crypto_limit, allow_all)
values
  ('free', 10, 10, false),
  ('paid', 100, 100, true)
on conflict (plan) do update
set
  fiat_limit = excluded.fiat_limit,
  crypto_limit = excluded.crypto_limit,
  allow_all = excluded.allow_all;

create table if not exists public.fiat_priority (
  code text primary key check (code = upper(code)),
  rank int not null check (rank > 0)
);

insert into public.fiat_priority (code, rank)
values
  ('USD', 1),
  ('EUR', 2),
  ('GBP', 3),
  ('CHF', 4),
  ('RUB', 5),
  ('AED', 6),
  ('JPY', 7),
  ('CNY', 8),
  ('TRY', 9),
  ('PLN', 10)
on conflict (code) do update
set rank = excluded.rank;

create or replace view public.asset_rankings as
select
  a.id as asset_id,
  a.kind,
  a.code,
  a.provider_ref,
  case
    when a.kind = 'fiat' then coalesce(fp.rank, 999999)
    when a.kind = 'crypto' then coalesce(
      cgt.rank,
      case a.code
        when 'BTC' then 1
        when 'ETH' then 2
        when 'USDT' then 3
        when 'SOL' then 4
        else 999999
      end
    )
    else 999999
  end as rank
from public.assets a
left join public.fiat_priority fp
  on fp.code = a.code
left join public.cg_top_coins cgt
  on cgt.coingecko_id = a.provider_ref;

grant all on table public.fx_rates_usd to service_role;
grant all on table public.cg_coins_cache to service_role;
grant all on table public.cg_top_coins to service_role;
grant all on table public.crypto_rates_usd to service_role;
grant all on table public.plan_limits to service_role;
grant all on table public.fiat_priority to service_role;
