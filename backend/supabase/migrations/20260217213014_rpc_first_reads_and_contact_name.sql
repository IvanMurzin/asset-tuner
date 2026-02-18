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
