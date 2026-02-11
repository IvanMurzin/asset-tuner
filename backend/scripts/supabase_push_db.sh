#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/_common.sh"

require_cmd supabase

cd_backend

supabase db push

echo "Done. Note: the Supabase CLI only seeds automatically for local db reset."
echo "To seed a remote DB, run: ./scripts/supabase_seed_remote.sh"

