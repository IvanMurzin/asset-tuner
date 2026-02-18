create trigger trg_assets_set_updated_at
before update on public.assets
for each row execute function public.set_updated_at();
