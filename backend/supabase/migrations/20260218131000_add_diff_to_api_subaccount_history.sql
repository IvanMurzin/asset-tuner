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

  with raw as (
    select
      b.id,
      b.user_id,
      b.subaccount_id,
      b.amount_atomic,
      b.amount_decimals,
      b.note,
      b.created_at,
      public.atomic_to_numeric(b.amount_atomic, b.amount_decimals) as snapshot_amount
    from public.balance_entries b
    where b.user_id = p_user_id
      and b.subaccount_id = p_subaccount_id
      and (p_cursor is null or b.created_at < p_cursor)
    order by b.created_at desc, b.id desc
    limit (v_limit + 1)
  ),
  calc as (
    select
      r.id,
      r.user_id,
      r.subaccount_id,
      r.amount_atomic,
      r.amount_decimals,
      r.note,
      r.created_at,
      r.snapshot_amount - lead(r.snapshot_amount) over (order by r.created_at desc, r.id desc) as diff_amount,
      row_number() over (order by r.created_at desc, r.id desc) as rn
    from raw r
  ),
  page as (
    select *
    from calc
    where rn <= v_limit
  ),
  meta as (
    select min(p.created_at) as min_created_at
    from page p
  ),
  raw_cnt as (
    select count(*) as cnt
    from raw
  )
  select
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'id', p.id,
          'user_id', p.user_id,
          'subaccount_id', p.subaccount_id,
          'amount_atomic', p.amount_atomic,
          'amount_decimals', p.amount_decimals,
          'note', p.note,
          'created_at', p.created_at,
          'diff_amount', p.diff_amount
        )
        order by p.created_at desc, p.id desc
      ),
      '[]'::jsonb
    ),
    case when (select cnt from raw_cnt) > v_limit then (select min_created_at from meta) else null end
  into v_items, v_next_cursor
  from page p;

  return jsonb_build_object(
    'items', coalesce(v_items, '[]'::jsonb),
    'nextCursor', v_next_cursor
  );
end;

$$;
