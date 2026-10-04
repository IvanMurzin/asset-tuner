import { handleCors } from '../_shared/cors.ts';
import { getAdminClient } from '../_shared/db.ts';
import { requiredEnv } from '../_shared/env.ts';
import {
  fetchSubscriberIsPro,
  isProEntitlementId,
  resolveProEntitlementIdsFromEnv,
} from '../_shared/revenuecat_entitlements.ts';
import { syncSubscriberFromRevenueCat } from '../_shared/revenuecat_sync.ts';
import { ApiHttpError, fail, fromError, ok } from '../_shared/responses.ts';

export type RevenueCatEvent = {
  id?: string;
  event_timestamp_ms?: number;
  type?: string;
  app_user_id?: string;
  entitlement_ids?: string[];
  expiration_at_ms?: number | null;
  transferred_from?: string[];
  transferred_to?: string[];
};

/**
 * App user ids whose plan a TRANSFER may have changed. A TRANSFER has no `app_user_id`; the
 * purchase moved between `transferred_from` and `transferred_to`. Anonymous RevenueCat ids have
 * no profile and are skipped.
 */
export function transferAppUserIds(event: RevenueCatEvent): string[] {
  const ids = [...(event.transferred_from ?? []), ...(event.transferred_to ?? [])]
    .map((id) => id.trim())
    .filter((id) => id.length > 0 && !id.startsWith('$RCAnonymousID:'));
  return [...new Set(ids)];
}

function requireWebhookSecret(req: Request): void {
  const expected = requiredEnv('REVENUECAT_WEBHOOK_SECRET');
  const authHeader = req.headers.get('authorization') ?? req.headers.get('Authorization');
  const match = authHeader?.match(/^Bearer\s+(.+)$/i);
  const provided = match?.[1]?.trim();

  if (!provided || provided !== expected) {
    throw new ApiHttpError(403, 'FORBIDDEN', 'Invalid RevenueCat webhook secret');
  }
}

function parsePayload(raw: unknown): { event: RevenueCatEvent; payload: Record<string, unknown> } {
  if (typeof raw !== 'object' || raw === null) {
    throw new ApiHttpError(400, 'VALIDATION_ERROR', 'Webhook payload must be an object');
  }

  const payload = raw as Record<string, unknown>;
  const eventRaw = payload.event;
  if (typeof eventRaw !== 'object' || eventRaw === null) {
    throw new ApiHttpError(400, 'VALIDATION_ERROR', 'Missing payload.event object');
  }

  return {
    event: eventRaw as RevenueCatEvent,
    payload,
  };
}

export function inferIsPro(
  event: RevenueCatEvent,
  nowMs: number = Date.now(),
  proEntitlementIds: ReadonlySet<string> = resolveProEntitlementIdsFromEnv(),
): boolean {
  const entitlementIds = event.entitlement_ids ?? [];
  const hasProEntitlement = entitlementIds.some((id) => isProEntitlementId(id, proEntitlementIds));

  if (!hasProEntitlement) {
    return false;
  }

  if (event.expiration_at_ms == null) {
    return true;
  }

  return Number.isFinite(event.expiration_at_ms) && event.expiration_at_ms > nowMs;
}

function extractExternalId(event: RevenueCatEvent, appUserId: string): string {
  if (event.id && event.id.trim().length > 0) {
    return event.id;
  }

  if (typeof event.event_timestamp_ms === 'number' && Number.isFinite(event.event_timestamp_ms)) {
    return `${appUserId}:${event.event_timestamp_ms}`;
  }

  return `${appUserId}:${new Date().toISOString()}`;
}

if (import.meta.main) {
  Deno.serve(async (req) => {
    const startedAt = Date.now();
    const cors = handleCors(req);
    if (cors) {
      return cors;
    }

    try {
      if (req.method.toUpperCase() !== 'POST') {
        throw new ApiHttpError(404, 'NOT_FOUND', 'Route not found');
      }

      requireWebhookSecret(req);

      const rawBody = await req.json().catch(() => {
        throw new ApiHttpError(400, 'VALIDATION_ERROR', 'Invalid JSON payload');
      });

      const { event, payload } = parsePayload(rawBody);

      if (event.type === 'TRANSFER') {
        // Same reconciliation as the client refresh, for every user on either side. A user
        // without a profile (deleted, never signed in) is reported, not retried.
        const results = [];
        for (const appUserId of transferAppUserIds(event)) {
          const { isPro, sync } = await syncSubscriberFromRevenueCat(appUserId);
          results.push({ app_user_id: appUserId, is_pro: isPro, reason: sync?.reason ?? null });
        }
        console.log(
          JSON.stringify({
            function: 'revenuecat_webhook',
            op: 'transfer',
            event_id: event.id ?? null,
            results,
            duration_ms: Date.now() - startedAt,
          }),
        );
        return ok({ received: true, type: 'TRANSFER', results });
      }

      const appUserId = event.app_user_id?.trim();
      if (!appUserId) {
        throw new ApiHttpError(400, 'VALIDATION_ERROR', 'event.app_user_id is required');
      }

      const externalId = extractExternalId(event, appUserId);
      const isProFromEventPayload = inferIsPro(event);
      const { isPro } = await fetchSubscriberIsPro(appUserId);

      const db = getAdminClient();
      const { data, error } = await db.rpc('api_apply_revenuecat_event', {
        p_source: 'revenuecat',
        p_external_id: externalId,
        p_app_user_id: appUserId,
        p_payload: payload,
        p_is_pro: isPro,
      });

      if (error) {
        throw error;
      }

      const result = data as Record<string, unknown> | null;

      // The profile does not exist yet (e.g. webhook raced ahead of profile
      // creation). The RPC intentionally did NOT consume the idempotency key,
      // so ask RevenueCat to re-deliver later once the profile exists.
      const profileNotFound = result?.processed === false &&
        result?.reason === 'profile_not_found';

      console.log(
        JSON.stringify({
          function: 'revenuecat_webhook',
          op: 'process',
          app_user_id: appUserId,
          external_id: externalId,
          is_pro: isPro,
          is_pro_from_event_payload: isProFromEventPayload,
          is_pro_source: 'subscriber_api',
          processed: result?.processed ?? null,
          reason: result?.reason ?? null,
          profile_not_found: profileNotFound,
          duration_ms: Date.now() - startedAt,
        }),
      );

      if (profileNotFound) {
        return fail(
          503,
          'INTERNAL_ERROR',
          'Profile not found yet for app_user_id; retry later',
        );
      }

      return ok({
        received: true,
        app_user_id: appUserId,
        external_id: externalId,
        is_pro: isPro,
        result,
      });
    } catch (error) {
      const failure = fromError(error);

      console.error(
        JSON.stringify({
          function: 'revenuecat_webhook',
          op: 'process_failed',
          error: error instanceof Error ? error.message : 'unknown_error',
          duration_ms: Date.now() - startedAt,
        }),
      );

      return failure;
    }
  });
}
