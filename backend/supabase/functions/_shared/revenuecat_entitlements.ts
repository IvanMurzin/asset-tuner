import { optionalEnv } from './env.ts';

const DEFAULT_PRO_ENTITLEMENT_IDS = ['pro'] as const;

export function normalizeEntitlementId(value: string): string {
  return value.trim().toLowerCase();
}

export function resolveProEntitlementIdsFromEnv(): Set<string> {
  const csv = optionalEnv('REVENUECAT_PRO_ENTITLEMENTS');
  const single = optionalEnv('REVENUECAT_PRO_ENTITLEMENT');

  const configured = [
    ...(csv ? csv.split(',') : []),
    ...(single ? [single] : []),
  ]
    .map(normalizeEntitlementId)
    .filter((value) => value.length > 0);

  if (configured.length === 0) {
    return new Set(DEFAULT_PRO_ENTITLEMENT_IDS);
  }

  return new Set(configured);
}

export function isProEntitlementId(
  entitlementId: string,
  proEntitlementIds: ReadonlySet<string>,
): boolean {
  return proEntitlementIds.has(normalizeEntitlementId(entitlementId));
}
