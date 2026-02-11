#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/_common.sh"

require_cmd supabase

ENV_NAME="$(require_env_name "${1:-}")"
load_env_file "${ENV_NAME}"

PROJECT_REF="${2:-${SUPABASE_PROJECT_REF:-}}"
if [[ -z "${PROJECT_REF}" ]]; then
  echo "Missing SUPABASE_PROJECT_REF in supabase/.env.${ENV_NAME} (or pass as 2nd arg)." >&2
  echo "Tip: list projects with: supabase projects list" >&2
  exit 1
fi

cd_backend
supabase link --project-ref "${PROJECT_REF}"
