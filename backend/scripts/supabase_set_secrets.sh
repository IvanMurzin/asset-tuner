#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/_common.sh"

require_cmd supabase

cd_backend

ENV_NAME="$(require_env_name "${1:-}")"
ENV_FILE="${BACKEND_DIR}/supabase/.env.${ENV_NAME}"

supabase secrets set --env-file "${ENV_FILE}"
