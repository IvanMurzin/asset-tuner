import { handleCors } from '../_shared/cors.ts';
import { requireAuthUser } from '../_shared/auth.ts';
import { entitlementsForPlan, normalizePlan } from '../_shared/entitlements.ts';
import { json, jsonError } from '../_shared/responses.ts';
import { getServiceClient } from '../_shared/supabase.ts';

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) {
    return cors;
  }

  try {
    const user = await requireAuthUser(req);
    const service = getServiceClient();

    const { data: existing, error: existingError } = await service
      .from('profiles')
      .select('*')
      .eq('user_id', user.id)
      .maybeSingle();

    if (existingError) {
      return jsonError('unknown', 'Failed to load profile', 500);
    }

    const plan = normalizePlan(existing?.plan);
    const entitlements = entitlementsForPlan(plan);

    if (!existing) {
      const { data: inserted, error: insertError } = await service
        .from('profiles')
        .insert({
          user_id: user.id,
          base_currency: 'USD',
          plan,
          entitlements,
        })
        .select('*')
        .single();

      if (insertError) {
        return jsonError('unknown', 'Failed to create profile', 500);
      }

      return json({
        profile: inserted,
        is_new: true,
        was_base_currency_defaulted: true,
      });
    }

    const needsEntitlementsSync =
      JSON.stringify(existing.entitlements ?? null) !== JSON.stringify(entitlements);
    if (!needsEntitlementsSync) {
      return json({
        profile: existing,
        is_new: false,
        was_base_currency_defaulted: false,
      });
    }

    const { data: updated, error: updateError } = await service
      .from('profiles')
      .update({ entitlements })
      .eq('user_id', user.id)
      .select('*')
      .single();

    if (updateError) {
      return jsonError('unknown', 'Failed to update profile', 500);
    }

    return json({
      profile: updated,
      is_new: false,
      was_base_currency_defaulted: false,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unauthorized';
    if (message === 'Missing Authorization header' || message === 'Unauthorized') {
      return jsonError('unauthorized', 'Unauthorized', 401);
    }
    return jsonError('unknown', 'Unexpected error', 500);
  }
});

