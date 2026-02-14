import { handleCors } from '../_shared/cors.ts';
import { requireAuthUser } from '../_shared/auth.ts';
import { entitlementsForPlan, normalizePlan } from '../_shared/entitlements.ts';
import { json, jsonError } from '../_shared/responses.ts';
import { getServiceClient } from '../_shared/supabase.ts';
import { isUuid, normalizeName, parseIsoDate, parseNumericString } from '../_shared/validators.ts';

function todayUtcIsoDate(): string {
  return new Date().toISOString().slice(0, 10);
}

async function loadEntitlements(service: ReturnType<typeof getServiceClient>, userId: string) {
  const { data: profile, error } = await service
    .from('profiles')
    .select('plan')
    .eq('user_id', userId)
    .maybeSingle();
  if (error) {
    throw new Error('profile_load_failed');
  }
  const plan = normalizePlan(profile?.plan);
  return {
    plan,
    entitlements: entitlementsForPlan(plan),
  };
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
    const name = normalizeName(body.name);
    const snapshotAmount = parseNumericString(body.snapshot_amount);
    const entryDate = parseIsoDate(body.entry_date) ?? todayUtcIsoDate();

    if (!isUuid(accountId)) {
      return jsonError('validation', 'Invalid account_id', 400, { field: 'account_id' });
    }
    if (!isUuid(assetId)) {
      return jsonError('validation', 'Invalid asset_id', 400, { field: 'asset_id' });
    }
    if (!name) {
      return jsonError('validation', 'Invalid name', 400, { field: 'name' });
    }
    if (snapshotAmount == null) {
      return jsonError('validation', 'Invalid snapshot_amount', 400, { field: 'snapshot_amount' });
    }

    const service = getServiceClient();
    const { entitlements, plan } = await loadEntitlements(service, user.id);

    const { count: subaccountsCount, error: countError } = await service
      .from('subaccounts')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', user.id);
    if (countError) {
      return jsonError('unknown', 'Failed to check limits', 500);
    }
    if ((subaccountsCount ?? 0) >= entitlements.max_subaccounts) {
      return jsonError('forbidden', 'Subaccounts limit reached', 403, {
        reason: 'subaccounts_limit',
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

    const { data: rankedAsset, error: rankedAssetError } = await service
      .from('asset_rankings')
      .select('asset_id, kind, rank')
      .eq('asset_id', assetId)
      .maybeSingle();
    if (rankedAssetError) {
      return jsonError('unknown', 'Failed to validate asset', 500);
    }
    if (!rankedAsset) {
      return jsonError('validation', 'Unknown asset_id', 400, { field: 'asset_id' });
    }

    const { data: limits, error: limitsError } = await service
      .from('plan_limits')
      .select('fiat_limit, crypto_limit, allow_all')
      .eq('plan', plan)
      .maybeSingle();
    if (limitsError) {
      return jsonError('unknown', 'Failed to validate plan limits', 500);
    }

    const allowAll = Boolean(limits?.allow_all);
    if (!allowAll) {
      const rank = Number.isFinite(Number(rankedAsset.rank)) && Number(rankedAsset.rank) > 0
        ? Number(rankedAsset.rank)
        : 999999;
      const fiatLimit = Number.isFinite(Number(limits?.fiat_limit))
        ? Number(limits?.fiat_limit)
        : (plan === 'paid' ? 100 : 10);
      const cryptoLimit = Number.isFinite(Number(limits?.crypto_limit))
        ? Number(limits?.crypto_limit)
        : (plan === 'paid' ? 100 : 10);
      const planLimit = rankedAsset.kind === 'crypto' ? cryptoLimit : fiatLimit;
      if (rank > planLimit) {
        return jsonError('forbidden', 'Asset is locked for current plan', 403, {
          reason: 'asset_locked',
        });
      }
    }

    const { data: subaccount, error: subaccountError } = await service
      .from('subaccounts')
      .insert({
        user_id: user.id,
        account_id: accountId,
        asset_id: assetId,
        name,
      })
      .select('*')
      .single();

    if (subaccountError || !subaccount) {
      return jsonError('unknown', 'Failed to create subaccount', 500);
    }

    const { data: balanceEntry, error: balanceEntryError } = await service
      .from('balance_entries')
      .insert({
        user_id: user.id,
        subaccount_id: subaccount.id,
        entry_date: entryDate,
        snapshot_amount: snapshotAmount,
        diff_amount: null,
      })
      .select('*')
      .single();

    if (balanceEntryError || !balanceEntry) {
      await service.from('subaccounts').delete().eq('id', subaccount.id).eq('user_id', user.id);
      return jsonError('unknown', 'Failed to create initial snapshot', 500);
    }

    return json({ subaccount, balance_entry: balanceEntry });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unexpected';
    if (message === 'Missing Authorization header' || message === 'Unauthorized') {
      return jsonError('unauthorized', 'Unauthorized', 401);
    }
    return jsonError('unknown', 'Unexpected error', 500);
  }
});
