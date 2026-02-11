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

  if (req.method !== 'DELETE') {
    return jsonError('validation', 'Method not allowed', 405);
  }

  try {
    const user = await requireAuthUser(req);
    const body = await req.json().catch(() => ({})) as Record<string, unknown>;
    const accountId = body.account_id;
    if (!isUuid(accountId)) {
      return jsonError('validation', 'Invalid account_id', 400, { field: 'account_id' });
    }

    const service = getServiceClient();
    const { error, count } = await service
      .from('accounts')
      .delete({ count: 'exact' })
      .eq('user_id', user.id)
      .eq('id', accountId);

    if (error) {
      return jsonError('unknown', 'Failed to delete account', 500);
    }

    if ((count ?? 0) === 0) {
      return jsonError('not_found', 'Account not found', 404);
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

