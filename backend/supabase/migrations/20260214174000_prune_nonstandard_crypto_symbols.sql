-- Remove non-standard crypto symbols (e.g. with underscores) from top cache/catalog.

delete from public.cg_top_coins
where symbol_upper !~ '^[A-Z0-9]{2,10}$';

do $$
begin
  delete from public.asset_rates_usd ar
  using public.assets a
  where ar.asset_id = a.id
    and a.kind = 'crypto'
    and a.code !~ '^[A-Z0-9]{2,10}$'
    and not exists (select 1 from public.subaccounts s where s.asset_id = a.id);

  delete from public.assets a
  where a.kind = 'crypto'
    and a.code !~ '^[A-Z0-9]{2,10}$'
    and not exists (select 1 from public.subaccounts s where s.asset_id = a.id);
end $$;
