#!/usr/bin/env bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/_common.sh"

require_cmd supabase

cd_backend

ENV_NAME="$(require_env_name "${1:-}")"
load_env_file "${ENV_NAME}"

# Destructive operation: drops all data on the linked remote DB,
# reapplies migrations, and runs seed.sql.
supabase db reset --linked --yes
