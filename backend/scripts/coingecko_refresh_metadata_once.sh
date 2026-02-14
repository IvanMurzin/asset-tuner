#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/_common.sh"

require_cmd curl

ENV_NAME="$(require_env_name "${1:-}")"
load_env_file "${ENV_NAME}"

SUPABASE_URL="${SUPABASE_URL:-}"
RATES_SYNC_SECRET="${RATES_SYNC_SECRET:-}"

if [[ -z "${SUPABASE_URL}" ]]; then
  echo "Missing SUPABASE_URL in supabase/.env.${ENV_NAME}" >&2
  exit 1
fi
if [[ -z "${RATES_SYNC_SECRET}" ]]; then
  echo "Missing RATES_SYNC_SECRET in supabase/.env.${ENV_NAME}" >&2
  exit 1
fi

curl -sS -X POST \
  -H "Content-Type: application/json" \
  -H "x-rates-sync-secret: ${RATES_SYNC_SECRET}" \
  "${SUPABASE_URL%/}/functions/v1/coingecko_refresh_metadata"
