begin;

alter table public.support_messages
  add column if not exists name text;

update public.support_messages
set name = 'Unknown'
where name is null;

alter table public.support_messages
  alter column name set not null;

alter table public.support_messages
  drop constraint if exists chk_support_messages_name_nonempty;

alter table public.support_messages
  add constraint chk_support_messages_name_nonempty
  check (length(trim(name)) > 0);

drop function if exists public.api_create_support_message(uuid, text, text, text, jsonb);

create or replace function public.api_create_support_message(
  p_user_id uuid,
  p_name text,
  p_email text,
  p_subject text,
  p_message text,
  p_meta jsonb default '{}'::jsonb,
  p_max_per_hour int default 5
)
returns public.support_messages
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.support_messages;
  v_recent_count int;
  v_subject text;
begin
  if p_name is null or length(trim(p_name)) = 0 then
    raise exception 'VALIDATION_ERROR: name is required';
  end if;
  if p_message is null or length(trim(p_message)) = 0 then
    raise exception 'VALIDATION_ERROR: message is required';
  end if;
  if p_max_per_hour is null or p_max_per_hour < 1 then
    raise exception 'VALIDATION_ERROR: p_max_per_hour must be >= 1';
  end if;

  select count(*)
  into v_recent_count
  from public.support_messages s
  where s.user_id = p_user_id
    and s.created_at >= now() - interval '1 hour';

  if v_recent_count >= p_max_per_hour then
    raise exception 'RATE_LIMITED: support message limit reached';
  end if;

  v_subject := coalesce(nullif(trim(p_subject), ''), 'Contact developer');

  insert into public.support_messages(
    user_id,
    name,
    email,
    subject,
    message,
    meta
  )
  values (
    p_user_id,
    trim(p_name),
    nullif(trim(p_email), ''),
    v_subject,
    trim(p_message),
    coalesce(p_meta, '{}'::jsonb)
  )
  returning * into v_row;

  return v_row;
end;
$$;

create or replace function public.api_ensure_profile(
  p_user_id uuid
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile public.profiles;
begin
  insert into public.profiles(user_id)
  values (p_user_id)
  on conflict (user_id) do nothing;

  select *
  into v_profile
  from public.profiles p
  where p.user_id = p_user_id;

  if not found then
    raise exception 'INTERNAL_ERROR: failed to ensure profile';
  end if;

  return v_profile;
end;
$$;

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

create or replace function public.api_list_assets(
  p_user_id uuid,
  p_kind text default null,
  p_limit int default 100,
  p_only_allowed boolean default true
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile public.profiles;
  v_limits public.plan_limits;
  v_kind text := nullif(trim(p_kind), '');
  v_limit int := coalesce(p_limit, 100);
begin
  if v_kind is not null and v_kind not in ('fiat', 'crypto') then
    raise exception 'VALIDATION_ERROR: kind must be fiat or crypto';
  end if;

  if v_limit < 1 or v_limit > 200 then
    raise exception 'VALIDATION_ERROR: limit must be in range 1..200';
  end if;

  v_profile := public.api_ensure_profile(p_user_id);

  select *
  into v_limits
  from public.plan_limits pl
  where pl.plan = v_profile.plan;

  if not found then
    raise exception 'INTERNAL_ERROR: plan limits not configured';
  end if;

  return coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'id', x.id,
        'kind', x.kind,
        'code', x.code,
        'name', x.name,
        'provider', x.provider,
        'provider_ref', x.provider_ref,
        'rank', x.rank,
        'decimals', x.decimals,
        'is_active', x.is_active,
        'usd_rate', case
          when x.asset_id is null then null
          else jsonb_build_object(
            'usd_price_atomic', x.usd_price_atomic,
            'usd_price_decimals', x.usd_price_decimals,
            'as_of', x.as_of
          )
        end
      )
      order by x.kind asc, x.rank asc
    )
    from (
      select
        a.id,
        a.kind,
        a.code,
        a.name,
        a.provider,
        a.provider_ref,
        a.rank,
        a.decimals,
        a.is_active,
        r.asset_id,
        r.usd_price_atomic,
        r.usd_price_decimals,
        r.as_of
      from public.assets a
      left join public.asset_rates_usd r on r.asset_id = a.id
      where a.is_active = true
        and (v_kind is null or a.kind = v_kind)
        and (
          not coalesce(p_only_allowed, true)
          or v_profile.plan = 'pro'
          or (
            a.kind = 'fiat'
            and (v_limits.fiat_limit is null or a.rank <= v_limits.fiat_limit)
          )
          or (
            a.kind = 'crypto'
            and (v_limits.crypto_limit is null or a.rank <= v_limits.crypto_limit)
          )
        )
      order by a.kind asc, a.rank asc
      limit v_limit
    ) x
  ), '[]'::jsonb);
