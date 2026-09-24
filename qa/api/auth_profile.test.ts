import { assertEquals } from 'jsr:@std/assert@1';
import { api } from '../lib/client.ts';
import { setPlan, withUsers } from '../lib/users.ts';
import { assetByCode, createAccount, createSubaccount, lockedAsset } from '../lib/fixtures.ts';

Deno.test('auth: missing or garbage token is rejected with 401', async () => {
  const missing = await api(null, 'GET', '/me');
  assertEquals(missing.status, 401);

  // Rejected by the platform JWT gateway (verify_jwt), so the body is not the API envelope.
  const garbage = await api('not-a-jwt', 'GET', '/me');
  assertEquals(garbage.status, 401);
});

Deno.test('auth: unknown route returns 404', async () => {
  await withUsers(1, async (u) => {
    const res = await api(u.token, 'GET', '/does/not/exist');
    assertEquals(res.status, 404);
    assertEquals(res.error?.code, 'NOT_FOUND');
  });
});

Deno.test('profile: /me for a new user is free with free limits', async () => {
  await withUsers(1, async (u) => {
    const res = await api<{
      profile: { user_id: string; plan: string; base_asset_id: string | null };
      limits: Record<string, number | null>;
      baseAsset: { code: string } | null;
    }>(u.token, 'GET', '/me');
    assertEquals(res.status, 200);
    assertEquals(res.data.profile.user_id, u.id);
    assertEquals(res.data.profile.plan, 'free');
    assertEquals(res.data.limits.max_accounts, 5);
    assertEquals(res.data.limits.max_subaccounts, 15);
    assertEquals(res.data.limits.fiat_limit, 5);
    assertEquals(res.data.limits.crypto_limit, 5);
    // Backend leaves base asset empty; the client's EnsureProfileReadyUseCase sets USD.
    assertEquals(res.data.profile.base_asset_id, null);
  });
});

Deno.test('isolation: user B cannot read or mutate user A data', async () => {
  await withUsers(2, async (a, b) => {
    const usd = await assetByCode(a, 'fiat', 'USD');
    const account = await createAccount(a);
    const sub = await createSubaccount(a, account.id, usd);

    const calls: Array<[string, 'GET' | 'POST', string, unknown?]> = [
      ['subaccounts/list', 'GET', `/subaccounts/list?accountId=${account.id}`],
      ['subaccounts/history', 'GET', `/subaccounts/history?subaccountId=${sub.id}`],
      ['accounts/update', 'POST', '/accounts/update', { accountId: account.id, name: 'x' }],
      ['subaccounts/update', 'POST', '/subaccounts/update', { subaccountId: sub.id, name: 'x' }],
      ['subaccounts/set_balance', 'POST', '/subaccounts/set_balance', {
        subaccountId: sub.id,
        amountAtomic: '5',
        amountDecimals: sub.current_amount_decimals,
      }],
      ['subaccounts/create', 'POST', '/subaccounts/create', {
        accountId: account.id,
        assetId: usd.id,
        name: 'x',
        initialAmountAtomic: '1',
        initialAmountDecimals: usd.decimals,
      }],
      ['subaccounts/delete', 'POST', '/subaccounts/delete', { subaccountId: sub.id }],
      ['accounts/delete', 'POST', '/accounts/delete', { accountId: account.id }],
    ];

    for (const [name, method, path, body] of calls) {
      const res = await api(b.token, method, path, body);
      assertEquals(res.status, 404, `${name}: ${JSON.stringify(res.raw)}`);
    }

    const bList = await api<unknown[]>(b.token, 'GET', '/accounts/list');
    assertEquals(bList.data.length, 0);

    const aList = await api<Array<{ id: string; name: string }>>(a.token, 'GET', '/accounts/list');
    assertEquals(aList.data.length, 1);
    assertEquals(aList.data[0].name, account.name);
  });
});

Deno.test('base asset: free plan rules, pro unlocks crypto', async () => {
  await withUsers(1, async (u) => {
    const eur = await assetByCode(u, 'fiat', 'EUR');
    const ok = await api<{ base_asset_id: string }>(u.token, 'POST', '/profile/update', {
      baseAssetId: eur.id,
    });
    assertEquals(ok.status, 200, JSON.stringify(ok.raw));

    const lockedFiat = await lockedAsset(u, 'fiat');
    const denied = await api(u.token, 'POST', '/profile/update', { baseAssetId: lockedFiat.id });
    assertEquals(denied.status, 403, JSON.stringify(denied.raw));
    assertEquals(denied.error?.code, 'ASSET_NOT_ALLOWED_FOR_PLAN');

    const btc = await assetByCode(u, 'crypto', 'BTC');
    const cryptoDenied = await api(u.token, 'POST', '/profile/update', { baseAssetId: btc.id });
    assertEquals(cryptoDenied.status, 403);

    const unknown = await api(u.token, 'POST', '/profile/update', {
      baseAssetId: crypto.randomUUID(),
    });
    assertEquals(unknown.status, 404);

    const invalid = await api(u.token, 'POST', '/profile/update', { baseAssetId: 'nope' });
    assertEquals(invalid.status, 400);

    await setPlan(u, 'pro');
    const proOk = await api(u.token, 'POST', '/profile/update', { baseAssetId: btc.id });
    assertEquals(proOk.status, 200, JSON.stringify(proOk.raw));

    const me = await api<{ baseAsset: { code: string } }>(u.token, 'GET', '/me');
    assertEquals(me.data.baseAsset.code, 'BTC');
  });
});
