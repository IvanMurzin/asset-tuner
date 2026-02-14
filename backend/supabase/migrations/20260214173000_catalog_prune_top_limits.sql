-- Re-prune catalog/rates to paid limits (top lists) for already populated DBs.

insert into public.plan_limits (plan, fiat_limit, crypto_limit, allow_all)
values
  ('free', 10, 10, false),
  ('paid', 100, 100, false)
on conflict (plan) do update
set
  fiat_limit = excluded.fiat_limit,
  crypto_limit = excluded.crypto_limit,
  allow_all = excluded.allow_all;

delete from public.cg_top_coins
where rank > coalesce((select crypto_limit from public.plan_limits where plan = 'paid'), 100);

do $$
declare
  v_paid_fiat_limit int := coalesce((select fiat_limit from public.plan_limits where plan = 'paid'), 100);
  v_paid_crypto_limit int := coalesce((select crypto_limit from public.plan_limits where plan = 'paid'), 100);
begin
  delete from public.asset_rates_usd ar
  using public.assets a
  where ar.asset_id = a.id
    and a.kind = 'fiat'
    and not exists (
      select 1
      from public.fiat_priority fp
      where fp.code = a.code
        and fp.rank <= v_paid_fiat_limit
    )
    and not exists (
      select 1 from public.subaccounts s where s.asset_id = a.id
    );

  delete from public.asset_rates_usd ar
  using public.assets a
  where ar.asset_id = a.id
    and a.kind = 'crypto'
    and not exists (
      select 1
      from public.cg_top_coins c
      where c.coingecko_id = a.provider_ref
        and c.rank <= v_paid_crypto_limit
    )
    and a.code not in ('BTC', 'ETH', 'USDT', 'BNB', 'SOL', 'XRP', 'USDC', 'ADA', 'DOGE', 'TRX')
    and not exists (
      select 1 from public.subaccounts s where s.asset_id = a.id
    );

  delete from public.assets a
  where a.kind = 'fiat'
    and not exists (
      select 1
      from public.fiat_priority fp
      where fp.code = a.code
        and fp.rank <= v_paid_fiat_limit
    )
    and not exists (
      select 1 from public.subaccounts s where s.asset_id = a.id
    );

  delete from public.assets a
  where a.kind = 'crypto'
    and not exists (
      select 1
      from public.cg_top_coins c
      where c.coingecko_id = a.provider_ref
        and c.rank <= v_paid_crypto_limit
    )
    and a.code not in ('BTC', 'ETH', 'USDT', 'BNB', 'SOL', 'XRP', 'USDC', 'ADA', 'DOGE', 'TRX')
    and not exists (
      select 1 from public.subaccounts s where s.asset_id = a.id
    );
end $$;
