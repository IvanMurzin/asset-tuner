create or replace function public.validate_amount_atomic(p_value text)
returns boolean
language plpgsql
immutable
strict
as $func$
begin
  return p_value ~ '^-?\\d+$';
end;
$func$;
