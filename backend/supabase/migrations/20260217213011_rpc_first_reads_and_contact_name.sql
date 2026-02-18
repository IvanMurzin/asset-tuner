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
