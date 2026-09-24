import { assert, assertEquals } from 'jsr:@std/assert@1';
import { api, dbSelect } from '../lib/client.ts';
import { setPlan, withUsers } from '../lib/users.ts';
import {
  assetByCode,
  createAccount,
  createSubaccount,
  lockedAsset,
  setBalance,
  type Subaccount,
} from '../lib/fixtures.ts';

Deno.test('subaccounts: create fiat and crypto, rename, archive, delete', async () => {
  await withUsers(1, async (u) => {
    const account = await createAccount(u);
    const usd = await assetByCode(u, 'fiat', 'USD');
    const btc = await assetByCode(u, 'crypto', 'BTC');

    const fiatSub = await createSubaccount(u, account.id, usd, '12345');
    assertEquals(fiatSub.current_amount_atomic, '12345');
    assertEquals(fiatSub.current_amount_decimals, usd.decimals);

    const btcSub = await createSubaccount(u, account.id, btc, '150000000', 'Cold wallet');
    assertEquals(btcSub.current_amount_decimals, 8);

    const initial = await dbSelect<{ note: string }>(
      'balance_entries',
      `subaccount_id=eq.${btcSub.id}&select=note`,
    );
    assertEquals(initial.length, 1, 'initial balance entry');

    const renamed = await api<Subaccount>(u.token, 'POST', '/subaccounts/update', {
      subaccountId: btcSub.id,
      name: 'Ledger',
    });
    assertEquals(renamed.data.name, 'Ledger');

    const archived = await api<Subaccount>(u.token, 'POST', '/subaccounts/update', {
      subaccountId: btcSub.id,
      archived: true,
    });
    assertEquals(archived.data.archived, true);

    const del = await api(u.token, 'POST', '/subaccounts/delete', { subaccountId: fiatSub.id });
    assertEquals(del.status, 200);

    const list = await api<Subaccount[]>(u.token, 'GET', `/subaccounts/list?accountId=${account.id}`);
    assertEquals(list.data.map((s) => s.id), [btcSub.id]);
  });
});

Deno.test('subaccounts: amount and decimals validation', async () => {
  await withUsers(1, async (u) => {
    const account = await createAccount(u);
    const usd = await assetByCode(u, 'fiat', 'USD');
    const base = { accountId: account.id, assetId: usd.id, name: 'x' };
    const cases: Array<[string, Record<string, unknown>]> = [
      ['decimal point', { initialAmountAtomic: '1.5', initialAmountDecimals: usd.decimals }],
      ['letters', { initialAmountAtomic: 'abc', initialAmountDecimals: usd.decimals }],
      ['empty', { initialAmountAtomic: '', initialAmountDecimals: usd.decimals }],
      ['decimals 19', { initialAmountAtomic: '1', initialAmountDecimals: 19 }],
      ['fractional decimals', { initialAmountAtomic: '1', initialAmountDecimals: 2.5 }],
      ['decimals mismatch', { initialAmountAtomic: '1', initialAmountDecimals: usd.decimals + 1 }],
      ['empty name', { name: ' ', initialAmountAtomic: '1', initialAmountDecimals: usd.decimals }],
    ];
    for (const [label, extra] of cases) {
      const res = await api(u.token, 'POST', '/subaccounts/create', { ...base, ...extra });
      assertEquals(res.status, 400, `${label}: ${JSON.stringify(res.raw)}`);
    }

    const negative = await api(u.token, 'POST', '/subaccounts/create', {
      ...base,
      initialAmountAtomic: '-500',
      initialAmountDecimals: usd.decimals,
    });
    assertEquals(negative.status, 200, 'negative balances (debts) are allowed');

    const unknownAsset = await api(u.token, 'POST', '/subaccounts/create', {
      ...base,
      assetId: crypto.randomUUID(),
      initialAmountAtomic: '1',
      initialAmountDecimals: 2,
    });
    assertEquals(unknownAsset.status, 404);
  });
});

Deno.test('subaccounts: locked asset is 403 on free, allowed on pro', async () => {
  await withUsers(1, async (u) => {
    const account = await createAccount(u);
    for (const kind of ['fiat', 'crypto'] as const) {
      const asset = await lockedAsset(u, kind);
      const res = await api(u.token, 'POST', '/subaccounts/create', {
        accountId: account.id,
        assetId: asset.id,
        name: 'locked',
        initialAmountAtomic: '1',
        initialAmountDecimals: asset.decimals,
      });
      assertEquals(res.status, 403, `${kind}/${asset.code}: ${JSON.stringify(res.raw)}`);
      assertEquals(res.error?.code, 'ASSET_NOT_ALLOWED_FOR_PLAN');
    }
    await setPlan(u, 'pro');
    const asset = await lockedAsset(u, 'crypto').catch(() => null);
    // lockedAsset looks for rank > 5; for pro is_locked is false but rank is unchanged.
    assert(asset);
    await createSubaccount(u, account.id, asset, '1');
  });
});

