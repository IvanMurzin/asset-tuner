# Money Text Migration (v2)

## Goal
- DB stores money/rates as decimal strings in `text` columns.
- Edge Functions accept/return decimal strings.
- Client parses money/rates JSON fields directly to `Decimal`.

## Scope
- Tables:
  - `public.balance_entries.snapshot_amount`
  - `public.balance_entries.diff_amount`
  - `public.asset_rates_usd.usd_price`
- Client DTOs:
  - `BalanceEntryDto`
  - `AssetRateUsdDto`

## Migration files
- Baseline schema (fresh environments):
  - `backend/supabase/migrations/20260211170000_init.sql`
- Existing migration aligned to text:
  - `backend/supabase/migrations/20260211193000_asset_rates_usd_usd_price_text.sql`
- Existing environments conversion:
  - `backend/supabase/migrations/20260212173000_money_columns_text.sql`

## Deploy order
1. Push DB migrations.
2. Deploy Edge Functions.
3. Roll out client.

## Commands
Run from repo root:

```bash
./backend/scripts/supabase_push_db.sh
./backend/scripts/supabase_deploy_functions.sh
```

Optional remote seed refresh:

```bash
./backend/scripts/supabase_seed_remote.sh dev
./backend/scripts/supabase_seed_remote.sh prod
```

## Compatibility note
- During rollout, old clients that send numeric JSON values for money fields may fail validation in write functions.
- Recommended rollout: backend first, then client.
