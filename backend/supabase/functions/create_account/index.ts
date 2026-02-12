import { handleCors } from '../_shared/cors.ts';
import { requireAuthUser } from '../_shared/auth.ts';
import { entitlementsForPlan, normalizePlan } from '../_shared/entitlements.ts';
import { json, jsonError } from '../_shared/responses.ts';
import { getServiceClient } from '../_shared/supabase.ts';
import { normalizeName } from '../_shared/validators.ts';

const allowedTypes = new Set(['bank', 'wallet', 'exchange', 'cash', 'other']);

async function ensureProfile(service: ReturnType<typeof getServiceClient>, userId: string) {
  const { data: profile, error } = await service
    .from('profiles')
    .select('*')
    .eq('user_id', userId)
    .maybeSingle();
  if (error) {
    throw new Error('profile_load_failed');
  }
  if (profile) {
    const plan = normalizePlan(profile.plan);
    return { profile, plan, entitlements: entitlementsForPlan(plan) };
  }
  const plan = 'free' as const;
  const entitlements = entitlementsForPlan(plan);
  const { data: inserted, error: insertError } = await service
    .from('profiles')
    .insert({
      user_id: userId,
      base_currency: 'USD',
      plan,
      entitlements,
    })
    .select('*')
    .single();
  if (insertError) {
    throw new Error('profile_create_failed');
  }
  return { profile: inserted, plan, entitlements };
}

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) {
    return cors;
  }

  try {
    const user = await requireAuthUser(req);
    const body = await req.json().catch(() => ({})) as Record<string, unknown>;

    const name = normalizeName(body.name);
    const type = typeof body.type === 'string' ? body.type : null;

    if (!name) {
      return jsonError('validation', 'Invalid name', 400, { field: 'name' });
    }
    if (!type || !allowedTypes.has(type)) {
      return jsonError('validation', 'Invalid type', 400, { field: 'type' });
    }

    const service = getServiceClient();
    const { entitlements } = await ensureProfile(service, user.id);

    const { count, error: countError } = await service
      .from('accounts')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', user.id);

    if (countError) {
      return jsonError('unknown', 'Failed to check limits', 500);
    }

    if ((count ?? 0) >= entitlements.max_accounts) {
      return jsonError('forbidden', 'Accounts limit reached', 403, {
        reason: 'accounts_limit',
      });
    }

    const { data: inserted, error: insertError } = await service
      .from('accounts')
      .insert({ user_id: user.id, name, type })
      .select('*')
      .single();

    if (insertError) {
      return jsonError('unknown', 'Failed to create account', 500);
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
