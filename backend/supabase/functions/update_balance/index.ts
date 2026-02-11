import Big from 'https://esm.sh/big.js@6.2.1';
import { handleCors } from '../_shared/cors.ts';
import { requireAuthUser } from '../_shared/auth.ts';
import { json, jsonError } from '../_shared/responses.ts';
import { getServiceClient } from '../_shared/supabase.ts';
import { isUuid, parseIsoDate, parseNumericString } from '../_shared/validators.ts';

function todayUtcIsoDate(): string {
  return new Date().toISOString().slice(0, 10);
}

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) {
    return cors;
  }

  try {
    const user = await requireAuthUser(req);
    const body = await req.json().catch(() => ({})) as Record<string, unknown>;

    const accountAssetId = body.account_asset_id;
    const entryDate = parseIsoDate(body.entry_date);
    const snapshotAmount = parseNumericString(body.snapshot_amount);
    const deltaAmount = parseNumericString(body.delta_amount);

    if (!isUuid(accountAssetId)) {
      return jsonError('validation', 'Invalid account_asset_id', 400, {
        field: 'account_asset_id',
      });
    }
    if (!entryDate) {
      return jsonError('validation', 'Invalid entry_date', 400, { field: 'entry_date' });
    }

    const hasSnapshot = snapshotAmount != null;
    const hasDelta = deltaAmount != null;
    if (hasSnapshot === hasDelta) {
      return jsonError('validation', 'Provide exactly one of snapshot_amount or delta_amount', 400, {
        field: 'snapshot_amount',
      });
    }

    const today = todayUtcIsoDate();
    if (entryDate > today) {
      return jsonError('validation', 'entry_date cannot be in the future', 400, {
        field: 'entry_date',
      });
    }

    const service = getServiceClient();

    const { data: position, error: positionError } = await service
      .from('account_assets')
      .select('id')
      .eq('user_id', user.id)
      .eq('id', accountAssetId)
      .maybeSingle();
    if (positionError) {
      return jsonError('unknown', 'Failed to validate position', 500);
    }
    if (!position) {
      return jsonError('not_found', 'Position not found', 404);
    }

    let impliedDeltaAmount: string | null = null;
    if (hasSnapshot) {
      const { data: prev, error: prevError } = await service
        .from('balance_entries')
        .select('snapshot_amount')
        .eq('user_id', user.id)
        .eq('account_asset_id', accountAssetId)
        .eq('entry_type', 'snapshot')
        .lt('entry_date', entryDate)
        .order('entry_date', { ascending: false })
        .order('created_at', { ascending: false })
        .limit(1)
        .maybeSingle();

      if (prevError) {
        return jsonError('unknown', 'Failed to compute implied delta', 500);
      }

      const prevSnapshot = prev?.snapshot_amount;
      if (prevSnapshot != null) {
        impliedDeltaAmount = Big(snapshotAmount!).minus(Big(String(prevSnapshot))).toString();
      }
    }

    const { data: inserted, error: insertError } = await service
      .from('balance_entries')
      .insert({
        user_id: user.id,
        account_asset_id: accountAssetId,
        entry_date: entryDate,
        entry_type: hasSnapshot ? 'snapshot' : 'delta',
        snapshot_amount: hasSnapshot ? snapshotAmount : null,
        delta_amount: hasDelta ? deltaAmount : null,
        implied_delta_amount: impliedDeltaAmount,
      })
      .select('*')
      .single();

    if (insertError) {
      return jsonError('unknown', 'Failed to create balance entry', 500);
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

