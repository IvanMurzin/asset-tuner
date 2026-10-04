import { getAdminClient } from './db.ts';
import { fetchSubscriberIsPro } from './revenuecat_entitlements.ts';

/**
 * Reconciles one app user's plan with RevenueCat: reads the subscriber over REST (the source of
 * truth) and applies it. Keeps at most one `revenuecat_refresh` ledger row per user (upsert).
 *
 * Throws `ApiHttpError` from the REST lookup (e.g. 429) and the raw database error from the RPC.
 */
export async function syncSubscriberFromRevenueCat(
  appUserId: string,
): Promise<{ isPro: boolean; sync: Record<string, unknown> | null }> {
  const { payload, isPro } = await fetchSubscriberIsPro(appUserId);
  const { data, error } = await getAdminClient().rpc('api_apply_revenuecat_event', {
    p_source: 'revenuecat_refresh',
    p_external_id: `refresh:${appUserId}`,
    p_app_user_id: appUserId,
    p_payload: payload ?? {},
    p_is_pro: isPro,
    p_dedupe: false,
  });
  if (error) {
    throw error;
  }
  return { isPro, sync: data as Record<string, unknown> | null };
}
