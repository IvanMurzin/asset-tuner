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
    const subaccountId = body.subaccount_id;

    if (!isUuid(subaccountId)) {
      return jsonError('validation', 'Invalid subaccount_id', 400, { field: 'subaccount_id' });
    }

    const service = getServiceClient();
    const { error, count } = await service
      .from('subaccounts')
      .delete({ count: 'exact' })
      .eq('user_id', user.id)
      .eq('id', subaccountId);

    if (error) {
      return jsonError('unknown', 'Failed to delete subaccount', 500);
    }

    if ((count ?? 0) === 0) {
      return jsonError('not_found', 'Subaccount not found', 404);
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
