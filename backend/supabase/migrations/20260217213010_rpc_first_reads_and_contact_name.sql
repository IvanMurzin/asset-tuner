create or replace function public.api_list_assets(
  p_user_id uuid,
  p_kind text default null,
  p_limit int default 100
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

if v_limit < 1 or v_limit > 100 then
    raise exception 'VALIDATION_ERROR: limit must be in range 1..100';

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
        'is_locked', x.is_locked,
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
        case
          when v_profile.plan = 'pro' then false
          when a.kind = 'fiat' then
            case
              when v_limits.fiat_limit is null then false
              else a.rank > v_limits.fiat_limit
            end
          when a.kind = 'crypto' then
            case
              when v_limits.crypto_limit is null then false
              else a.rank > v_limits.crypto_limit
            end
          else true
        end as is_locked,
        r.asset_id,
        r.usd_price_atomic,
        r.usd_price_decimals,
        r.as_of
      from public.assets a
      left join public.asset_rates_usd r on r.asset_id = a.id
      where a.is_active = true
        and (v_kind is null or a.kind = v_kind)
      order by a.kind asc, a.rank asc
      limit v_limit
    ) x
  ), '[]'::jsonb);

end;

$$;
