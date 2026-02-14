import { handleCors } from '../_shared/cors.ts';
import { requireEnv } from '../_shared/env.ts';
import { json, jsonError } from '../_shared/responses.ts';
import { getServiceClient } from '../_shared/supabase.ts';

type CoinGeckoListCoin = {
  id: string;
  symbol: string;
  name: string;
};

type CoinGeckoMarketCoin = {
  id: string;
  symbol: string;
  name: string;
  market_cap_rank: number | null;
  market_cap: number | null;
};

type OerCurrenciesResponse = Record<string, string>;

type AssetRow = {
  id: string;
  kind: 'fiat' | 'crypto';
  code: string;
  provider_ref: string | null;
  name: string;
};

type FiatPriorityRow = {
  code: string;
  rank: number;
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
  return typeof body?.secret === 'string' && body.secret === expected;
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
  buildQuery?: (url: URL) => void,
): Promise<{ response: Response; errorBodyText: string | null }> {
  const proBaseUrl = 'https://pro-api.coingecko.com/api/v3';

  const url = new URL(`${state.baseUrl}${path}`);
  buildQuery?.(url);

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
    buildQuery?.(retryUrl);
    response = await fetch(retryUrl.toString(), {
      headers: coinGeckoHeaders(state.baseUrl, apiKey),
    });
    return { response, errorBodyText: firstErrorBody };
  }

  return { response, errorBodyText: firstErrorBody };
}

function upperCode(raw: string): string {
  return raw.trim().toUpperCase();
}

