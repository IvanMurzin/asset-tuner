#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/_common.sh"

require_cmd supabase

cd_backend

supabase functions deploy bootstrap_profile
supabase functions deploy create_account
supabase functions deploy account
supabase functions deploy create_subaccount
supabase functions deploy rename_subaccount
supabase functions deploy subaccount
supabase functions deploy update_subaccount_balance
supabase functions deploy update_base_currency
supabase functions deploy update_plan
supabase functions deploy rates_sync --no-verify-jwt
