-- QA-016 / SPEC-0011: an atomic amount has exactly one text form (no leading zeros, no "-0"), so
-- equal amounts are equal strings. Enforced here and by every CHECK constraint that uses it.
create or replace function public.validate_amount_atomic(p_value text)
returns boolean
language sql
immutable
strict
as $sql$
  select p_value ~ '^(0|-?[1-9][0-9]*)$';
$sql$;
