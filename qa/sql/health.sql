-- Asset Tuner production health checks. READ-ONLY: every statement is a SELECT.
-- Run from the repository root:
--   set -a; source backend/.env; set +a
--   psql "$SUPABASE_DB_URL" -X -f qa/sql/health.sql
-- Or paste individual blocks into the Supabase SQL editor.

\echo '== 1. api_* functions executable by anon/authenticated (expected: 0 rows)'
select p.proname,
       has_function_privilege('anon', p.oid, 'execute') as anon,
       has_function_privilege('authenticated', p.oid, 'execute') as authenticated
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and (p.proname like 'api\_%' or p.proname like 'recompute\_%' or p.proname like 'handle\_%')
  and (has_function_privilege('anon', p.oid, 'execute')
       or has_function_privilege('authenticated', p.oid, 'execute'))
order by 1;

\echo '== 2. Tables readable by anon/authenticated (expected: 0 rows)'
select c.relname,
       has_table_privilege('anon', c.oid, 'select') as anon,
       has_table_privilege('authenticated', c.oid, 'select') as authenticated
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relkind = 'r'
  and (has_table_privilege('anon', c.oid, 'select')
       or has_table_privilege('authenticated', c.oid, 'select'))
order by 1;

\echo '== 3. Rates cron job (expected: 1 active row, hourly)'
select jobid, jobname, schedule, active from cron.job where jobname = 'asset_tuner_rates_sync_hourly';

\echo '== 4. Last cron runs'
select d.status, d.start_time, d.return_message
from cron.job_run_details d
join cron.job j on j.jobid = d.jobid
where j.jobname = 'asset_tuner_rates_sync_hourly'
order by d.start_time desc
limit 5;

\echo '== 5. Rates freshness and coverage (expected: newest as_of < 2h old, missing = 0)'
select a.kind,
       count(*) filter (where a.is_active) as active_assets,
       count(*) filter (where a.is_active and (r.asset_id is null or r.usd_price_atomic::numeric <= 0))
         as missing_or_zero_rate,
       max(r.as_of) as newest_as_of,
       now() - max(r.as_of) as age
from public.assets a
left join public.asset_rates_usd r on r.asset_id = a.id
group by a.kind
order by a.kind;

\echo '== 6. Plans overview'
select plan, count(*) from public.profiles group by plan order by plan;

\echo '== 7. Pro users and their latest RevenueCat ledger event'
select p.user_id, p.revenuecat_app_user_id, p.updated_at,
       w.source, w.event_type, w.received_at as last_event_at
from public.profiles p
left join lateral (
  select source, event_type, received_at
  from public.webhook_events e
  where e.app_user_id = coalesce(p.revenuecat_app_user_id, p.user_id::text)
  order by received_at desc
  limit 1
) w on true
where p.plan = 'pro'
order by p.updated_at desc
limit 50;

\echo '== 8. Recent webhook ledger (last 30)'
select received_at, source, event_type, app_user_id, external_id
from public.webhook_events
order by received_at desc
limit 30;

\echo '== 9. Soft-deleted auth users that still own data (expected: 0 rows)'
select u.id, u.deleted_at,
       (select count(*) from public.accounts a where a.user_id = u.id) as accounts
from auth.users u
where u.deleted_at is not null
order by u.deleted_at desc
limit 50;

\echo '== 10. Leftovers from QA runs (expected: 0 rows)'
select id, email, created_at, deleted_at
from auth.users
where email like 'qa+%@asset-tuner.test'
order by created_at desc;

\echo '== 11. Free users above free limits (info: happens after a pro -> free downgrade)'
select p.user_id,
       (select count(*) from public.accounts a where a.user_id = p.user_id) as accounts,
       (select count(*) from public.subaccounts s where s.user_id = p.user_id) as subaccounts
from public.profiles p
where p.plan = 'free'
  and ((select count(*) from public.accounts a where a.user_id = p.user_id) > 5
       or (select count(*) from public.subaccounts s where s.user_id = p.user_id) > 15);

\echo '== 12. Support messages in the last 7 days'
select created_at, subject, left(message, 80) as message
from public.support_messages
where created_at > now() - interval '7 days'
order by created_at desc;
