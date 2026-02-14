import { handleCors } from '../_shared/cors.ts';
import { requireEnv } from '../_shared/env.ts';
import { json, jsonError } from '../_shared/responses.ts';
import { getServiceClient } from '../_shared/supabase.ts';

type OerLatestResponse = {
  base: string;
  timestamp: number;
  rates: Record<string, number>;
};

type CoinGeckoSimplePrice = Record<string, { usd?: number }>;

type AssetRow = {
  id: string;
  kind: 'fiat' | 'crypto';
  code: string;
  provider_ref: string | null;
};

type FxRateRow = {
  code: string;
  usd_price: string;
  as_of: string;
  source: 'openexchangerates';
};

type CryptoRateRow = {
  coingecko_id: string;
  usd_price: string;
  as_of: string;
  source: 'coingecko';
};

async function checkRatesSecret(req: Request): Promise<boolean> {
  const expected = Deno.env.get('RATES_SYNC_SECRET');
  if (!expected) {
    return false;
  }
  const provided = req.headers.get('x-rates-sync-secret');
  if (provided && provided === expected) {
    return true;
  }

  const body = await req.clone().json().catch(() => null) as Record<string, unknown> | null;
  const bodySecret = body?.secret;
  return typeof bodySecret === 'string' && bodySecret === expected;
}

function chunk<T>(items: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < items.length; i += size) {
    out.push(items.slice(i, i + size));
  }
  return out;
}

function parsePositiveInt(value: string | undefined, fallback: number): number {
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return fallback;
  }
  return Math.floor(parsed);
}

function requireCoinGeckoApiKey(): string {
  const modern = Deno.env.get('COINGECKO_API_KEY');
  if (modern) {
    return modern;
  }
  return requireEnv('COINGEKO_API_KEY');
}

function coinGeckoHeaders(baseUrl: string, apiKey: string): HeadersInit {
  if (baseUrl.includes('pro-api.coingecko.com')) {
    return { 'x-cg-pro-api-key': apiKey };
  }
  return { 'x-cg-demo-api-key': apiKey };
}

function trimTrailingSlash(value: string): string {
  return value.replace(/\/+$/, '');
}

function isCoinGeckoProDomainHint(bodyText: string): boolean {
  return bodyText.includes('"error_code":10010') ||
    bodyText.includes('pro-api.coingecko.com');
}

async function fetchCoinGeckoWithAutoProRetry(
  path: string,
  state: { baseUrl: string },
  apiKey: string,
  buildQuery: (url: URL) => void,
): Promise<{ response: Response; errorBodyText: string | null }> {
  const proBaseUrl = 'https://pro-api.coingecko.com/api/v3';

  const url = new URL(`${state.baseUrl}${path}`);
  buildQuery(url);

  let response = await fetch(url.toString(), {
    headers: coinGeckoHeaders(state.baseUrl, apiKey),
  });
  if (response.ok) {
    return { response, errorBodyText: null };
  }

  const firstErrorBody = await response.text().catch(() => '');
  if (
    response.status === 400 &&
    isCoinGeckoProDomainHint(firstErrorBody) &&
    state.baseUrl !== proBaseUrl
  ) {
    state.baseUrl = proBaseUrl;
    const retryUrl = new URL(`${state.baseUrl}${path}`);
    buildQuery(retryUrl);
    response = await fetch(retryUrl.toString(), {
      headers: coinGeckoHeaders(state.baseUrl, apiKey),
    });
    return { response, errorBodyText: firstErrorBody };
  }

  return { response, errorBodyText: firstErrorBody };
}

function normalizeCode(raw: string): string {
  return raw.trim().toUpperCase();
}