function isSupportedCryptoCode(code: string): boolean {
  // Keep catalog symbols human-friendly and avoid odd synthetic tickers.
  return /^[A-Z0-9]{2,10}$/.test(code);
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

    const maxCrypto = parsePositiveInt(Deno.env.get('RATES_SYNC_MAX_CRYPTO') ?? undefined, 100);
    const maxFiat = parsePositiveInt(Deno.env.get('RATES_SYNC_MAX_FIAT') ?? undefined, 100);
    const coinGeckoApiKey = requireCoinGeckoApiKey();
    const configuredCoinGeckoBaseUrl = Deno.env.get('COINGECKO_BASE_URL')?.trim();
    const coinGeckoState = {
      baseUrl: trimTrailingSlash(configuredCoinGeckoBaseUrl || 'https://api.coingecko.com/api/v3'),
    };
    const service = getServiceClient();
    const now = new Date().toISOString();

    const { response: coinsResp, errorBodyText: coinsErrorBodyText } = await fetchCoinGeckoWithAutoProRetry(
      '/coins/list',
      coinGeckoState,
      coinGeckoApiKey,
    );
    if (!coinsResp.ok) {
      const providerBody = ((await coinsResp.text().catch(() => '')) || coinsErrorBodyText || '').slice(0, 300);
      console.error('coingecko coins/list fetch failed', { status: coinsResp.status });
      return jsonError('unknown', 'Failed to fetch CoinGecko coins list', 500, {
        provider: 'coingecko',
        status: coinsResp.status,
        provider_message: providerBody || null,
      });
    }

    const coinsList = (await coinsResp.json()) as CoinGeckoListCoin[];
    const coinCacheRows = coinsList
      .filter((coin) => Boolean(coin?.id) && Boolean(coin?.symbol))
      .map((coin) => ({
        coingecko_id: coin.id,
        symbol: coin.symbol,
        symbol_upper: upperCode(coin.symbol),
        name: coin.name || null,
        updated_at: now,
      }));

    for (const rows of chunk(coinCacheRows, 1000)) {
      const { error } = await service
        .from('cg_coins_cache')
        .upsert(rows, { onConflict: 'coingecko_id' });
      if (error) {
        return jsonError('unknown', 'Failed to upsert CoinGecko coins cache', 500);
      }
    }

    const perPage = Math.min(Math.max(maxCrypto * 2, 100), 250);
    const { response: marketsResp, errorBodyText: marketsErrorBodyText } = await fetchCoinGeckoWithAutoProRetry(
      '/coins/markets',
      coinGeckoState,
      coinGeckoApiKey,
      (marketsUrl) => {
        marketsUrl.searchParams.set('vs_currency', 'usd');
        marketsUrl.searchParams.set('order', 'market_cap_desc');
        marketsUrl.searchParams.set('per_page', String(perPage));
        marketsUrl.searchParams.set('page', '1');
        marketsUrl.searchParams.set('sparkline', 'false');
      },
    );
    if (!marketsResp.ok) {
      const providerBody = ((await marketsResp.text().catch(() => '')) || marketsErrorBodyText || '').slice(0, 300);
      console.error('coingecko coins/markets fetch failed', { status: marketsResp.status });
      return jsonError('unknown', 'Failed to fetch CoinGecko top markets', 500, {
        provider: 'coingecko',
        status: marketsResp.status,
        provider_message: providerBody || null,
      });
    }

    const markets = (await marketsResp.json()) as CoinGeckoMarketCoin[];
    const topRowsRaw = markets
      .filter((coin) => Boolean(coin?.id) && Boolean(coin?.symbol))
      .map((coin, index) => ({
        coingecko_id: coin.id,
        symbol_upper: upperCode(coin.symbol),
        name: coin.name || null,
        raw_rank: Number.isFinite(Number(coin.market_cap_rank)) && Number(coin.market_cap_rank) > 0
          ? Number(coin.market_cap_rank)
          : index + 1,
        market_cap: Number.isFinite(Number(coin.market_cap)) && Number(coin.market_cap) > 0
          ? String(Number(coin.market_cap))
          : null,
        updated_at: now,
      }))
      .filter((row) => isSupportedCryptoCode(row.symbol_upper))
      .sort((a, b) => a.raw_rank - b.raw_rank)
      .slice(0, maxCrypto);

    const topRows = topRowsRaw.map((row, index) => ({
      coingecko_id: row.coingecko_id,
      symbol_upper: row.symbol_upper,
      name: row.name,
      rank: index + 1,
      market_cap: row.market_cap,
      updated_at: row.updated_at,
    }));

    for (const rows of chunk(topRows, 500)) {
      const { error } = await service
        .from('cg_top_coins')
        .upsert(rows, { onConflict: 'coingecko_id' });
      if (error) {
        return jsonError('unknown', 'Failed to upsert CoinGecko top coins', 500);
      }
    }

    const { data: fxCodesRaw, error: fxCodesError } = await service
      .from('fx_rates_usd')
      .select('code');
    if (fxCodesError) {
      return jsonError('unknown', 'Failed to load FX provider codes', 500);
    }

    const fxCodes = ((fxCodesRaw ?? []) as Array<{ code: string | null }>)
      .map((row) => row.code)
      .filter((code): code is string => typeof code === 'string' && code.length > 0)
      .map(upperCode)
      .sort();

    const { data: fiatPriorityRaw, error: fiatPriorityError } = await service
      .from('fiat_priority')
      .select('code, rank')
      .order('rank', { ascending: true })
      .limit(maxFiat);
    if (fiatPriorityError) {
      return jsonError('unknown', 'Failed to load fiat priority list', 500);
    }

    const fiatByPriority = ((fiatPriorityRaw ?? []) as FiatPriorityRow[])
      .map((row) => upperCode(row.code))
      .filter((code) => code.length > 0);
    const fxCodeSet = new Set(fxCodes);
    const fiatCodesForAutofill = fiatByPriority.filter((code) => fxCodeSet.has(code));
    if (fiatCodesForAutofill.length < maxFiat) {
      for (const code of fxCodes) {
        if (fiatCodesForAutofill.length >= maxFiat) {
          break;
        }
        if (fiatCodesForAutofill.includes(code)) {
          continue;
        }
        fiatCodesForAutofill.push(code);
      }
    }

    let currenciesByCode: OerCurrenciesResponse = {};
    const currenciesResp = await fetch('https://openexchangerates.org/api/currencies.json');
    if (currenciesResp.ok) {
      const payload = await currenciesResp.json().catch(() => ({}));
      if (payload && typeof payload === 'object') {
        currenciesByCode = payload as OerCurrenciesResponse;
      }
    }

    const { data: existingAssetsRaw, error: existingAssetsError } = await service
      .from('assets')
      .select('id, kind, code, provider_ref, name');
    if (existingAssetsError) {
      return jsonError('unknown', 'Failed to load assets for autofill', 500);
    }

    const existingAssets = ((existingAssetsRaw ?? []) as AssetRow[]).filter((asset) =>
      Boolean(asset?.id) &&
      (asset.kind === 'fiat' || asset.kind === 'crypto') &&
      typeof asset.code === 'string'
    );

    const fiatCodesInAssets = new Set(
      existingAssets
        .filter((asset) => asset.kind === 'fiat')
        .map((asset) => upperCode(asset.code)),
    );

    const fiatMissingRows = fiatCodesForAutofill
      .filter((code) => !fiatCodesInAssets.has(code))
      .map((code) => ({
        kind: 'fiat',
        code,
        name: currenciesByCode[code] || code,
        decimals: 2,
        provider_ref: null,
      }));

    for (const rows of chunk(fiatMissingRows, 500)) {
      const { error } = await service
        .from('assets')
        .upsert(rows, { onConflict: 'kind,code' });
      if (error) {
        return jsonError('unknown', 'Failed to autofill fiat assets', 500);
      }
    }

    const existingCryptoByCode = new Map(
      existingAssets
        .filter((asset) => asset.kind === 'crypto')
        .map((asset) => [upperCode(asset.code), asset] as const),
    );
    const existingCryptoByProviderRef = new Map(
      existingAssets
        .filter((asset) =>
          asset.kind === 'crypto' &&
          typeof asset.provider_ref === 'string' &&
          asset.provider_ref.length > 0
        )
        .map((asset) => [asset.provider_ref as string, asset.id] as const),
    );

    const bestTopBySymbol = new Map<string, {
      coingecko_id: string;
      symbol_upper: string;
      name: string | null;
      rank: number;
    }>();

    for (const row of topRows) {
      const current = bestTopBySymbol.get(row.symbol_upper);
      if (!current || row.rank < current.rank) {
        bestTopBySymbol.set(row.symbol_upper, {
          coingecko_id: row.coingecko_id,
          symbol_upper: row.symbol_upper,
          name: row.name,
          rank: row.rank,
        });
      }
    }

    const cryptoInsertRows: Array<{
      kind: 'crypto';
      code: string;
      name: string;
      decimals: number | null;
      provider_ref: string;
    }> = [];

    const cryptoUpdateRows: Array<{
      id: string;
      provider_ref: string;
      name: string;
      had_provider_ref: boolean;
    }> = [];

    for (const top of bestTopBySymbol.values()) {
      const existing = existingCryptoByCode.get(top.symbol_upper);
      const topName = top.name || top.symbol_upper;

      if (!existing) {
        if (existingCryptoByProviderRef.has(top.coingecko_id)) {
          continue;
        }
        cryptoInsertRows.push({
          kind: 'crypto',
          code: top.symbol_upper,
          name: topName,
          decimals: null,
          provider_ref: top.coingecko_id,
        });
        existingCryptoByProviderRef.set(top.coingecko_id, `insert:${top.symbol_upper}`);
        continue;
      }

      if (existing.provider_ref && existing.provider_ref !== top.coingecko_id) {
        continue;
      }

      const shouldSetProviderRef = !existing.provider_ref;
      const shouldUpdateName = existing.name !== topName;
      const ownerOfProviderRef = existingCryptoByProviderRef.get(top.coingecko_id);
      const providerRefTakenByAnother = Boolean(
        ownerOfProviderRef && ownerOfProviderRef !== existing.id,
      );
      if (shouldSetProviderRef && providerRefTakenByAnother) {
        continue;
      }
      if (shouldSetProviderRef || shouldUpdateName) {
        cryptoUpdateRows.push({
          id: existing.id,
          provider_ref: top.coingecko_id,
          name: topName,
          had_provider_ref: Boolean(existing.provider_ref),
        });
        if (shouldSetProviderRef) {
          existingCryptoByProviderRef.set(top.coingecko_id, existing.id);
        }
      }
    }

    for (const rows of chunk(cryptoInsertRows, 500)) {
      const { error } = await service
        .from('assets')
        .upsert(rows, { onConflict: 'kind,code' });
      if (error) {
        return jsonError('unknown', 'Failed to autofill crypto assets', 500);
      }
    }

    for (const rows of chunk(cryptoUpdateRows, 200)) {
      const { error } = await service
        .from('assets')
        .upsert(
          rows.map((row) => ({
            id: row.id,
            provider_ref: row.provider_ref,
            name: row.name,
          })),
          { onConflict: 'id' },
        );
      if (error) {
        return jsonError('unknown', 'Failed to update crypto provider refs', 500);
      }
    }

    const providerRefUpdates = cryptoUpdateRows.filter((row) => !row.had_provider_ref).length;

    console.log('coingecko_refresh_metadata complete', {
      coins_cache_upserted: coinCacheRows.length,
      top_coins_upserted: topRows.length,
      assets_fiat_inserted: fiatMissingRows.length,
      assets_crypto_inserted: cryptoInsertRows.length,
      assets_provider_ref_updated: providerRefUpdates,
    });

    return json({
      ok: true,
      as_of: now,
      coins_cache_upserted: coinCacheRows.length,
      top_coins_upserted: topRows.length,
      assets_fiat_inserted: fiatMissingRows.length,
      assets_crypto_inserted: cryptoInsertRows.length,
      assets_provider_ref_updated: providerRefUpdates,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unexpected';
    if (message.startsWith('Missing env var:')) {
      return jsonError('unknown', 'Missing required secrets', 500);
    }
    console.error('coingecko_refresh_metadata unexpected error', { message });
    return jsonError('unknown', 'Unexpected error', 500);
  }
});
