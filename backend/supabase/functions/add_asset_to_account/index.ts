import { handleCors } from '../_shared/cors.ts';
import { requireAuthUser } from '../_shared/auth.ts';
import { entitlementsForPlan, normalizePlan } from '../_shared/entitlements.ts';
import { json, jsonError } from '../_shared/responses.ts';
import { getServiceClient } from '../_shared/supabase.ts';
import { isUuid } from '../_shared/validators.ts';

async function ensureEntitlements(service: ReturnType<typeof getServiceClient>, userId: string) {
  const { data: profile, error } = await service
    .from('profiles')
    .select('plan')
    .eq('user_id', userId)
    .maybeSingle();
  if (error) {
    throw new Error('profile_load_failed');
  }
  const plan = normalizePlan(profile?.plan);
  return entitlementsForPlan(plan);
}

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) {
    return cors;
  }

  try {
    const user = await requireAuthUser(req);
    const body = await req.json().catch(() => ({})) as Record<string, unknown>;

    const accountId = body.account_id;
    const assetId = body.asset_id;

    if (!isUuid(accountId)) {
      return jsonError('validation', 'Invalid account_id', 400, { field: 'account_id' });
    }
    if (!isUuid(assetId)) {
      return jsonError('validation', 'Invalid asset_id', 400, { field: 'asset_id' });
    }

    const service = getServiceClient();
    const entitlements = await ensureEntitlements(service, user.id);

    const { count: positionsCount, error: positionsCountError } = await service
      .from('account_assets')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', user.id);
    if (positionsCountError) {
      return jsonError('unknown', 'Failed to check limits', 500);
    }
    if ((positionsCount ?? 0) >= entitlements.max_positions) {
      return jsonError('forbidden', 'Asset positions limit reached', 403, {
        reason: 'positions_limit',
      });
    }

    const { data: account, error: accountError } = await service
      .from('accounts')
      .select('id')
      .eq('user_id', user.id)
      .eq('id', accountId)
      .maybeSingle();
    if (accountError) {
      return jsonError('unknown', 'Failed to validate account', 500);
    }
    if (!account) {
      return jsonError('not_found', 'Account not found', 404);
    }

    const { data: asset, error: assetError } = await service
      .from('assets')
      .select('id')
      .eq('id', assetId)
      .maybeSingle();
    if (assetError) {
      return jsonError('unknown', 'Failed to validate asset', 500);
    }
    if (!asset) {
      return jsonError('validation', 'Unknown asset_id', 400, { field: 'asset_id' });
    }

    const { data: inserted, error: insertError } = await service
      .from('account_assets')
      .insert({
        user_id: user.id,
        account_id: accountId,
        asset_id: assetId,
      })
      .select('*')
      .single();

    if (insertError) {
      const msg = insertError.message ?? '';
      if (msg.includes('uq_account_assets_account_asset') || msg.includes('duplicate key')) {
        return jsonError('validation', 'Asset already added to account', 400, {
          field: 'asset_id',
          reason: 'duplicate_position',
        });
      }
      return jsonError('unknown', 'Failed to add asset to account', 500);
    }

    return json(inserted);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unexpected';
    if (message === 'Missing Authorization header' || message === 'Unauthorized') {
      return jsonError('unauthorized', 'Unauthorized', 401);
    }
    return jsonError('unknown', 'Unexpected error', 500);
  }
});

