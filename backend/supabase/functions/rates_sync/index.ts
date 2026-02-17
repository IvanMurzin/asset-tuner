import { handleCors } from '../_shared/cors.ts';
import { getAdminClient } from '../_shared/db.ts';
import { optionalEnv, requiredEnv } from '../_shared/env.ts';
import { numberToAtomic, USD_PRICE_DECIMALS } from '../_shared/money.ts';
import { fromError, ok, ApiHttpError } from '../_shared/responses.ts';
import { FIAT_TOP100 } from '../_shared/fiat_top100.ts';
import { cryptoDecimalsForCoinGeckoId } from '../_shared/crypto_decimals.ts';

type CoinGeckoMarketRow = {
  id: string;
  symbol: string;
  name: string;
  current_price: number;
};

type OerLatestResponse = {
  timestamp: number;
  base: string;
  rates: Record<string, number>;
};

type AssetRow = {
  id: string;
  kind: 'fiat' | 'crypto';
  code: string;
  provider_ref: string;
};

function chunk<T>(rows: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < rows.length; i += size) {
    out.push(rows.slice(i, i + size));
  }
  return out;
}

function ensureSchedulerSecret(req: Request): void {
  const expected = requiredEnv('SCHEDULER_SECRET');
  const provided = req.headers.get('x-scheduler-secret');

  if (!provided || provided !== expected) {
    throw new ApiHttpError(403, 'FORBIDDEN', 'Invalid scheduler secret');
  }
}

function normalizeCryptoCode(raw: string): string {
  return raw.trim().toUpperCase();
}

async function fetchCoinGeckoTop100(): Promise<CoinGeckoMarketRow[]> {
  const apiKey = optionalEnv('COINGECKO_API_KEY');
  const baseUrl = (optionalEnv('COINGECKO_BASE_URL') ?? 'https://api.coingecko.com/api/v3').replace(/\/+$/, '');
  const useProDomain = baseUrl.includes('pro-api.coingecko.com');

  const url = new URL(`${baseUrl}/coins/markets`);
  url.searchParams.set('vs_currency', 'usd');
  url.searchParams.set('order', 'market_cap_desc');
  url.searchParams.set('per_page', '100');
  url.searchParams.set('page', '1');
  url.searchParams.set('sparkline', 'false');

  const headers: Record<string, string> = {};
  if (apiKey) {
    headers[useProDomain ? 'x-cg-pro-api-key' : 'x-cg-demo-api-key'] = apiKey;
  }

  const response = await fetch(url.toString(), { headers });
  if (!response.ok) {
    const details = await response.text().catch(() => '');
    throw new ApiHttpError(502, 'EXTERNAL_API_ERROR', 'Failed to fetch CoinGecko top coins', {
      status: response.status,
      details,
    });
  }

  const rows = (await response.json()) as CoinGeckoMarketRow[];

  const byCode = new Map<string, CoinGeckoMarketRow>();
  for (const row of rows) {
    const code = normalizeCryptoCode(row.symbol);
    if (!code) {
      continue;
    }
    if (!byCode.has(code)) {
      byCode.set(code, row);
    }
    if (byCode.size === 100) {
      break;
    }
  }

  return Array.from(byCode.values());
}

async function fetchOpenExchangeRates(): Promise<OerLatestResponse> {
  const appId = requiredEnv('OPENEXCHANGERATES_APP_ID');
  const url = new URL('https://openexchangerates.org/api/latest.json');
  url.searchParams.set('app_id', appId);
  url.searchParams.set('base', 'USD');

  const response = await fetch(url.toString());
  if (!response.ok) {
    const details = await response.text().catch(() => '');
    throw new ApiHttpError(502, 'EXTERNAL_API_ERROR', 'Failed to fetch OpenExchangeRates latest', {
      status: response.status,
      details,
    });
  }

  return (await response.json()) as OerLatestResponse;
}

