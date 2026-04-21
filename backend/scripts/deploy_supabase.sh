#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." >/dev/null 2>&1 && pwd)"
BACKEND_DIR="${ROOT_DIR}/backend"
ENV_FILE="${BACKEND_DIR}/.env"
cd "${ROOT_DIR}"

if ! command -v supabase >/dev/null 2>&1; then
  echo "supabase CLI is required" >&2
  exit 1
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source "${ENV_FILE}"
set +a

if [[ -z "${SUPABASE_PROJECT_REF:-}" || "${SUPABASE_PROJECT_REF}" == "replace_me" ]]; then
  echo "Set SUPABASE_PROJECT_REF in ${ENV_FILE}" >&2
  exit 1
fi

echo "[1/6] Linking project ${SUPABASE_PROJECT_REF}"
supabase --workdir "${BACKEND_DIR}" link --project-ref "${SUPABASE_PROJECT_REF}"

echo "[2/6] Pushing migrations"
supabase --workdir "${BACKEND_DIR}" db push

echo "[3/6] Seeding remote DB (optional, requires SUPABASE_DB_URL + psql)"
if [[ -n "${SUPABASE_DB_URL:-}" && "${SUPABASE_DB_URL}" != "replace_me" ]] && command -v psql >/dev/null 2>&1; then
  if ! psql "${SUPABASE_DB_URL}" -v ON_ERROR_STOP=1 -f "${BACKEND_DIR}/supabase/seed.sql"; then
    echo "Warning: remote seed failed (check SUPABASE_DB_URL/DNS/network and retry manually)"
  fi
else
  echo "Skipping remote seed: set SUPABASE_DB_URL and install psql to enable"
fi

echo "[4/6] Syncing secrets"
supabase --workdir "${BACKEND_DIR}" secrets set \
  SUPABASE_URL="${SUPABASE_URL:-}" \
  COINGECKO_API_KEY="${COINGECKO_API_KEY:-}" \
  COINGECKO_BASE_URL="${COINGECKO_BASE_URL:-}" \
  OPENEXCHANGERATES_APP_ID="${OPENEXCHANGERATES_APP_ID:-}" \
  SCHEDULER_SECRET="${SCHEDULER_SECRET:-}" \
  REVENUECAT_WEBHOOK_SECRET="${REVENUECAT_WEBHOOK_SECRET:-}" \
  REVENUECAT_API_KEY="${REVENUECAT_API_KEY:-}"

echo "[5/6] Deploying edge functions"
supabase --workdir "${BACKEND_DIR}" functions deploy api
supabase --workdir "${BACKEND_DIR}" functions deploy rates_sync --no-verify-jwt
supabase --workdir "${BACKEND_DIR}" functions deploy revenuecat_webhook --no-verify-jwt

echo "[6/6] Triggering initial rates sync (fills crypto/fiat assets + rates)"
if command -v curl >/dev/null 2>&1; then
  if curl -fsS -X POST \
    -H "x-scheduler-secret: ${SCHEDULER_SECRET}" \
    "https://${SUPABASE_PROJECT_REF}.supabase.co/functions/v1/rates_sync" >/dev/null; then
    echo "Initial rates sync triggered"
  else
    echo "Warning: initial rates_sync failed (check secrets and retry manually)"
  fi
else
  echo "curl not found: run initial rates_sync manually"
fi

echo "Done."
echo "Next: configure hourly cron to POST /functions/v1/rates_sync with header x-scheduler-secret."
