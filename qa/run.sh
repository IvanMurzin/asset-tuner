#!/usr/bin/env bash
# Runs the Asset Tuner QA API suite against the hosted Supabase project.
# Secrets are loaded into this process only and are never printed.
#
# Usage (from repo root):
#   qa/run.sh                                   # whole API suite
#   qa/run.sh qa/api/accounts.test.ts           # one file
#   qa/run.sh tool qa/tools/delete_users.ts ID  # run a script that needs the same secrets
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

set -a
# shellcheck disable=SC1091
source backend/.env
set +a

QA_SUPABASE_URL="$(python3 -c "import json;print(json.load(open('.config.prod.json'))['SUPABASE_URL'])")"
QA_PUBLISHABLE_KEY="$(python3 -c "import json;print(json.load(open('.config.prod.json'))['SUPABASE_PUBLISHABLE_KEY'])")"
QA_SECRET_KEY="$(cd backend && supabase projects api-keys --project-ref "$SUPABASE_PROJECT_REF" --reveal -o json 2>/dev/null \
  | python3 -c "import json,sys;print(next(k['api_key'] for k in json.load(sys.stdin) if k['type']=='secret'))")"
QA_REVENUECAT_WEBHOOK_SECRET="$REVENUECAT_WEBHOOK_SECRET"

export QA_SUPABASE_URL QA_PUBLISHABLE_KEY QA_SECRET_KEY QA_REVENUECAT_WEBHOOK_SECRET

if [ "${1:-}" = "tool" ]; then
  shift
  exec deno run --allow-net --allow-env --allow-read "$@"
fi

if [ "$#" -eq 0 ]; then
  set -- qa/api/
fi

exec deno test --allow-net --allow-env --allow-read "$@"
