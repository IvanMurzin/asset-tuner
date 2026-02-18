#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." >/dev/null 2>&1 && pwd)"
cd "${ROOT_DIR}"

if ! command -v psql >/dev/null 2>&1; then
  echo "psql is required" >&2
  exit 1
fi

ENV_FILE="${ROOT_DIR}/backend/.env"
if [[ ! -f "${ENV_FILE}" ]]; then
  ENV_FILE="${ROOT_DIR}/.env"
fi
if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing env file: ${ROOT_DIR}/backend/.env (preferred) or ${ROOT_DIR}/.env" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
source "${ENV_FILE}"
set +a

if [[ -z "${SUPABASE_DB_URL:-}" || "${SUPABASE_DB_URL}" == "replace_me" ]]; then
  # Optional helper: construct a pooler URL from Supabase CLI cache + password.
  POOLER_URL_FILE="${ROOT_DIR}/backend/supabase/.temp/pooler-url"
  if [[ -n "${SUPABASE_DB_PASSWORD:-}" && -f "${POOLER_URL_FILE}" ]]; then
	    RAW_POOLER_URL="$(cat "${POOLER_URL_FILE}")"
	    # RAW_POOLER_URL is like: postgresql://postgres.<ref>@<host>:5432/postgres
	    SUPABASE_DB_URL="$(echo "${RAW_POOLER_URL}" | sed -E "s#^(postgresql://[^/@]+)@#\\1:${SUPABASE_DB_PASSWORD}@#")"
	    export SUPABASE_DB_URL
	    echo "SUPABASE_DB_URL not set; using pooler URL from ${POOLER_URL_FILE}"
	  else
    echo "Set SUPABASE_DB_URL in ${ENV_FILE} (or set SUPABASE_DB_PASSWORD and run supabase link to populate ${POOLER_URL_FILE})" >&2
    exit 1
  fi
fi
if [[ -z "${SUPABASE_PROJECT_REF:-}" || "${SUPABASE_PROJECT_REF}" == "replace_me" ]]; then
  echo "Set SUPABASE_PROJECT_REF in ${ENV_FILE}" >&2
  exit 1
fi
if [[ -z "${SCHEDULER_SECRET:-}" || "${SCHEDULER_SECRET}" == "replace_me" ]]; then
  echo "Set SCHEDULER_SECRET in ${ENV_FILE}" >&2
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
