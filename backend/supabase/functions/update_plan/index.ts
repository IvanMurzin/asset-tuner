import { handleCors } from '../_shared/cors.ts';
import { requireAuthUser } from '../_shared/auth.ts';
import { entitlementsForPlan, normalizePlan } from '../_shared/entitlements.ts';
import { envFlag, requireEnv } from '../_shared/env.ts';
import { json, jsonError } from '../_shared/responses.ts';
import { getServiceClient } from '../_shared/supabase.ts';

const allowedPlans = new Set(['free', 'paid']);

function allowlisted(email: string | undefined): boolean {
  const raw = Deno.env.get('UPDATE_PLAN_ALLOWLIST_EMAILS');
  if (!raw) {
    return true;
  }
  if (!email) {
    return false;
  }
  const allowed = raw
    .split(',')
    .map((s) => s.trim().toLowerCase())
    .filter(Boolean);
  return allowed.includes(email.toLowerCase());
}

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) {
    return cors;
  }

  try {
    if (!envFlag('UPDATE_PLAN_ENABLED', false)) {
      return jsonError('forbidden', 'update_plan is disabled', 403);
    }

    const user = await requireAuthUser(req);
    if (!allowlisted(user.email)) {
      return jsonError('forbidden', 'Not allowed', 403);
    }

    const body = await req.json().catch(() => ({})) as Record<string, unknown>;
    const planRaw = typeof body.plan === 'string' ? body.plan : null;
    if (!planRaw || !allowedPlans.has(planRaw)) {
      return jsonError('validation', 'Invalid plan', 400, { field: 'plan' });
    }

    const plan = normalizePlan(planRaw);
    const entitlements = entitlementsForPlan(plan);

    const service = getServiceClient();
    const { data: updated, error } = await service
      .from('profiles')
      .update({ plan, entitlements })
      .eq('user_id', user.id)
      .select('*')
      .single();

    if (error) {
      return jsonError('unknown', 'Failed to update plan', 500);
    }

    return json(updated);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unexpected';
    if (message === 'Missing Authorization header' || message === 'Unauthorized') {
      return jsonError('unauthorized', 'Unauthorized', 401);
    }
    // Keep secrets safe.
    try {
      requireEnv('SUPABASE_URL');
      requireEnv('SUPABASE_ANON_KEY');
      requireEnv('SUPABASE_SERVICE_ROLE_KEY');
    } catch {
      return jsonError('unknown', 'Missing required secrets', 500);
    }
    return jsonError('unknown', 'Unexpected error', 500);
  }
});

