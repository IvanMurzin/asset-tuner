import { handleCors } from '../_shared/cors.ts';
import { requireAuthUser } from '../_shared/auth.ts';
import { json, jsonError } from '../_shared/responses.ts';
import { getServiceClient } from '../_shared/supabase.ts';
import { isUuid } from '../_shared/validators.ts';

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

    const { error, count } = await service
      .from('account_assets')
      .delete({ count: 'exact' })
      .eq('user_id', user.id)
      .eq('account_id', accountId)
      .eq('asset_id', assetId);

    if (error) {
      return jsonError('unknown', 'Failed to remove asset from account', 500);
    }

    if ((count ?? 0) === 0) {
      return jsonError('not_found', 'Position not found', 404);
    }

    return json({ ok: true });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unexpected';
    if (message === 'Missing Authorization header' || message === 'Unauthorized') {
      return jsonError('unauthorized', 'Unauthorized', 401);
    }
    return jsonError('unknown', 'Unexpected error', 500);
  }
});