end;
$$;

create or replace function public.api_get_rates_usd(
  p_asset_ids uuid[]
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_result jsonb;
begin
  if p_asset_ids is null or coalesce(array_length(p_asset_ids, 1), 0) = 0 then
    raise exception 'VALIDATION_ERROR: asset_ids is required';
  end if;

  select coalesce(
    jsonb_object_agg(
      r.asset_id::text,
      jsonb_build_object(
        'usd_price_atomic', r.usd_price_atomic,
        'usd_price_decimals', r.usd_price_decimals,
        'as_of', r.as_of
      )
    ),
    '{}'::jsonb
  )
  into v_result
  from public.asset_rates_usd r
  where r.asset_id = any(p_asset_ids);

  return v_result;
end;
$$;

create or replace function public.api_list_accounts(
  p_user_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_profile public.profiles;
  v_base_asset public.assets;
  v_base_rate public.asset_rates_usd;
begin
  v_profile := public.api_ensure_profile(p_user_id);

  if v_profile.base_asset_id is not null then
    select *
    into v_base_asset
    from public.assets a
    where a.id = v_profile.base_asset_id;

    if v_base_asset.id is not null then
      select *
      into v_base_rate
      from public.asset_rates_usd r
      where r.asset_id = v_base_asset.id;
    end if;
  end if;

  return coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'id', t.id,
        'name', t.name,
        'type', t.type,
        'archived', t.archived,
        'subaccounts_count', t.subaccounts_count,
        'totals', jsonb_build_object(
          'total_usd_atomic', public.numeric_to_atomic(t.total_usd_numeric, 12),
          'total_usd_decimals', 12,
          'total_in_base_atomic', case
            when v_base_asset.id is null then null
            when v_base_rate.asset_id is null then null
            when v_base_rate.usd_price_atomic = '0' then null
            else public.numeric_to_atomic(
              t.total_usd_numeric
              / public.atomic_to_numeric(v_base_rate.usd_price_atomic, v_base_rate.usd_price_decimals),
              v_base_asset.decimals
            )
          end,
          'total_in_base_decimals', case
            when v_base_asset.id is null then null
            else v_base_asset.decimals
          end,
          'base_asset_id', case
            when v_base_asset.id is null then null
            else v_base_asset.id
          end,
          'base_asset_code', case
            when v_base_asset.id is null then null
            else v_base_asset.code
          end
        ),
        'cache', jsonb_build_object(
          'cached_total_usd_atomic', t.cached_total_usd_atomic,
          'cached_total_usd_decimals', t.cached_total_usd_decimals,
          'cached_total_updated_at', t.cached_total_updated_at
        ),
        'created_at', t.created_at,
        'updated_at', t.updated_at
      )
      order by t.created_at desc
    )
    from (
      select
        a.id,
        a.name,
        a.type,
        a.archived,
        a.cached_total_usd_atomic,
        a.cached_total_usd_decimals,
        a.cached_total_updated_at,
        a.created_at,
        a.updated_at,
        count(s.id) filter (where not s.archived) as subaccounts_count,
        coalesce(
          sum(
            public.atomic_to_numeric(s.current_amount_atomic, s.current_amount_decimals)
            * coalesce(public.atomic_to_numeric(r.usd_price_atomic, r.usd_price_decimals), 0::numeric)
          ) filter (where not s.archived),
          0::numeric
        ) as total_usd_numeric
      from public.accounts a
      left join public.subaccounts s
        on s.account_id = a.id
       and s.user_id = p_user_id
      left join public.asset_rates_usd r
        on r.asset_id = s.asset_id
      where a.user_id = p_user_id
      group by a.id
      order by a.created_at desc
    ) t
  ), '[]'::jsonb);
end;
$$;

