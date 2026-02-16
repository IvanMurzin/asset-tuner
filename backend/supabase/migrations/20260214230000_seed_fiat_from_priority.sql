-- Ensure all fiat from fiat_priority exist in assets so picker can return full list (not just seed's 5).
insert into public.assets (kind, code, name, decimals, provider_ref)
select 'fiat', fp.code, fp.code, 2, null
from public.fiat_priority fp
where not exists (
  select 1 from public.assets a where a.kind = 'fiat' and a.code = fp.code
)
on conflict (kind, code) do nothing;
