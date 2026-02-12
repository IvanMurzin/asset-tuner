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

    const subaccountId = body.subaccount_id;
    const entryDate = parseIsoDate(body.entry_date) ?? todayUtcIsoDate();
    const snapshotAmount = parseNumericString(body.snapshot_amount);

    if (!isUuid(subaccountId)) {
      return jsonError('validation', 'Invalid subaccount_id', 400, { field: 'subaccount_id' });
    }
    if (snapshotAmount == null) {
      return jsonError('validation', 'Invalid snapshot_amount', 400, { field: 'snapshot_amount' });
    }

    const today = todayUtcIsoDate();
    if (entryDate > today) {
      return jsonError('validation', 'entry_date cannot be in the future', 400, {
        field: 'entry_date',
      });
    }

    const service = getServiceClient();

    const { data: subaccount, error: subaccountError } = await service
      .from('subaccounts')
      .select('id')
      .eq('user_id', user.id)
      .eq('id', subaccountId)
      .maybeSingle();
    if (subaccountError) {
      return jsonError('unknown', 'Failed to validate subaccount', 500);
    }
    if (!subaccount) {
      return jsonError('not_found', 'Subaccount not found', 404);
    }

    const { data: previous, error: previousError } = await service
      .from('balance_entries')
      .select('snapshot_amount, entry_date, created_at')
      .eq('user_id', user.id)
      .eq('subaccount_id', subaccountId)
      .lte('entry_date', entryDate)
      .order('entry_date', { ascending: false })
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (previousError) {
      return jsonError('unknown', 'Failed to compute diff', 500);
    }

    const previousSnapshot = previous?.snapshot_amount;
    const diffAmount = previousSnapshot == null
      ? null
      : Big(snapshotAmount).minus(Big(String(previousSnapshot))).toString();

    const { data: inserted, error: insertError } = await service
      .from('balance_entries')
      .insert({
        user_id: user.id,
        subaccount_id: subaccountId,
        entry_date: entryDate,
        snapshot_amount: snapshotAmount,
        diff_amount: diffAmount,
      })
      .select('*')
      .single();

    if (insertError || !inserted) {
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
