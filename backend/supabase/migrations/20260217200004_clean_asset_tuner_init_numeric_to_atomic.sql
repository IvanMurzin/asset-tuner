create or replace function public.numeric_to_atomic(p_value numeric, p_decimals int)
returns text
language plpgsql
immutable
strict
as $func$
declare
  v_scaled numeric;
begin
  if p_decimals < 0 or p_decimals > 18 then
    raise exception 'VALIDATION_ERROR: decimals must be in range 0..18';
  end if;

  -- Round half away from zero via round(..., 0).
  v_scaled := round(p_value * power(10::numeric, p_decimals), 0);
  return v_scaled::text;
end;
$func$;
