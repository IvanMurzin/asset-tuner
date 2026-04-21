import { handleCors } from '../_shared/cors.ts';
import { getAdminClient } from '../_shared/db.ts';
import { requiredEnv } from '../_shared/env.ts';
import { ApiHttpError, fromError, ok } from '../_shared/responses.ts';

export type RevenueCatEvent = {
  id?: string;
  event_timestamp_ms?: number;
  type?: string;
  app_user_id?: string;
  entitlement_ids?: string[];
  expiration_at_ms?: number | null;
};

type RevenueCatEntitlement = {
  expires_date?: string | null;
};

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

export function inferIsPro(event: RevenueCatEvent, nowMs: number = Date.now()): boolean {
  const entitlementIds = event.entitlement_ids ?? [];
  const hasProEntitlement = entitlementIds.some((id) => id.trim().toLowerCase() === 'pro');

  if (!hasProEntitlement) {
    return false;
  }

  if (event.expiration_at_ms == null) {
    return true;
  }

  return Number.isFinite(event.expiration_at_ms) && event.expiration_at_ms > nowMs;
}

export function inferIsProFromSubscriberEntitlements(
  entitlements: Record<string, RevenueCatEntitlement | undefined>,
  nowMs: number = Date.now(),
): boolean {
  return Object.entries(entitlements).some(([entitlementId, entitlement]) => {
    if (entitlementId.trim().toLowerCase() !== 'pro') {
      return false;
    }
    if (!entitlement) {
      return false;
    }
    const expiresAt = entitlement.expires_date;
    if (!expiresAt) {
      return true;
    }
    const expiresMs = new Date(expiresAt).getTime();
    return Number.isFinite(expiresMs) && expiresMs > nowMs;
  });
}

async function fetchIsProFromSubscriberApi(appUserId: string): Promise<boolean> {
  const apiKey = requiredEnv('REVENUECAT_API_KEY');
  const response = await fetch(
    `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}`,
    {
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
    },
  );

  if (!response.ok) {
    // Treat unknown subscriber as free; other failures should retry webhook delivery.
    if (response.status === 404) {
      return false;
    }
    const details = await response.text().catch(() => '');
    throw new ApiHttpError(502, 'EXTERNAL_API_ERROR', 'RevenueCat subscriber request failed', {
      status: response.status,
      details,
    });
  }

  const payload = (await response.json()) as Record<string, unknown>;
  const subscriber = payload.subscriber as Record<string, unknown> | undefined;
  const entitlements = (subscriber?.entitlements ?? {}) as Record<
    string,
    RevenueCatEntitlement | undefined
  >;
  return inferIsProFromSubscriberEntitlements(entitlements);
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

      const appUserId = event.app_user_id?.trim();
      if (!appUserId) {
        throw new ApiHttpError(400, 'VALIDATION_ERROR', 'event.app_user_id is required');
      }

      const externalId = extractExternalId(event, appUserId);
      const isProFromEventPayload = inferIsPro(event);
      const isPro = await fetchIsProFromSubscriberApi(appUserId);

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
          duration_ms: Date.now() - startedAt,
        }),
      );

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
