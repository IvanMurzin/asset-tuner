-- Fix the observability `app_user_id` column for refresh rows.
--
-- For client refresh rows the payload is the RevenueCat subscriber object, whose
-- `original_app_user_id` is the ANONYMOUS id created before `logIn` aliased the
-- Supabase user (e.g. `$RCAnonymousID:...`). That made the column misleading:
-- refresh rows showed an anonymous id instead of the real user. The reliable
-- identity for refresh rows is the stable `external_id` (`refresh:{uuid}`).
--
-- Webhook rows keep using `event.app_user_id` (the current id RevenueCat sends,
-- which is the Supabase user for logged-in purchases).

drop index if exists public.webhook_events_app_user_id_idx;
alter table public.webhook_events drop column if exists app_user_id;

alter table public.webhook_events
  add column app_user_id text
    generated always as (
      case
        when source = 'revenuecat_refresh'
          then nullif(split_part(external_id, ':', 2), '')
        else coalesce(
          payload->'event'->>'app_user_id',
          payload->'subscriber'->>'original_app_user_id'
        )
      end
    ) stored;

create index webhook_events_app_user_id_idx
  on public.webhook_events(app_user_id);
