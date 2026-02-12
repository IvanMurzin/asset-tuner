-- Store usd_price as text (string) to avoid numeric JSON precision issues on clients.
-- This migration is resilient to manual table drops (recreates table + policies if missing).

create table if not exists public.asset_rates_usd (
  asset_id uuid primary key references public.assets(id) on delete cascade,
  usd_price text not null,
  as_of timestamptz not null
);

create index if not exists idx_asset_rates_usd_as_of on public.asset_rates_usd(as_of desc);

do $$
declare
  coltype text;
begin
  if to_regclass('public.asset_rates_usd') is null then
    return;
  end if;

  select c.data_type into coltype
  from information_schema.columns c
  where c.table_schema = 'public'
    and c.table_name = 'asset_rates_usd'
    and c.column_name = 'usd_price';

  alter table public.asset_rates_usd
    drop constraint if exists asset_rates_usd_usd_price_check,
    drop constraint if exists chk_asset_rates_usd_usd_price_numeric_positive;

  if coltype is distinct from 'text' then
    alter table public.asset_rates_usd
      alter column usd_price type text using usd_price::text;
  end if;

  alter table public.asset_rates_usd
    add constraint chk_asset_rates_usd_usd_price_numeric_positive check ((usd_price)::numeric > 0);
end $$;

alter table public.asset_rates_usd enable row level security;

drop policy if exists asset_rates_usd_select_public on public.asset_rates_usd;
create policy asset_rates_usd_select_public
on public.asset_rates_usd
for select
to anon, authenticated
using (true);

-- Grants (PostgREST uses table privileges + RLS policies)
revoke all on table public.asset_rates_usd from anon, authenticated;
grant select on table public.asset_rates_usd to anon, authenticated;
grant all on table public.asset_rates_usd to service_role;

