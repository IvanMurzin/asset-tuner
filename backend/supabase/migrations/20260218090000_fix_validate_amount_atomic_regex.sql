create or replace function public.validate_amount_atomic(p_value text)
returns boolean
language sql
immutable
strict
as $sql$
  select p_value ~ '^-?[0-9]+$';
$sql$;