function normalizeCoinGeckoId(raw: string): string | null {
  const id = raw.trim().toLowerCase();
  if (!id) {
    return null;
  }
  // Keep ids URL-safe and predictable for CoinGecko /simple/price.
  if (!/^[a-z0-9._-]+$/.test(id)) {
    return null;
  }
  return id;
}

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) {
    return cors;
  }

  try {
    if (!(await checkRatesSecret(req))) {
      return jsonError('forbidden', 'Forbidden', 403);
    }

    const openExchangeAppId = requireEnv('OPENEXCHANGE_APP_ID');
    const coinGeckoApiKey = requireCoinGeckoApiKey();
    const maxCrypto = parsePositiveInt(Deno.env.get('RATES_SYNC_MAX_CRYPTO') ?? undefined, 100);
    const configuredCoinGeckoBaseUrl = Deno.env.get('COINGECKO_BASE_URL')?.trim();
    const coinGeckoState = {
      baseUrl: trimTrailingSlash(configuredCoinGeckoBaseUrl || 'https://api.coingecko.com/api/v3'),
    };
    const service = getServiceClient();

    const asOf = new Date().toISOString();

    const { data: assetsRaw, error: assetsError } = await service
      .from('assets')
      .select('id, kind, code, provider_ref');
    if (assetsError) {
      return jsonError('unknown', 'Failed to load assets', 500);
    }
    const assets = ((assetsRaw ?? []) as AssetRow[]).filter((row) =>
      row?.id &&
      (row.kind === 'fiat' || row.kind === 'crypto') &&
      typeof row.code === 'string'
    );

    const oerUrl = new URL('https://openexchangerates.org/api/latest.json');
    oerUrl.searchParams.set('app_id', openExchangeAppId);
    oerUrl.searchParams.set('base', 'USD');

    const oerResp = await fetch(oerUrl.toString());
    if (!oerResp.ok) {
      console.error('openexchangerates latest fetch failed', { status: oerResp.status });
      return jsonError('unknown', 'Failed to fetch FX rates', 500, {
        provider: 'openexchangerates',
        status: oerResp.status,
      });
    }
    const oerJson = (await oerResp.json()) as OerLatestResponse;

    const fxByCode = new Map<string, number>();
    fxByCode.set('USD', 1);
    for (const [rawCode, rawRate] of Object.entries(oerJson.rates ?? {})) {
      const code = normalizeCode(rawCode);
      if (!code) {
        continue;
      }
      if (code === 'USD') {
        fxByCode.set('USD', 1);
        continue;
      }
      const rate = Number(rawRate);
      if (!Number.isFinite(rate) || rate <= 0) {
        continue;
      }
      fxByCode.set(code, 1 / rate);
    }

    const fxRows: FxRateRow[] = Array.from(fxByCode.entries()).map(([code, usd_price]) => ({
      code,
      usd_price: String(usd_price),
      as_of: asOf,
      source: 'openexchangerates',
    }));

    for (const rows of chunk(fxRows, 500)) {
      const { error } = await service
        .from('fx_rates_usd')
        .upsert(rows, { onConflict: 'code' });
      if (error) {
        return jsonError('unknown', 'Failed to upsert FX provider rates', 500);
      }
    }

    const { data: topRaw, error: topError } = await service
      .from('cg_top_coins')
      .select('coingecko_id, rank')
      .order('rank', { ascending: true })
      .limit(maxCrypto);
    if (topError) {
      return jsonError('unknown', 'Failed to load CoinGecko top ids cache', 500);
    }

    const topIds = ((topRaw ?? []) as Array<{ coingecko_id: string | null }>)
      .map((r) => r.coingecko_id)
      .filter((v): v is string => typeof v === 'string' && v.length > 0)
      .map((id) => normalizeCoinGeckoId(id))
      .filter((id): id is string => id !== null);

    const assetRefs = assets
      .filter((a) => a.kind === 'crypto' && typeof a.provider_ref === 'string' && a.provider_ref.length > 0)
      .map((a) => normalizeCoinGeckoId(a.provider_ref as string))
      .filter((id): id is string => id !== null);

    const cryptoIds = Array.from(new Set([...topIds, ...assetRefs]));
    const cryptoById = new Map<string, number>();

    if (cryptoIds.length > 0) {
      const simplePriceChunkSize = 100;
      for (const idsChunk of chunk(cryptoIds, simplePriceChunkSize)) {
        const { response: cgResp, errorBodyText } = await fetchCoinGeckoWithAutoProRetry(
          '/simple/price',
          coinGeckoState,
          coinGeckoApiKey,
          (cgUrl) => {
            cgUrl.searchParams.set('ids', idsChunk.join(','));
            cgUrl.searchParams.set('vs_currencies', 'usd');
          },
        );
        if (!cgResp.ok) {
          const responseText = await cgResp.text().catch(() => '');
          const detailSnippet = (responseText || errorBodyText || '').slice(0, 300);
          console.error('coingecko simple/price fetch failed', {
            status: cgResp.status,
            base_url: coinGeckoState.baseUrl,
            ids_chunk_size: idsChunk.length,
            ids_preview: idsChunk.slice(0, 10),
            provider_body: detailSnippet,
          });
          return jsonError('unknown', 'Failed to fetch crypto prices', 500, {
            provider: 'coingecko',
            status: cgResp.status,
            ids_chunk_size: idsChunk.length,
            provider_message: detailSnippet || null,
          });
        }
        const cgJson = (await cgResp.json()) as CoinGeckoSimplePrice;
        for (const id of idsChunk) {
          const usd = Number(cgJson?.[id]?.usd);
          if (Number.isFinite(usd) && usd > 0) {
            cryptoById.set(id, usd);
          }
        }
      }
    }

    const cryptoRows: CryptoRateRow[] = Array.from(cryptoById.entries()).map(([coingecko_id, usd_price]) => ({
      coingecko_id,
      usd_price: String(usd_price),
      as_of: asOf,
      source: 'coingecko',
    }));

    for (const rows of chunk(cryptoRows, 500)) {
      const { error } = await service
        .from('crypto_rates_usd')
        .upsert(rows, { onConflict: 'coingecko_id' });
      if (error) {
        return jsonError('unknown', 'Failed to upsert crypto provider rates', 500);
      }
    }

    const projectedRows = assets
      .map((asset) => {
        if (asset.kind === 'fiat') {
          const usd = fxByCode.get(normalizeCode(asset.code));
          if (!usd || !Number.isFinite(usd) || usd <= 0) {
            return null;
          }
          return {
            asset_id: asset.id,
            usd_price: String(usd),
            as_of: asOf,
          };
        }

        const id = asset.provider_ref;
        if (!id) {
          return null;
        }
        const usd = cryptoById.get(id);
        if (!usd || !Number.isFinite(usd) || usd <= 0) {
          return null;
        }
        return {
          asset_id: asset.id,
          usd_price: String(usd),
          as_of: asOf,
        };
      })
      .filter((row): row is { asset_id: string; usd_price: string; as_of: string } => row !== null);

    for (const rows of chunk(projectedRows, 500)) {
      const { error } = await service
        .from('asset_rates_usd')
        .upsert(rows, { onConflict: 'asset_id' });
      if (error) {
        return jsonError('unknown', 'Failed to upsert projected asset rates', 500);
      }
    }

    console.log('rates_sync complete', {
      as_of: asOf,
      fx_upserted: fxRows.length,
      crypto_upserted: cryptoRows.length,
      projected_asset_rates_upserted: projectedRows.length,
    });

    return json({
      ok: true,
      as_of: asOf,
      fx_upserted: fxRows.length,
      crypto_upserted: cryptoRows.length,
      projected_asset_rates_upserted: projectedRows.length,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unexpected';
    if (message.startsWith('Missing env var:')) {
      return jsonError('unknown', 'Missing required secrets', 500);
    }
    console.error('rates_sync unexpected error', { message });
    return jsonError('unknown', 'Unexpected error', 500);
  }
});
