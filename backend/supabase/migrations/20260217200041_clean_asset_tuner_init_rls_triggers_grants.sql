create trigger trg_asset_rates_usd_set_updated_at
before update on public.asset_rates_usd
for each row execute function public.set_updated_at();
