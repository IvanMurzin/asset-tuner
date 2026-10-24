-- QA-030 / SPEC-0021: a new profile starts with USD as its base asset. The default lives on the
-- column, so every insert path (auth trigger, api_ensure_profile) gets it.
create or replace function public.default_base_asset_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $sql$
  select a.id
  from public.assets a
  where a.kind = 'fiat'
    and a.code = 'USD'
    and a.is_active
  limit 1;
$sql$;

revoke all on function public.default_base_asset_id() from public, anon, authenticated;
grant execute on function public.default_base_asset_id() to service_role;

alter table public.profiles
  alter column base_asset_id set default public.default_base_asset_id();

update public.profiles
set base_asset_id = public.default_base_asset_id(),
    updated_at = now()
where base_asset_id is null;
