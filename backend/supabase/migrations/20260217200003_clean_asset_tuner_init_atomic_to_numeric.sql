create or replace function public.atomic_to_numeric(p_amount_atomic text, p_decimals int)
returns numeric
language plpgsql
immutable
strict
as $func$
begin
  if p_decimals < 0 or p_decimals > 18 then
    raise exception 'VALIDATION_ERROR: decimals must be in range 0..18';
  end if;
  if not public.validate_amount_atomic(p_amount_atomic) then
    raise exception 'VALIDATION_ERROR: invalid atomic integer string';
  end if;

  return p_amount_atomic::numeric / power(10::numeric, p_decimals);
end;
$func$;
