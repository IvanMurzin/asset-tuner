#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
BACKEND_DIR="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

cd_backend() {
  cd "${BACKEND_DIR}"
}

require_env_name() {
  local env_name="${1:-}"
  if [[ -z "${env_name}" ]]; then
    echo "Missing environment name: dev|prod" >&2
    exit 1
  fi
  if [[ "${env_name}" != "dev" && "${env_name}" != "prod" ]]; then
    echo "Invalid environment name: ${env_name} (expected dev|prod)" >&2
    exit 1
  fi
  echo "${env_name}"
}

load_env_file() {
  local env_name
  env_name="$(require_env_name "${1:-}")"

  local env_file="${BACKEND_DIR}/supabase/.env.${env_name}"
  if [[ ! -f "${env_file}" ]]; then
    echo "Missing ${env_file}" >&2
    echo "Create it from ${BACKEND_DIR}/supabase/.env.${env_name}.example and fill values." >&2
    exit 1
  fi

  set -a
  # shellcheck disable=SC1090
  source "${env_file}"
  set +a
}
