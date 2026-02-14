-- Enforce target model:
-- - free: 10 fiat + 10 crypto
-- - paid: 100 fiat + 100 crypto
-- - robust rankings with fiat fallback beyond fiat_priority
-- - RLS enabled on all tables in public schema

insert into public.plan_limits (plan, fiat_limit, crypto_limit, allow_all)
values
  ('free', 10, 10, false),
  ('paid', 100, 100, false)
on conflict (plan) do update
set
  fiat_limit = excluded.fiat_limit,
  crypto_limit = excluded.crypto_limit,
  allow_all = excluded.allow_all;

-- Ranking view with fiat fallback:
-- priority list first, then alphabetical fallback to fill up to paid limits.
create or replace view public.asset_rankings as
with
  fiat_max_rank as (
    select coalesce(max(fp.rank), 0) as max_rank
    from public.fiat_priority fp
  ),
  fiat_ranked_priority as (
    select
      a.id as asset_id,
      a.kind,
      a.code,
      a.provider_ref,
      fp.rank::int as rank
    from public.assets a
    join public.fiat_priority fp
      on fp.code = a.code
    where a.kind = 'fiat'
  ),
  fiat_ranked_fallback as (
    select
      a.id as asset_id,
      a.kind,
      a.code,
      a.provider_ref,
      (fmr.max_rank + row_number() over (order by a.code asc))::int as rank
    from public.assets a
    cross join fiat_max_rank fmr
    where a.kind = 'fiat'
      and not exists (
        select 1
        from public.fiat_priority fp
        where fp.code = a.code
      )
  ),
  crypto_ranked as (
    select
      a.id as asset_id,
      a.kind,
      a.code,
      a.provider_ref,
      coalesce(
        cgt.rank,
        case a.code
          when 'BTC' then 1
          when 'ETH' then 2
          when 'USDT' then 3
          when 'BNB' then 4
          when 'SOL' then 5
          when 'XRP' then 6
          when 'USDC' then 7
          when 'ADA' then 8
          when 'DOGE' then 9
          when 'TRX' then 10
          else 999999
        end
      )::int as rank
    from public.assets a
    left join public.cg_top_coins cgt
      on cgt.coingecko_id = a.provider_ref
    where a.kind = 'crypto'
  )
select * from fiat_ranked_priority
union all
select * from fiat_ranked_fallback
union all
select * from crypto_ranked;

-- Canonical RLS enablement.
alter table public.profiles enable row level security;
alter table public.accounts enable row level security;
alter table public.assets enable row level security;
alter table public.subaccounts enable row level security;
alter table public.balance_entries enable row level security;
alter table public.asset_rates_usd enable row level security;
alter table public.fx_rates_usd enable row level security;
alter table public.cg_coins_cache enable row level security;
alter table public.cg_top_coins enable row level security;
alter table public.crypto_rates_usd enable row level security;
alter table public.plan_limits enable row level security;
alter table public.fiat_priority enable row level security;

-- Ensure internal/provider tables are not exposed to anon/authenticated roles.
revoke all on table public.fx_rates_usd from anon, authenticated;
revoke all on table public.cg_coins_cache from anon, authenticated;
revoke all on table public.cg_top_coins from anon, authenticated;
revoke all on table public.crypto_rates_usd from anon, authenticated;
revoke all on table public.plan_limits from anon, authenticated;
revoke all on table public.fiat_priority from anon, authenticated;

-- Keep client-facing read grants on existing API tables.
grant select on table public.assets to anon, authenticated;
grant select on table public.asset_rates_usd to anon, authenticated;

-- Recreate canonical read policies for assets/rates.
do $$
declare
  rec record;
begin
  for rec in
    select policyname
    from pg_policies
    where schemaname = 'public'
      and tablename = 'assets'
      and cmd = 'SELECT'
  loop
    execute format('drop policy if exists %I on public.assets', rec.policyname);
  end loop;

  for rec in
    select policyname
    from pg_policies
    where schemaname = 'public'
      and tablename = 'asset_rates_usd'
      and cmd = 'SELECT'
  loop
    execute format('drop policy if exists %I on public.asset_rates_usd', rec.policyname);
  end loop;
end $$;

create policy assets_select_public
on public.assets
for select
to anon, authenticated
using (public.asset_visible_for_current_user(kind, code, provider_ref));

create policy asset_rates_usd_select_public
on public.asset_rates_usd
for select
to anon, authenticated
using (public.asset_visible_by_id_for_current_user(asset_id));

-- Keep only top paid window (100/100) for unreferenced catalog items.
-- This removes old garbage rows after previous wider imports.
delete from public.cg_top_coins
where rank > 100;

do $$
declare
  v_paid_fiat_limit int := coalesce((select fiat_limit from public.plan_limits where plan = 'paid'), 100);
  v_paid_crypto_limit int := coalesce((select crypto_limit from public.plan_limits where plan = 'paid'), 100);
begin
  delete from public.asset_rates_usd ar
  using public.assets a, public.asset_rankings rk
  where ar.asset_id = a.id
    and rk.asset_id = a.id
    and (
      (a.kind = 'fiat' and rk.rank > v_paid_fiat_limit)
      or
      (a.kind = 'crypto' and rk.rank > v_paid_crypto_limit)
    )
    and not exists (select 1 from public.subaccounts s where s.asset_id = a.id);

  delete from public.assets a
  using public.asset_rankings rk
  where rk.asset_id = a.id
    and (
      (a.kind = 'fiat' and rk.rank > v_paid_fiat_limit)
      or
      (a.kind = 'crypto' and rk.rank > v_paid_crypto_limit)
    )
    and not exists (select 1 from public.subaccounts s where s.asset_id = a.id);
end $$;
