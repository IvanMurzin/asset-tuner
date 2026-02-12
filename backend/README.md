# Backend (Supabase)

This folder contains the Supabase backend (database schema, RLS policies, Edge Functions) and helper scripts to deploy via the Supabase CLI.

## Prerequisites
- Supabase CLI installed and authenticated (`supabase login`)
- A Supabase project created (dev/prod)

## Deploy (dev/prod)
1) Create env files (not committed):
   - `cp supabase/.env.dev.example supabase/.env.dev`
   - `cp supabase/.env.prod.example supabase/.env.prod`
2) Link this backend folder to a Supabase project:
   - `./scripts/supabase_link.sh dev`
   - `./scripts/supabase_link.sh prod`
2) Set required secrets:
   - `./scripts/supabase_set_secrets.sh dev`
   - `./scripts/supabase_set_secrets.sh prod`
3) Push database migrations + seed:
   - `./scripts/supabase_push_db.sh`
4) Deploy edge functions:
   - `./scripts/supabase_deploy_functions.sh`

Migration details:
- `../docs/tech/money-text-migration.md`

Anything that cannot be automated via CLI/SQL is listed in `requirements.md`.

## Local development
- Start local Supabase:
  - `./scripts/supabase_start_local.sh`
- Reset local DB (re-applies migrations + runs `supabase/seed.sql`):
  - `./scripts/supabase_reset_local.sh`
