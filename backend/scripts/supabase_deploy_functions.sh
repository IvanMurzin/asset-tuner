#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/_common.sh"

require_cmd supabase

cd_backend

supabase functions deploy bootstrap_profile --no-verify-jwt
supabase functions deploy create_account --no-verify-jwt
supabase functions deploy account --no-verify-jwt
supabase functions deploy create_subaccount --no-verify-jwt
supabase functions deploy rename_subaccount --no-verify-jwt
supabase functions deploy subaccount --no-verify-jwt
supabase functions deploy update_subaccount_balance --no-verify-jwt
supabase functions deploy update_base_currency --no-verify-jwt
supabase functions deploy get_assets_for_picker --no-verify-jwt
supabase functions deploy update_plan --no-verify-jwt
supabase functions deploy rates_sync --no-verify-jwt
supabase functions deploy coingecko_refresh_metadata --no-verify-jwt