Deno.test('subaccounts: free limit is 15 across all accounts, archived included', async () => {
  await withUsers(1, async (u) => {
    const usd = await assetByCode(u, 'fiat', 'USD');
    const a1 = await createAccount(u, 'A1');
    const a2 = await createAccount(u, 'A2');
    const subs: Subaccount[] = [];
    for (let i = 0; i < 15; i++) {
      subs.push(await createSubaccount(u, i < 8 ? a1.id : a2.id, usd, `${i + 1}`, `S${i}`));
    }
    await api(u.token, 'POST', '/subaccounts/update', { subaccountId: subs[0].id, archived: true });

    const res = await api(u.token, 'POST', '/subaccounts/create', {
      accountId: a2.id,
      assetId: usd.id,
      name: 'S16',
      initialAmountAtomic: '1',
      initialAmountDecimals: usd.decimals,
    });
    assertEquals(res.status, 409, JSON.stringify(res.raw));
    assertEquals(res.error?.code, 'LIMIT_SUBACCOUNTS_REACHED');
  });
});

Deno.test('balance: set, unchanged rejection, current amount follows', async () => {
  await withUsers(1, async (u) => {
    const account = await createAccount(u);
    const usd = await assetByCode(u, 'fiat', 'USD');
    const sub = await createSubaccount(u, account.id, usd, '1000');

    const same = await setBalance(u, sub, '1000');
    assertEquals(same.status, 400, 'unchanged initial amount must be rejected');

    const changed = await setBalance(u, sub, '2500');
    assertEquals(changed.status, 200, JSON.stringify(changed.raw));

    const again = await setBalance(u, sub, '2500');
    assertEquals(again.status, 400);

    const list = await api<Subaccount[]>(u.token, 'GET', `/subaccounts/list?accountId=${account.id}`);
    assertEquals(list.data[0].current_amount_atomic, '2500');

    const wrongDecimals = await api(u.token, 'POST', '/subaccounts/set_balance', {
      subaccountId: sub.id,
      amountAtomic: '1',
      amountDecimals: usd.decimals + 1,
    });
    assertEquals(wrongDecimals.status, 400);

    const longNote = await api(u.token, 'POST', '/subaccounts/set_balance', {
      subaccountId: sub.id,
      amountAtomic: '3',
      amountDecimals: usd.decimals,
      note: 'x'.repeat(1001),
    });
    assertEquals(longNote.status, 400);
  });
});

Deno.test('balance: numerically equal amounts with different text are rejected', async () => {
  await withUsers(1, async (u) => {
    const account = await createAccount(u);
    const usd = await assetByCode(u, 'fiat', 'USD');
    const sub = await createSubaccount(u, account.id, usd, '100');
    const leadingZero = await setBalance(u, sub, '0100');
    assertEquals(leadingZero.status, 400, `'0100' accepted as a change from '100'`);
  });
});

Deno.test('balance: account totals reflect subaccounts (archived excluded)', async () => {
  await withUsers(1, async (u) => {
    const account = await createAccount(u);
    const usd = await assetByCode(u, 'fiat', 'USD');
    const s1 = await createSubaccount(u, account.id, usd, '10000');
    await createSubaccount(u, account.id, usd, '5000');
    await api(u.token, 'POST', '/subaccounts/update', { subaccountId: s1.id, archived: true });

    type Totals = { total_usd_atomic: string; total_usd_decimals: number };
    type Cache = { cached_total_usd_atomic: string; cached_total_usd_decimals: number };
    const list = await api<Array<{ totals: Totals; cache: Cache }>>(u.token, 'GET', '/accounts/list');
    const { totals, cache } = list.data[0];
    const toNumber = (atomic: string, decimals: number) => Number(atomic) / 10 ** decimals;
    const live = toNumber(totals.total_usd_atomic, totals.total_usd_decimals);
    const cached = toNumber(cache.cached_total_usd_atomic, cache.cached_total_usd_decimals);
    const expected = toNumber('5000', usd.decimals);
    assertEquals(live, expected, 'live total must exclude the archived subaccount');
    // Cache and live totals should follow the same archived rule.
    assertEquals(cached, live, `cache=${cached} live=${live}`);
  });
});
