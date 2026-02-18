create trigger trg_subaccounts_set_updated_at
before update on public.subaccounts
for each row execute function public.set_updated_at();
