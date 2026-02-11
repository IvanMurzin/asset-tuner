#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/_common.sh"

require_cmd psql

cd_backend

ENV_NAME="$(require_env_name "${1:-}")"
load_env_file "${ENV_NAME}"

DB_URL="${SUPABASE_DB_URL:-}"
if [[ -z "${DB_URL}" ]]; then
  echo "Missing SUPABASE_DB_URL in supabase/.env.${ENV_NAME}" >&2
  echo "Get it from Supabase Dashboard -> Project Settings -> Database -> Connection string." >&2
  exit 1
fi

psql "${DB_URL}" -v ON_ERROR_STOP=1 -f "${BACKEND_DIR}/supabase/seed.sql"
