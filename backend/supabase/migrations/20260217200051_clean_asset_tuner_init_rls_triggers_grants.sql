create trigger trg_balance_entries_after_insert
after insert on public.balance_entries
for each row execute function public.handle_balance_entry_insert();
