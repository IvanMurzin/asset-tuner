#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." >/dev/null 2>&1 && pwd)"
cd "${ROOT_DIR}"

if ! command -v psql >/dev/null 2>&1; then
  echo "psql is required" >&2
  exit 1
fi

if [[ ! -f .env ]]; then
  echo "Missing .env in repo root" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

if [[ -z "${SUPABASE_DB_URL:-}" || "${SUPABASE_DB_URL}" == "replace_me" ]]; then
  echo "Set SUPABASE_DB_URL in .env" >&2
  exit 1
fi
if [[ -z "${SUPABASE_PROJECT_REF:-}" || "${SUPABASE_PROJECT_REF}" == "replace_me" ]]; then
  echo "Set SUPABASE_PROJECT_REF in .env" >&2
  exit 1
fi
if [[ -z "${SCHEDULER_SECRET:-}" || "${SCHEDULER_SECRET}" == "replace_me" ]]; then
  echo "Set SCHEDULER_SECRET in .env" >&2
  exit 1
fi

FUNCTION_URL="https://${SUPABASE_PROJECT_REF}.supabase.co/functions/v1/rates_sync"

psql "${SUPABASE_DB_URL}" -v ON_ERROR_STOP=1 <<SQL
create extension if not exists pg_cron;
create extension if not exists pg_net;

do \
\$\$ \
declare
  v_job_id bigint;
begin
  select jobid into v_job_id
  from cron.job
  where jobname = 'asset_tuner_rates_sync_hourly'
  limit 1;

  if v_job_id is not null then
    perform cron.unschedule(v_job_id);
  end if;

  perform cron.schedule(
    'asset_tuner_rates_sync_hourly',
    '0 * * * *',
    format(
      \$cmd\$select net.http_post(url := %L, headers := jsonb_build_object('x-scheduler-secret', %L));\$cmd\$,
      '${FUNCTION_URL}',
      '${SCHEDULER_SECRET}'
    )
  );
end
\$\$;
SQL

echo "Hourly cron configured for rates_sync"
