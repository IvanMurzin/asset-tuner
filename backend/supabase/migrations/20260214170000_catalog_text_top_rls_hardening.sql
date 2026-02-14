-- Hardening pass:
-- 1) Money-like provider columns use text decimal strings.
-- 2) Catalog limits/top lists are enforced (no paid allow_all by default).
-- 3) RLS policies for assets/rates are recreated defensively.
-- 4) Existing non-top catalog rows are pruned when they are not referenced.

-- -------------------------------------------------------------------
-- Provider money fields -> text decimal string
-- -------------------------------------------------------------------
do $$
begin
  if to_regclass('public.fx_rates_usd') is not null then
    alter table public.fx_rates_usd
      drop constraint if exists fx_rates_usd_usd_price_check,
      drop constraint if exists chk_fx_rates_usd_usd_price_text_positive;

    alter table public.fx_rates_usd
      alter column usd_price type text using (usd_price::text);

    alter table public.fx_rates_usd
      add constraint chk_fx_rates_usd_usd_price_text_positive check (
        usd_price ~ '^[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$'
        and usd_price::numeric > 0
      );
  end if;

  if to_regclass('public.crypto_rates_usd') is not null then
    alter table public.crypto_rates_usd
      drop constraint if exists crypto_rates_usd_usd_price_check,
      drop constraint if exists chk_crypto_rates_usd_usd_price_text_positive;

    alter table public.crypto_rates_usd
      alter column usd_price type text using (usd_price::text);

    alter table public.crypto_rates_usd
      add constraint chk_crypto_rates_usd_usd_price_text_positive check (
        usd_price ~ '^[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$'
        and usd_price::numeric > 0
      );
  end if;

  if to_regclass('public.cg_top_coins') is not null then
    alter table public.cg_top_coins
      drop constraint if exists chk_cg_top_coins_market_cap_text_positive;

    alter table public.cg_top_coins
      alter column market_cap type text using (market_cap::text);

    alter table public.cg_top_coins
      add constraint chk_cg_top_coins_market_cap_text_positive check (
        market_cap is null or (
          market_cap ~ '^[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$'
          and market_cap::numeric > 0
        )
      );
  end if;
end $$;

-- -------------------------------------------------------------------
-- Plan defaults and top fiat list
-- -------------------------------------------------------------------
insert into public.plan_limits (plan, fiat_limit, crypto_limit, allow_all)
values
  ('free', 10, 10, false),
  ('paid', 100, 100, false)
on conflict (plan) do update
set
  fiat_limit = excluded.fiat_limit,
  crypto_limit = excluded.crypto_limit,
  allow_all = excluded.allow_all;

-- Keep fiat ordering explicit and deterministic.
insert into public.fiat_priority (code, rank)
values
  ('USD', 1),
  ('EUR', 2),
  ('GBP', 3),
  ('JPY', 4),
  ('CHF', 5),
  ('CAD', 6),
  ('AUD', 7),
  ('CNY', 8),
  ('HKD', 9),
  ('SGD', 10),
  ('RUB', 11),
  ('AED', 12),
  ('TRY', 13),
  ('PLN', 14),
  ('SEK', 15),
  ('NOK', 16),
  ('DKK', 17),
  ('CZK', 18),
  ('HUF', 19),
  ('RON', 20),
  ('BRL', 21),
  ('MXN', 22),
  ('INR', 23),
  ('IDR', 24),
  ('KRW', 25),
  ('THB', 26),
  ('MYR', 27),
  ('PHP', 28),
  ('ZAR', 29),
  ('ILS', 30)
on conflict (code) do update
set rank = excluded.rank;

-- -------------------------------------------------------------------
-- Recreate ranking view
-- -------------------------------------------------------------------
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
        when 'BNB' then 4
        when 'SOL' then 5
        when 'XRP' then 6
        when 'USDC' then 7
        when 'ADA' then 8
        when 'DOGE' then 9
        when 'TRX' then 10
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

-- -------------------------------------------------------------------
-- Defensive RLS recreation (drop all select policies, create canonical)
-- -------------------------------------------------------------------
alter table public.assets enable row level security;
alter table public.asset_rates_usd enable row level security;

do $$
declare
  rec record;
begin
  for rec in
    select policyname
    from pg_policies
    where schemaname = 'public'
      and tablename = 'assets'
      and cmd = 'SELECT'
  loop
    execute format('drop policy if exists %I on public.assets', rec.policyname);
  end loop;

  for rec in
    select policyname
    from pg_policies
    where schemaname = 'public'
      and tablename = 'asset_rates_usd'
      and cmd = 'SELECT'
  loop
    execute format('drop policy if exists %I on public.asset_rates_usd', rec.policyname);
  end loop;
end $$;

create policy assets_select_public
on public.assets
for select
to anon, authenticated
using (public.asset_visible_for_current_user(kind, code, provider_ref));

create policy asset_rates_usd_select_public
on public.asset_rates_usd
for select
to anon, authenticated
using (public.asset_visible_by_id_for_current_user(asset_id));

-- -------------------------------------------------------------------
-- Cleanup pass: remove non-top catalog rows when they are not referenced.
-- This avoids FK errors for already used assets.
-- -------------------------------------------------------------------
do $$
declare
  v_paid_fiat_limit int := coalesce((select fiat_limit from public.plan_limits where plan = 'paid'), 100);
  v_paid_crypto_limit int := coalesce((select crypto_limit from public.plan_limits where plan = 'paid'), 100);
begin
  -- rates first
  delete from public.asset_rates_usd ar
  using public.assets a
  where ar.asset_id = a.id
    and a.kind = 'fiat'
    and not exists (
      select 1
      from public.fiat_priority fp
      where fp.code = a.code
        and fp.rank <= v_paid_fiat_limit
    )
    and not exists (
      select 1 from public.subaccounts s where s.asset_id = a.id
    );

  delete from public.asset_rates_usd ar
  using public.assets a
  where ar.asset_id = a.id
    and a.kind = 'crypto'
    and not exists (
      select 1
      from public.cg_top_coins c
      where c.coingecko_id = a.provider_ref
        and c.rank <= v_paid_crypto_limit
    )
    and a.code not in ('BTC', 'ETH', 'USDT', 'BNB', 'SOL', 'XRP', 'USDC', 'ADA', 'DOGE', 'TRX')
    and not exists (
      select 1 from public.subaccounts s where s.asset_id = a.id
    );

  -- assets next
  delete from public.assets a
  where a.kind = 'fiat'
    and not exists (
      select 1
      from public.fiat_priority fp
      where fp.code = a.code
        and fp.rank <= v_paid_fiat_limit
    )
    and not exists (
      select 1 from public.subaccounts s where s.asset_id = a.id
    );

  delete from public.assets a
  where a.kind = 'crypto'
    and not exists (
      select 1
      from public.cg_top_coins c
      where c.coingecko_id = a.provider_ref
        and c.rank <= v_paid_crypto_limit
    )
    and a.code not in ('BTC', 'ETH', 'USDT', 'BNB', 'SOL', 'XRP', 'USDC', 'ADA', 'DOGE', 'TRX')
    and not exists (
      select 1 from public.subaccounts s where s.asset_id = a.id
    );
end $$;
