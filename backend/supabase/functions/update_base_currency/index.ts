import { handleCors } from '../_shared/cors.ts';
import { requireAuthUser } from '../_shared/auth.ts';
import { entitlementsForPlan, normalizePlan } from '../_shared/entitlements.ts';
import { json, jsonError } from '../_shared/responses.ts';
import { getServiceClient } from '../_shared/supabase.ts';
import { normalizeCode } from '../_shared/validators.ts';

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) {
    return cors;
  }

  try {
    const user = await requireAuthUser(req);
    const body = await req.json().catch(() => ({})) as Record<string, unknown>;
    const baseCurrency = normalizeCode(body.base_currency);
    if (!baseCurrency) {
      return jsonError('validation', 'Invalid base_currency', 400, { field: 'base_currency' });
    }

    const service = getServiceClient();
    const { data: profile, error: profileError } = await service
      .from('profiles')
      .select('*')
      .eq('user_id', user.id)
      .maybeSingle();

    if (profileError) {
      return jsonError('unknown', 'Failed to load profile', 500);
    }
    if (!profile) {
      return jsonError('not_found', 'Profile not found', 404);
    }

    const plan = normalizePlan(profile.plan);
    const entitlements = entitlementsForPlan(plan);
    if (!entitlements.any_base_currency) {
      const allowed = new Set(entitlements.allowed_base_currency_codes);
      if (!allowed.has(baseCurrency)) {
        return jsonError('forbidden', 'Base currency not allowed', 403, {
          reason: 'base_currency',
        });
      }
    }

    const { data: fiat, error: fiatError } = await service
      .from('assets')
      .select('id')
      .eq('kind', 'fiat')
      .eq('code', baseCurrency)
      .maybeSingle();
    if (fiatError) {
      return jsonError('unknown', 'Failed to validate currency', 500);
    }
    if (!fiat) {
      return jsonError('validation', 'Unsupported currency', 400, { field: 'base_currency' });
    }

    const { data: updated, error: updateError } = await service
      .from('profiles')
      .update({ base_currency: baseCurrency })
      .eq('user_id', user.id)
      .select('*')
      .single();

    if (updateError) {
      return jsonError('unknown', 'Failed to update base currency', 500);
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

