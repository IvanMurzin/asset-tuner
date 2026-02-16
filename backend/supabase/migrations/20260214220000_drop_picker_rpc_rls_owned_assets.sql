-- Drop picker RPC (replaced by Edge Function get_assets_for_picker).
drop function if exists public.list_assets_for_picker(text);

-- RLS: allow reading assets and their rates if visible by plan rank OR user has a subaccount with that asset (so totals/balance work).
create or replace function public.asset_selectable_by_current_user(p_asset_id uuid)
returns boolean
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
begin
  if p_asset_id is null then
    return false;
  end if;
  if public.asset_visible_by_id_for_current_user(p_asset_id) then
    return true;
  end if;
  return exists (
    select 1
    from public.subaccounts s
    where s.asset_id = p_asset_id
      and s.user_id = auth.uid()
  );
end;
$$;

revoke all on function public.asset_selectable_by_current_user(uuid) from public;
grant execute on function public.asset_selectable_by_current_user(uuid) to anon, authenticated, service_role;

drop policy if exists assets_select_public on public.assets;
create policy assets_select_public
on public.assets
for select
to anon, authenticated
using (public.asset_selectable_by_current_user(id));

drop policy if exists asset_rates_usd_select_public on public.asset_rates_usd;
create policy asset_rates_usd_select_public
on public.asset_rates_usd
for select
to anon, authenticated
using (public.asset_selectable_by_current_user(asset_id));
