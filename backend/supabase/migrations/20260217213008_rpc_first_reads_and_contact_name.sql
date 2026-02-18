create or replace function public.api_get_me(
  p_user_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile public.profiles;

v_limits public.plan_limits;

v_base_asset public.assets;

begin
  v_profile := public.api_ensure_profile(p_user_id);

select *
  into v_limits
  from public.plan_limits pl
  where pl.plan = v_profile.plan;

if not found then
    raise exception 'INTERNAL_ERROR: plan limits not configured';

end if;

if v_profile.base_asset_id is not null then
    select *
    into v_base_asset
    from public.assets a
    where a.id = v_profile.base_asset_id;

end if;

return jsonb_build_object(
    'profile', to_jsonb(v_profile),
    'limits', to_jsonb(v_limits),
    'baseAsset', case when v_base_asset.id is null then null else to_jsonb(v_base_asset) end
  );

end;

$$;
