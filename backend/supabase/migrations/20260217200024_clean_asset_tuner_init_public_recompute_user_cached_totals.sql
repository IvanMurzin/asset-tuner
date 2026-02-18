create or replace function public.recompute_user_cached_totals(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_account_id uuid;
begin
  for v_account_id in
    select a.id
    from public.accounts a
    where a.user_id = p_user_id
  loop
    perform public.recompute_account_cached_total_usd(v_account_id);
  end loop;
end;
$func$;