async function upsertAssetsAndRates(): Promise<{
  as_of: string;
  fiat_updated: number;
  crypto_updated: number;
  rates_updated: number;
}> {
  const db = getAdminClient();
  const asOf = new Date().toISOString();

  const [cryptoTop100, oerLatest] = await Promise.all([
    fetchCoinGeckoTop100(),
    fetchOpenExchangeRates(),
  ]);

  const fiatAssets = FIAT_TOP100.map((item) => ({
    kind: 'fiat' as const,
    code: item.code,
    name: item.name,
    provider: 'openexchangerates',
    provider_ref: item.code,
    rank: item.rank,
    decimals: item.decimals,
    is_active: true,
  }));

  const cryptoAssets = cryptoTop100.map((item, index) => ({
    kind: 'crypto' as const,
    code: normalizeCryptoCode(item.symbol),
    name: item.name,
    provider: 'coingecko',
    provider_ref: item.id,
    rank: index + 1,
    decimals: cryptoDecimalsForCoinGeckoId(item.id),
    is_active: true,
  }));

  for (const rows of chunk(fiatAssets, 200)) {
    const { error } = await db.from('assets').upsert(rows, { onConflict: 'kind,code' });
    if (error) {
      throw error;
    }
  }

  for (const rows of chunk(cryptoAssets, 200)) {
    const { error } = await db.from('assets').upsert(rows, { onConflict: 'kind,code' });
    if (error) {
      throw error;
    }
  }

  const fiatCodes = fiatAssets.map((item) => item.code);
  const cryptoCodes = cryptoAssets.map((item) => item.code);
  const fiatCodeSet = new Set(fiatCodes);
  const cryptoCodeSet = new Set(cryptoCodes);

  const { data: activeFiatData, error: activeFiatError } = await db
    .from('assets')
    .select('code')
    .eq('kind', 'fiat')
    .eq('is_active', true);
  if (activeFiatError) {
    throw activeFiatError;
  }

  const { data: activeCryptoData, error: activeCryptoError } = await db
    .from('assets')
    .select('code')
    .eq('kind', 'crypto')
    .eq('is_active', true);
  if (activeCryptoError) {
    throw activeCryptoError;
  }

  const staleFiatCodes = ((activeFiatData ?? []) as Array<{ code: string }>).filter((row) =>
    !fiatCodeSet.has(row.code)
  ).map((row) => row.code);

  const staleCryptoCodes = ((activeCryptoData ?? []) as Array<{ code: string }>).filter((row) =>
    !cryptoCodeSet.has(row.code)
  ).map((row) => row.code);

  if (staleFiatCodes.length > 0) {
    const { error: disableFiatError } = await db
      .from('assets')
      .update({ is_active: false })
      .eq('kind', 'fiat')
      .in('code', staleFiatCodes);
    if (disableFiatError) {
      throw disableFiatError;
    }
  }

  if (staleCryptoCodes.length > 0) {
    const { error: disableCryptoError } = await db
      .from('assets')
      .update({ is_active: false })
      .eq('kind', 'crypto')
      .in('code', staleCryptoCodes);
    if (disableCryptoError) {
      throw disableCryptoError;
    }
  }

  const { data: assetsData, error: assetsError } = await db
    .from('assets')
    .select('id, kind, code, provider_ref')
    .in('kind', ['fiat', 'crypto'])
    .eq('is_active', true);

  if (assetsError) {
    throw assetsError;
  }

  const assets = (assetsData ?? []) as AssetRow[];

  const fiatRateByCode = new Map<string, string>();
  fiatRateByCode.set('USD', '1000000000000');
  for (const [code, rawRate] of Object.entries(oerLatest.rates ?? {})) {
    if (code === 'USD') {
      continue;
    }
    const rate = Number(rawRate);
    if (!Number.isFinite(rate) || rate <= 0) {
      continue;
    }
    const usdPrice = 1 / rate;
    fiatRateByCode.set(code.toUpperCase(), numberToAtomic(usdPrice, USD_PRICE_DECIMALS));
  }

  const cryptoRateByCode = new Map<string, string>();
  for (const item of cryptoTop100) {
    if (!Number.isFinite(item.current_price) || item.current_price <= 0) {
      continue;
    }
    cryptoRateByCode.set(
      normalizeCryptoCode(item.symbol),
      numberToAtomic(item.current_price, USD_PRICE_DECIMALS),
    );
  }

  const ratesRows = assets
    .map((asset) => {
      if (asset.kind === 'fiat') {
        const atomic = fiatRateByCode.get(asset.code);
        if (!atomic) {
          return null;
        }
        return {
          asset_id: asset.id,
          usd_price_atomic: atomic,
          usd_price_decimals: USD_PRICE_DECIMALS,
          as_of: asOf,
        };
      }

      const atomic = cryptoRateByCode.get(asset.code);
      if (!atomic) {
        return null;
      }

      return {
        asset_id: asset.id,
        usd_price_atomic: atomic,
        usd_price_decimals: USD_PRICE_DECIMALS,
        as_of: asOf,
      };
    })
    .filter((row): row is { asset_id: string; usd_price_atomic: string; usd_price_decimals: number; as_of: string } => row !== null);

  for (const rows of chunk(ratesRows, 500)) {
    const { error } = await db.from('asset_rates_usd').upsert(rows, { onConflict: 'asset_id' });
    if (error) {
      throw error;
    }
  }

  const { error: recomputeError } = await db.rpc('recompute_all_cached_totals');
  if (recomputeError) {
    throw recomputeError;
  }

  return {
    as_of: asOf,
    fiat_updated: fiatAssets.length,
    crypto_updated: cryptoAssets.length,
    rates_updated: ratesRows.length,
  };
}

Deno.serve(async (req) => {
  const startedAt = Date.now();
  const cors = handleCors(req);
  if (cors) {
    return cors;
  }

  try {
    ensureSchedulerSecret(req);

    const summary = await upsertAssetsAndRates();

    console.log(
      JSON.stringify({
        function: 'rates_sync',
        op: 'sync',
        duration_ms: Date.now() - startedAt,
        ...summary,
      }),
    );

    return ok(summary);
  } catch (error) {
    const failure = fromError(error);

    console.error(
      JSON.stringify({
        function: 'rates_sync',
        op: 'sync_failed',
        error: error instanceof Error ? error.message : 'unknown_error',
        duration_ms: Date.now() - startedAt,
      }),
    );

    return failure;
  }
});
