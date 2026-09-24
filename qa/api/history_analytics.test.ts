import { assert, assertEquals } from 'jsr:@std/assert@1';
import { api } from '../lib/client.ts';
import { withUsers } from '../lib/users.ts';
import { assetByCode, createAccount, createSubaccount, setBalance } from '../lib/fixtures.ts';

type HistoryItem = { id: string; amount_atomic: string; created_at: string; diff_amount: number | null };

Deno.test('history: cursor pagination returns every entry exactly once', async () => {
  await withUsers(1, async (u) => {
    const account = await createAccount(u);
    const usd = await assetByCode(u, 'fiat', 'USD');
    const sub = await createSubaccount(u, account.id, usd, '1');
    const total = 12;
    for (let i = 2; i <= total; i++) {
      const res = await setBalance(u, sub, `${i}`);
      assertEquals(res.status, 200);
    }

    const seen: HistoryItem[] = [];
    let cursor: string | null = null;
    for (let page = 0; page < 10; page++) {
      const q: string = `/subaccounts/history?subaccountId=${sub.id}&limit=5` +
        (cursor ? `&cursor=${encodeURIComponent(cursor)}` : '');
      const res = await api<HistoryItem[]>(u.token, 'GET', q);
      assertEquals(res.status, 200, JSON.stringify(res.raw));
      seen.push(...res.data);
      cursor = (res.meta?.nextCursor as string | null) ?? null;
      if (!cursor) break;
    }

    const amounts = seen.map((i) => i.amount_atomic);
    assertEquals(new Set(seen.map((i) => i.id)).size, seen.length, 'duplicates across pages');
    assertEquals(amounts.length, total, `missing entries: got ${amounts.join(',')}`);
    assertEquals(amounts[0], `${total}`, 'newest first');

    // diff_amount is in asset units: +1 atomic USD cent = 0.01. The oldest entry has no diff.
    assertEquals(seen[0].diff_amount, 1 / 10 ** usd.decimals);
    assertEquals(seen[seen.length - 1].diff_amount, null);
  });
});

Deno.test('history: invalid params', async () => {
  await withUsers(1, async (u) => {
    const bad = await api(u.token, 'GET', '/subaccounts/history?subaccountId=nope');
    assertEquals(bad.status, 400);
    const account = await createAccount(u);
    const usd = await assetByCode(u, 'fiat', 'USD');
    const sub = await createSubaccount(u, account.id, usd, '1');
    const badCursor = await api(u.token, 'GET', `/subaccounts/history?subaccountId=${sub.id}&cursor=zzz`);
    assertEquals(badCursor.status, 400);
  });
});

type Summary = {
  base_currency: string;
  breakdown: Array<{ asset_code: string; value_atomic: string; value_decimals: number }>;
  updates: Array<{ asset_code: string; diff_atomic: string }>;
};

Deno.test('analytics: empty user, USD base default', async () => {
  await withUsers(1, async (u) => {
    const res = await api<Summary>(u.token, 'GET', '/analytics/summary');
    assertEquals(res.status, 200, JSON.stringify(res.raw));
    assertEquals(res.data.base_currency, 'USD');
    assertEquals(res.data.breakdown.length, 0);
    assertEquals(res.data.updates.length, 0);
  });
});

Deno.test('analytics: breakdown and updates in USD and EUR base', async () => {
  await withUsers(1, async (u) => {
    const account = await createAccount(u);
    const usd = await assetByCode(u, 'fiat', 'USD');
    const eur = await assetByCode(u, 'fiat', 'EUR');
    const btc = await assetByCode(u, 'crypto', 'BTC');
    const s1 = await createSubaccount(u, account.id, usd, '10000');
    await createSubaccount(u, account.id, btc, '10000000');
    await createSubaccount(u, account.id, eur, '0', 'Zero EUR');
    await setBalance(u, s1, '20000');

    const usdRes = await api<Summary>(u.token, 'GET', '/analytics/summary');
    assertEquals(usdRes.status, 200, JSON.stringify(usdRes.raw));
    const codes = usdRes.data.breakdown.map((b) => b.asset_code).sort();
    assertEquals(codes, ['BTC', 'USD'], 'zero-balance EUR must be excluded');
    assert(usdRes.data.updates.some((x) => x.asset_code === 'USD'), 'USD update in feed');

    await api(u.token, 'POST', '/profile/update', { baseAssetId: eur.id });
    const eurRes = await api<Summary>(u.token, 'GET', '/analytics/summary');
    assertEquals(eurRes.status, 200, JSON.stringify(eurRes.raw));
    assertEquals(eurRes.data.base_currency, 'EUR');
  });
});

Deno.test('analytics: updatesLimit is capped and bad values fall back', async () => {
  await withUsers(1, async (u) => {
    const big = await api(u.token, 'GET', '/analytics/summary?updatesLimit=100000');
    assertEquals(big.status, 200);
    assertEquals(big.meta?.updatesLimit, 500);
    const neg = await api(u.token, 'GET', '/analytics/summary?updatesLimit=-1');
    assertEquals(neg.status, 200);
  });
});
