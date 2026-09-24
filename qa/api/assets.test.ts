import { assert, assertEquals } from 'jsr:@std/assert@1';
import { api } from '../lib/client.ts';
import { setPlan, withUsers } from '../lib/users.ts';
import { type Asset, listAssets } from '../lib/fixtures.ts';

Deno.test('assets: free plan locks rank > 5 for fiat and crypto', async () => {
  await withUsers(1, async (u) => {
    for (const kind of ['fiat', 'crypto'] as const) {
      const assets = await listAssets(u, kind);
      assert(assets.length > 5, `${kind}: expected a catalog, got ${assets.length}`);
      assert(assets.every((a) => a.kind === kind), `${kind}: mixed kinds`);
      for (const a of assets) {
        assertEquals(a.is_locked, a.rank > 5, `${kind}/${a.code} rank=${a.rank}`);
      }
    }
  });
});

Deno.test('assets: pro plan unlocks everything', async () => {
  await withUsers(1, async (u) => {
    await setPlan(u, 'pro');
    for (const kind of ['fiat', 'crypto'] as const) {
      const assets = await listAssets(u, kind);
      assert(assets.every((a) => !a.is_locked), `${kind}: pro user still has locked assets`);
    }
  });
});

Deno.test('assets: core currencies have a USD rate', async () => {
  await withUsers(1, async (u) => {
    const fiat = await listAssets(u, 'fiat');
    const crypto = await listAssets(u, 'crypto');
    const wanted = ['USD', 'EUR', 'GBP', 'BTC', 'ETH', 'USDT'];
    const all = [...fiat, ...crypto] as Array<Asset & { usd_rate?: { usd_price_atomic: string } }>;
    for (const code of wanted) {
      const asset = all.find((a) => a.code === code);
      assert(asset, `${code} missing`);
      const price = asset.usd_rate?.usd_price_atomic;
      assert(price && /^[1-9]\d*$/.test(price), `${code} has no positive USD rate: ${price}`);
    }
  });
});

Deno.test('assets: list without kind returns both fiat and crypto', async () => {
  await withUsers(1, async (u) => {
    const res = await api<Asset[]>(u.token, 'GET', '/assets/list');
    assertEquals(res.status, 200);
    const kinds = new Set(res.data.map((a) => a.kind));
    assert(kinds.has('fiat') && kinds.has('crypto'), `kinds=${[...kinds].join(',')}`);
  });
});
