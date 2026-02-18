create or replace function public.api_profile_update_base_asset(
  p_user_id uuid,
  p_base_asset_id uuid
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_profile public.profiles;
  v_limits public.plan_limits;
  v_asset public.assets;
begin
  select *
  into v_profile
  from public.profiles
  where user_id = p_user_id;

  if not found then
    raise exception 'NOT_FOUND: profile not found';
  end if;

  select * into v_limits from public.plan_limits where plan = v_profile.plan;
  if not found then
    raise exception 'INTERNAL_ERROR: plan limits not configured';
  end if;

  select * into v_asset from public.assets where id = p_base_asset_id and is_active = true;
  if not found then
    raise exception 'NOT_FOUND: base asset not found';
  end if;

  if v_profile.plan = 'free' then
    if v_asset.kind <> 'fiat' then
      raise exception 'ASSET_NOT_ALLOWED_FOR_PLAN: free plan allows only fiat base asset';
    end if;
    if v_limits.fiat_limit is not null and v_asset.rank > v_limits.fiat_limit then
      raise exception 'ASSET_NOT_ALLOWED_FOR_PLAN: base asset rank exceeds free limit';
    end if;
  end if;

  update public.profiles
  set base_asset_id = p_base_asset_id,
      updated_at = now()
  where user_id = p_user_id
  returning * into v_profile;

  return v_profile;
end;
$func$;
