-- Keep asset_rates_usd.usd_price as numeric for v2 contracts.
-- This migration is idempotent and safe for local resets.

do $$
begin
  if to_regclass('public.asset_rates_usd') is null then
    return;
  end if;

  alter table public.asset_rates_usd
    drop constraint if exists asset_rates_usd_usd_price_check,
    drop constraint if exists chk_asset_rates_usd_usd_price_numeric_positive;

  alter table public.asset_rates_usd
    alter column usd_price type numeric using (usd_price::numeric);

  alter table public.asset_rates_usd
    add constraint chk_asset_rates_usd_usd_price_numeric_positive check (usd_price > 0);
end $$;
