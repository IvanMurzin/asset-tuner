import { handleCors } from '../_shared/cors.ts';
import { requireAuthUser } from '../_shared/auth.ts';
import { normalizePlan } from '../_shared/entitlements.ts';
import { json, jsonError } from '../_shared/responses.ts';
import { getServiceClient } from '../_shared/supabase.ts';

type AssetRow = { id: string; kind: string; code: string; name: string };
type RankingRow = { asset_id: string; rank: number };
type PlanLimitsRow = { fiat_limit: number; crypto_limit: number; allow_all: boolean };

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) {
    return cors;
  }

  try {
    const user = await requireAuthUser(req);
    const body = (await req.json().catch(() => ({}))) as Record<string, unknown>;
    const kindRaw = typeof body.kind === 'string' ? (body.kind as string).trim().toLowerCase() : '';
    if (kindRaw !== 'fiat' && kindRaw !== 'crypto') {
      return jsonError('validation', 'Invalid kind: must be fiat or crypto', 400, { field: 'kind' });
    }
    const kind = kindRaw as 'fiat' | 'crypto';

    const service = getServiceClient();

    const { data: profile, error: profileError } = await service
      .from('profiles')
      .select('plan')
      .eq('user_id', user.id)
      .maybeSingle();
    if (profileError) {
      return jsonError('unknown', 'Failed to load profile', 500);
    }
    const plan = normalizePlan(profile?.plan);

    const { data: limits, error: limitsError } = await service
      .from('plan_limits')
      .select('fiat_limit, crypto_limit, allow_all')
      .eq('plan', plan)
      .maybeSingle();
    if (limitsError) {
      return jsonError('unknown', 'Failed to load plan limits', 500);
    }
    const lim = (limits ?? {}) as PlanLimitsRow;
    const allowAll = Boolean(lim.allow_all);
    const fiatLimit = Number.isFinite(Number(lim.fiat_limit)) ? Number(lim.fiat_limit) : 5;
    const cryptoLimit = Number.isFinite(Number(lim.crypto_limit)) ? Number(lim.crypto_limit) : 5;
    const planLimit = kind === 'fiat' ? fiatLimit : cryptoLimit;

    const { data: assets, error: assetsError } = await service
      .from('assets')
      .select('id, kind, code, name')
      .eq('kind', kind)
      .order('code');
    if (assetsError) {
      return jsonError('unknown', 'Failed to load assets', 500);
    }
    const assetList = (assets ?? []) as AssetRow[];
    if (assetList.length === 0) {
      return json({ items: [] });
    }

    const assetIds = assetList.map((a) => a.id);
    const { data: rankings, error: rankError } = await service
      .from('asset_rankings')
      .select('asset_id, rank')
      .eq('kind', kind)
      .in('asset_id', assetIds);
    if (rankError) {
      return jsonError('unknown', 'Failed to load rankings', 500);
    }
    const rankList = (rankings ?? []) as RankingRow[];
    const rankByAssetId = new Map<string, number>();
    for (const r of rankList) {
      const rank = Number.isFinite(Number(r.rank)) ? Number(r.rank) : 999999;
      if (!rankByAssetId.has(r.asset_id) || rank < (rankByAssetId.get(r.asset_id) ?? 999999)) {
        rankByAssetId.set(r.asset_id, rank);
      }
    }

    const items = assetList
      .map((a) => {
        const rank = rankByAssetId.get(a.id) ?? 999999;
        const isUnlocked = allowAll || rank <= planLimit;
        return {
          id: a.id,
          kind: a.kind,
          code: a.code,
          name: a.name ?? a.code,
          rank,
          is_unlocked: isUnlocked,
        };
      })
      .sort((x, y) => {
        if (x.rank !== y.rank) {
          return x.rank - y.rank;
        }
        return (x.code ?? '').localeCompare(y.code ?? '');
      });

    return json({ items });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unexpected';
    if (message === 'Missing Authorization header' || message === 'Unauthorized') {
      return jsonError('unauthorized', 'Unauthorized', 401);
    }
    return jsonError('unknown', 'Unexpected error', 500);
  }
});