create or replace function public.api_list_subaccounts(
  p_user_id uuid,
  p_account_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  perform 1
  from public.accounts a
  where a.id = p_account_id
    and a.user_id = p_user_id;

  if not found then
    raise exception 'NOT_FOUND: account not found';
  end if;

  return coalesce((
    select jsonb_agg(
      jsonb_build_object(
        'id', s.id,
        'user_id', s.user_id,
        'account_id', s.account_id,
        'asset_id', s.asset_id,
        'name', s.name,
        'archived', s.archived,
        'current_amount_atomic', s.current_amount_atomic,
        'current_amount_decimals', s.current_amount_decimals,
        'created_at', s.created_at,
        'updated_at', s.updated_at,
        'asset', case
          when a.id is null then null
          else to_jsonb(a)
        end,
        'usd_rate', case
          when r.asset_id is null then null
          else jsonb_build_object(
            'asset_id', r.asset_id,
            'usd_price_atomic', r.usd_price_atomic,
            'usd_price_decimals', r.usd_price_decimals,
            'as_of', r.as_of
          )
        end
      )
      order by s.created_at desc
    )
    from public.subaccounts s
    left join public.assets a
      on a.id = s.asset_id
    left join public.asset_rates_usd r
      on r.asset_id = s.asset_id
    where s.user_id = p_user_id
      and s.account_id = p_account_id
  ), '[]'::jsonb);
end;
$$;

create or replace function public.api_subaccount_history(
  p_user_id uuid,
  p_subaccount_id uuid,
  p_cursor timestamptz default null,
  p_limit int default 50
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit int := coalesce(p_limit, 50);
  v_items jsonb;
  v_next_cursor timestamptz;
begin
  if v_limit < 1 or v_limit > 200 then
    raise exception 'VALIDATION_ERROR: limit must be in range 1..200';
  end if;

  perform 1
  from public.subaccounts s
  where s.id = p_subaccount_id
    and s.user_id = p_user_id;

  if not found then
    raise exception 'NOT_FOUND: subaccount not found';
  end if;

  with entries as (
    select
      b.id,
      b.user_id,
      b.subaccount_id,
      b.amount_atomic,
      b.amount_decimals,
      b.note,
      b.created_at
    from public.balance_entries b
    where b.user_id = p_user_id
      and b.subaccount_id = p_subaccount_id
      and (p_cursor is null or b.created_at < p_cursor)
    order by b.created_at desc
    limit v_limit
  ),
  stats as (
    select count(*) as cnt, min(created_at) as min_created_at
    from entries
  )
  select
    coalesce(jsonb_agg(to_jsonb(e) order by e.created_at desc), '[]'::jsonb),
    case when s.cnt = v_limit then s.min_created_at else null end
  into v_items, v_next_cursor
  from entries e
  cross join stats s;

  return jsonb_build_object(
    'items', coalesce(v_items, '[]'::jsonb),
    'nextCursor', v_next_cursor
  );
end;
$$;

revoke all on function public.api_create_support_message(uuid, text, text, text, text, jsonb, int) from public, anon, authenticated;
revoke all on function public.api_ensure_profile(uuid) from public, anon, authenticated;
revoke all on function public.api_get_me(uuid) from public, anon, authenticated;
revoke all on function public.api_list_assets(uuid, text, int, boolean) from public, anon, authenticated;
revoke all on function public.api_get_rates_usd(uuid[]) from public, anon, authenticated;
revoke all on function public.api_list_accounts(uuid) from public, anon, authenticated;
revoke all on function public.api_list_subaccounts(uuid, uuid) from public, anon, authenticated;
revoke all on function public.api_subaccount_history(uuid, uuid, timestamptz, int) from public, anon, authenticated;

grant execute on function public.api_create_support_message(uuid, text, text, text, text, jsonb, int) to service_role;
grant execute on function public.api_ensure_profile(uuid) to service_role;
grant execute on function public.api_get_me(uuid) to service_role;
grant execute on function public.api_list_assets(uuid, text, int, boolean) to service_role;
grant execute on function public.api_get_rates_usd(uuid[]) to service_role;
grant execute on function public.api_list_accounts(uuid) to service_role;
grant execute on function public.api_list_subaccounts(uuid, uuid) to service_role;
grant execute on function public.api_subaccount_history(uuid, uuid, timestamptz, int) to service_role;

commit;
