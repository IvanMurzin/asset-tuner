import { handleCors } from '../_shared/cors.ts';
import { requireAuthUser } from '../_shared/auth.ts';
import { json, jsonError } from '../_shared/responses.ts';
import { getServiceClient } from '../_shared/supabase.ts';
import { isUuid, normalizeName } from '../_shared/validators.ts';

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) {
    return cors;
  }

  try {
    const user = await requireAuthUser(req);
    const body = await req.json().catch(() => ({})) as Record<string, unknown>;

    const subaccountId = body.subaccount_id;
    const name = normalizeName(body.name);

    if (!isUuid(subaccountId)) {
      return jsonError('validation', 'Invalid subaccount_id', 400, { field: 'subaccount_id' });
    }
    if (!name) {
      return jsonError('validation', 'Invalid name', 400, { field: 'name' });
    }

    const service = getServiceClient();
    const { data: updated, error } = await service
      .from('subaccounts')
      .update({ name })
      .eq('user_id', user.id)
      .eq('id', subaccountId)
      .select('*')
      .maybeSingle();

    if (error) {
      return jsonError('unknown', 'Failed to rename subaccount', 500);
    }
    if (!updated) {
      return jsonError('not_found', 'Subaccount not found', 404);
    }

    return json(updated);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unexpected';
    if (message === 'Missing Authorization header' || message === 'Unauthorized') {
      return jsonError('unauthorized', 'Unauthorized', 401);
    }
    return jsonError('unknown', 'Unexpected error', 500);
  }
});
