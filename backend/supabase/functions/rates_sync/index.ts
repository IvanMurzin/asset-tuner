import { handleCors } from '../_shared/cors.ts';
import { requireEnv } from '../_shared/env.ts';
import { json, jsonError } from '../_shared/responses.ts';
import { getServiceClient } from '../_shared/supabase.ts';

type OerLatestResponse = {
  base: string;
  timestamp: number;
  rates: Record<string, number>;
};

type CoinGeckoSimplePrice = Record<string, { usd: number }>;

type CoinGeckoCoin = { id: string; symbol: string; name: string };

const cryptoIdOverridesByCode: Record<string, string> = {
  BTC: 'bitcoin',
  ETH: 'ethereum',
  USDT: 'tether',
  SOL: 'solana',
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
    const coinGeckoApiKey = requireEnv('COINGEKO_API_KEY');
    const service = getServiceClient();

    const asOf = new Date().toISOString();

    const { data: assets, error: assetsError } = await service
      .from('assets')
      .select('id, kind, code');
    if (assetsError) {
      return jsonError('unknown', 'Failed to load assets', 500);
    }

    const fiatCodes = new Set(
      (assets ?? [])
        .filter((a: any) => a.kind === 'fiat' && typeof a.code === 'string')
        .map((a: any) => String(a.code)),
    );
    fiatCodes.add('USD');

    // OpenExchangeRates: base is USD (free tier).
    const oerUrl = new URL('https://openexchangerates.org/api/latest.json');
    oerUrl.searchParams.set('app_id', openExchangeAppId);
    oerUrl.searchParams.set('base', 'USD');

    const oerResp = await fetch(oerUrl.toString());
    if (!oerResp.ok) {
      return jsonError('unknown', 'Failed to fetch FX rates', 500, {
        provider: 'openexchangerates',
        status: oerResp.status,
      });
    }
    const oerJson = (await oerResp.json()) as OerLatestResponse;

    const fxUsdPriceByCode = new Map<string, string>();
    fxUsdPriceByCode.set('USD', '1');
    for (const code of fiatCodes) {
      if (code === 'USD') {
        continue;
      }
      const rate = oerJson.rates?.[code];
      if (typeof rate !== 'number' || !Number.isFinite(rate) || rate <= 0) {
        continue;
      }
      // OER: rate is <code> per 1 USD. We need USD per 1 <code>.
      fxUsdPriceByCode.set(code, String(1 / rate));
    }

    const cryptoCodes = Array.from(
      new Set(
        (assets ?? [])
          .filter((a: any) => a.kind === 'crypto' && typeof a.code === 'string')
          .map((a: any) => String(a.code)),
      ),
    );

    const cryptoUsdByCode = new Map<string, string>();
    if (cryptoCodes.length > 0) {
      const maxCrypto = Number(Deno.env.get('RATES_SYNC_MAX_CRYPTO') ?? '250');
      const limitedCryptoCodes = cryptoCodes.slice().sort().slice(0, maxCrypto);

      const cgHeaders = { 'x-cg-demo-api-key': coinGeckoApiKey };

      const cgCoinsResp = await fetch('https://api.coingecko.com/api/v3/coins/list', {
        headers: cgHeaders,
      });
      if (!cgCoinsResp.ok) {
        return jsonError('unknown', 'Failed to load CoinGecko coins list', 500, {
          provider: 'coingecko',
          status: cgCoinsResp.status,
        });
      }
      const cgCoins = (await cgCoinsResp.json()) as CoinGeckoCoin[];

      const cryptoCodeSet = new Set(limitedCryptoCodes);
      const idByCode = new Map<string, string>();
      for (const [code, id] of Object.entries(cryptoIdOverridesByCode)) {
        if (cryptoCodeSet.has(code)) {
          idByCode.set(code, id);
        }
      }

      for (const coin of cgCoins) {
        const symbol = (coin.symbol ?? '').toString().toUpperCase();
        if (!symbol || !cryptoCodeSet.has(symbol) || idByCode.has(symbol)) {
          continue;
        }
        idByCode.set(symbol, coin.id);
      }

      const ids = Array.from(new Set(Array.from(idByCode.values())));
      for (const idsChunk of chunk(ids, 200)) {
        const cgUrl = new URL('https://api.coingecko.com/api/v3/simple/price');
        cgUrl.searchParams.set('ids', idsChunk.join(','));
        cgUrl.searchParams.set('vs_currencies', 'usd');
        const cgResp = await fetch(cgUrl.toString(), { headers: cgHeaders });
        if (!cgResp.ok) {
          return jsonError('unknown', 'Failed to fetch crypto prices', 500, {
            provider: 'coingecko',
            status: cgResp.status,
          });
        }
        const cgJson = (await cgResp.json()) as CoinGeckoSimplePrice;
        for (const code of limitedCryptoCodes) {
          const id = idByCode.get(code);
          if (!id) continue;
          const usd = cgJson?.[id]?.usd;
          if (typeof usd === 'number' && Number.isFinite(usd) && usd > 0) {
            cryptoUsdByCode.set(code, String(usd));
          }
        }
      }
    }

    let upserted = 0;
    for (const asset of assets ?? []) {
      const code = String(asset.code);
      const kind = String(asset.kind);
      let usdPrice: string | null = null;
      if (kind === 'fiat') {
        usdPrice = fxUsdPriceByCode.get(code) ?? null;
      } else if (kind === 'crypto') {
        usdPrice = cryptoUsdByCode.get(code) ?? null;
      }
      if (!usdPrice) {
        continue;
      }

      const { error: upsertError } = await service
        .from('asset_rates_usd')
        .upsert(
          { asset_id: asset.id, usd_price: usdPrice, as_of: asOf },
          { onConflict: 'asset_id' },
        );

      if (upsertError) {
        return jsonError('unknown', 'Failed to upsert rates', 500, { asset_id: asset.id });
      }
      upserted += 1;
    }

    return json({ ok: true, as_of: asOf, upserted });
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unexpected';
    if (message.startsWith('Missing env var:')) {
      return jsonError('unknown', 'Missing required secrets', 500);
    }
    return jsonError('unknown', 'Unexpected error', 500);
  }
});
