create trigger trg_accounts_set_updated_at
before update on public.accounts
for each row execute function public.set_updated_at();
