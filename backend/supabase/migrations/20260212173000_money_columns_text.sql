do $$
begin
  if to_regclass('public.balance_entries') is not null then
    alter table public.balance_entries
      drop constraint if exists chk_balance_entries_snapshot_amount_text_decimal,
      drop constraint if exists chk_balance_entries_diff_amount_text_decimal;

    alter table public.balance_entries
      alter column snapshot_amount type text using (snapshot_amount::text),
      alter column diff_amount type text using (diff_amount::text);

    alter table public.balance_entries
      add constraint chk_balance_entries_snapshot_amount_text_decimal check (
        snapshot_amount ~ '^-?[0-9]+(\.[0-9]+)?$'
      ),
      add constraint chk_balance_entries_diff_amount_text_decimal check (
        diff_amount is null or diff_amount ~ '^-?[0-9]+(\.[0-9]+)?$'
      );
  end if;

  if to_regclass('public.asset_rates_usd') is not null then
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
  end if;
end $$;
