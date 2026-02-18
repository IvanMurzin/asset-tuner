create or replace function public.api_apply_revenuecat_event(
  p_source text,
  p_external_id text,
  p_app_user_id text,
  p_payload jsonb,
  p_is_pro boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_inserted_id uuid;
  v_user_id uuid;
  v_user_id_by_app uuid;
  v_target_user_id uuid;
  v_plan text;
  v_current_base_asset_id uuid;
  v_default_usd_asset_id uuid;
  v_should_reset_base boolean := false;
  v_free_limits public.plan_limits;
begin
  if p_source is null or length(trim(p_source)) = 0 then
    raise exception 'VALIDATION_ERROR: source is required';
  end if;
  if p_external_id is null or length(trim(p_external_id)) = 0 then
    raise exception 'VALIDATION_ERROR: external_id is required';
  end if;
  if p_app_user_id is null or length(trim(p_app_user_id)) = 0 then
    raise exception 'VALIDATION_ERROR: app_user_id is required';
  end if;

  insert into public.webhook_events(source, external_id, payload)
  values (trim(p_source), trim(p_external_id), coalesce(p_payload, '{}'::jsonb))
  on conflict (source, external_id) do nothing
  returning id into v_inserted_id;

  if v_inserted_id is null then
    return jsonb_build_object(
      'processed', false,
      'reason', 'duplicate'
    );
  end if;

  select p.user_id
  into v_user_id_by_app
  from public.profiles p
  where p.revenuecat_app_user_id = p_app_user_id
  limit 1;

  begin
    v_user_id := p_app_user_id::uuid;
  exception
    when invalid_text_representation then
      v_user_id := null;
  end;

  if v_user_id_by_app is not null then
    v_target_user_id := v_user_id_by_app;
  elsif v_user_id is not null and exists(select 1 from public.profiles where user_id = v_user_id) then
    v_target_user_id := v_user_id;
  else
    return jsonb_build_object(
      'processed', true,
      'updated', false,
      'reason', 'profile_not_found'
    );
  end if;

  v_plan := case when p_is_pro then 'pro' else 'free' end;

  select p.base_asset_id
  into v_current_base_asset_id
  from public.profiles p
  where p.user_id = v_target_user_id;

  if not found then
    return jsonb_build_object(
      'processed', true,
      'updated', false,
      'reason', 'profile_not_found'
    );
  end if;

  if not p_is_pro then
    select *
    into v_free_limits
    from public.plan_limits pl
    where pl.plan = 'free';

    if not found then
      raise exception 'INTERNAL_ERROR: plan limits not configured';
    end if;

    if v_current_base_asset_id is null then
      v_should_reset_base := true;
    else
      perform 1
      from public.assets a
      where a.id = v_current_base_asset_id
        and a.is_active = true
        and a.kind = 'fiat'
        and (v_free_limits.fiat_limit is null or a.rank <= v_free_limits.fiat_limit);

      if not found then
        v_should_reset_base := true;
      end if;
    end if;

    if v_should_reset_base then
      select a.id
      into v_default_usd_asset_id
      from public.assets a
      where a.kind = 'fiat'
        and a.code = 'USD'
        and a.is_active = true
      limit 1;

      if v_default_usd_asset_id is null then
        raise exception 'INTERNAL_ERROR: USD base asset is not configured';
      end if;
    end if;
  end if;

  update public.profiles p
  set
    plan = v_plan,
    revenuecat_app_user_id = p_app_user_id,
    base_asset_id = case
      when v_should_reset_base then v_default_usd_asset_id
      else p.base_asset_id
    end,
    updated_at = now()
  where p.user_id = v_target_user_id;

  return jsonb_build_object(
    'processed', true,
    'updated', true,
    'user_id', v_target_user_id,
    'plan', v_plan,
    'base_asset_reset', v_should_reset_base
  );
end;
$func$;
