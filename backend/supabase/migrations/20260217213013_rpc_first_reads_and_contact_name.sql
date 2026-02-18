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
