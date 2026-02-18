create index if not exists idx_balance_entries_subaccount_created_desc
  on public.balance_entries(subaccount_id, created_at desc);
