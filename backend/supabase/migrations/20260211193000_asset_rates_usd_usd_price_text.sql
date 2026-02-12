-- Keep asset_rates_usd.usd_price as text decimal string for v2 contracts.
-- This migration is idempotent and safe for local resets.

do $$
begin
  if to_regclass('public.asset_rates_usd') is null then
    return;
  end if;

  alter table public.asset_rates_usd
    drop constraint if exists asset_rates_usd_usd_price_check,
    drop constraint if exists chk_asset_rates_usd_usd_price_numeric_positive,
    drop constraint if exists chk_asset_rates_usd_usd_price_text_positive;

  alter table public.asset_rates_usd
    alter column usd_price type text using (usd_price::text);

  alter table public.asset_rates_usd
    add constraint chk_asset_rates_usd_usd_price_text_positive check (
      usd_price ~ '^[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$'
      and usd_price::numeric > 0
    );
end $$;
