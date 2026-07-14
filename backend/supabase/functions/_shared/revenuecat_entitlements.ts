import { requiredEnv } from './env.ts';
import { ApiHttpError } from './responses.ts';

const REVENUECAT_API_BASE = 'https://api.revenuecat.com/v1';

export type RevenueCatEntitlement = {
  expires_date?: string | null;
};

export function normalizeEntitlementId(value: string): string {
  return value.trim().toLowerCase();
}

let cachedProEntitlementIds: ReadonlySet<string> | null = null;

export function resolveProEntitlementIdsFromEnv(): ReadonlySet<string> {
  if (cachedProEntitlementIds) {
    return cachedProEntitlementIds;
  }

  const configured = requiredEnv('REVENUECAT_PRO_ENTITLEMENTS')
    .split(',')
    .map(normalizeEntitlementId)
    .filter((value) => value.length > 0);

  if (configured.length === 0) {
    throw new Error(
      'REVENUECAT_PRO_ENTITLEMENTS must list at least one entitlement identifier ' +
        '(RevenueCat: Product catalog -> Entitlements -> Identifier)',
    );
  }

  cachedProEntitlementIds = new Set(configured);
  return cachedProEntitlementIds;
}

export function isProEntitlementId(
  entitlementId: string,
  proEntitlementIds: ReadonlySet<string>,
): boolean {
  return proEntitlementIds.has(normalizeEntitlementId(entitlementId));
}

export function isProFromEntitlements(
  entitlements: Record<string, RevenueCatEntitlement | undefined>,
  nowMs: number = Date.now(),
  proEntitlementIds: ReadonlySet<string> = resolveProEntitlementIdsFromEnv(),
): boolean {
  return Object.entries(entitlements).some(([entitlementId, entitlement]) => {
    if (!isProEntitlementId(entitlementId, proEntitlementIds) || !entitlement) {
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

export function extractEntitlements(
  subscriberPayload: Record<string, unknown> | null,
): Record<string, RevenueCatEntitlement | undefined> {
  const subscriber = subscriberPayload?.subscriber as Record<string, unknown> | undefined;
  return (subscriber?.entitlements ?? {}) as Record<string, RevenueCatEntitlement | undefined>;
}

export async function fetchSubscriber(appUserId: string): Promise<Record<string, unknown> | null> {
  const apiKey = requiredEnv('REVENUECAT_API_KEY');

  const response = await fetch(
    `${REVENUECAT_API_BASE}/subscribers/${encodeURIComponent(appUserId)}`,
    {
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
    },
  );

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    const details = await response.text().catch(() => '');
    throw new ApiHttpError(502, 'EXTERNAL_API_ERROR', 'RevenueCat subscriber request failed', {
      status: response.status,
      details,
    });
  }

  return (await response.json()) as Record<string, unknown>;
}

export async function fetchSubscriberIsPro(
  appUserId: string,
  proEntitlementIds: ReadonlySet<string> = resolveProEntitlementIdsFromEnv(),
): Promise<{ payload: Record<string, unknown> | null; isPro: boolean }> {
  const payload = await fetchSubscriber(appUserId);
  const isPro = isProFromEntitlements(extractEntitlements(payload), Date.now(), proEntitlementIds);
  return { payload, isPro };
}
