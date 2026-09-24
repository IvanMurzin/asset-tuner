import { assert, assertEquals } from 'jsr:@std/assert@1';
import { api, dbSelect } from '../lib/client.ts';
import { setPlan, withUsers } from '../lib/users.ts';
import { type Account, assetByCode, createAccount, createSubaccount } from '../lib/fixtures.ts';

Deno.test('accounts: create, update, archive, unarchive, delete', async () => {
  await withUsers(1, async (u) => {
    const account = await createAccount(u, '  Main bank  ', 'bank');
    assertEquals(account.name, 'Main bank', 'name should be trimmed');
    assertEquals(account.archived, false);

    const renamed = await api<Account>(u.token, 'POST', '/accounts/update', {
      accountId: account.id,
      name: 'Renamed',
      type: 'wallet',
    });
    assertEquals(renamed.status, 200, JSON.stringify(renamed.raw));
    assertEquals(renamed.data.name, 'Renamed');
    assertEquals(renamed.data.type, 'wallet');

    const archived = await api<Account>(u.token, 'POST', '/accounts/update', {
      accountId: account.id,
      archived: true,
    });
    assertEquals(archived.data.archived, true);

    const unarchived = await api<Account>(u.token, 'POST', '/accounts/update', {
      accountId: account.id,
      archived: false,
    });
    assertEquals(unarchived.data.archived, false);

    const nothing = await api(u.token, 'POST', '/accounts/update', { accountId: account.id });
    assertEquals(nothing.status, 400);

    const deleted = await api(u.token, 'POST', '/accounts/delete', { accountId: account.id });
    assertEquals(deleted.status, 200);

    const list = await api<Account[]>(u.token, 'GET', '/accounts/list');
    assertEquals(list.data.length, 0);

    const again = await api(u.token, 'POST', '/accounts/delete', { accountId: account.id });
    assertEquals(again.status, 404);
  });
});

Deno.test('accounts: validation', async () => {
  await withUsers(1, async (u) => {
    for (const body of [
      { name: '', type: 'bank' },
      { name: '   ', type: 'bank' },
      { name: 'ok', type: '' },
      { name: 'x'.repeat(121), type: 'bank' },
      { type: 'bank' },
    ]) {
      const res = await api(u.token, 'POST', '/accounts/create', body);
      assertEquals(res.status, 400, JSON.stringify(body));
    }
  });
});

Deno.test('accounts: free limit is 5 and archived accounts count', async () => {
  await withUsers(1, async (u) => {
    const created: Account[] = [];
    for (let i = 0; i < 5; i++) {
      created.push(await createAccount(u, `A${i}`));
    }
    await api(u.token, 'POST', '/accounts/update', { accountId: created[0].id, archived: true });

    const sixth = await api(u.token, 'POST', '/accounts/create', { name: 'A6', type: 'bank' });
    assertEquals(sixth.status, 409, JSON.stringify(sixth.raw));
    assertEquals(sixth.error?.code, 'LIMIT_ACCOUNTS_REACHED');

    await setPlan(u, 'pro');
    const proSixth = await api(u.token, 'POST', '/accounts/create', { name: 'A6', type: 'bank' });
    assertEquals(proSixth.status, 200);
  });
});

Deno.test('accounts: parallel creates cannot exceed the free limit', async () => {
  await withUsers(1, async (u) => {
    for (let i = 0; i < 4; i++) {
      await createAccount(u, `A${i}`);
    }
    const results = await Promise.all(
      Array.from({ length: 4 }, (_, i) =>
        api(u.token, 'POST', '/accounts/create', { name: `P${i}`, type: 'bank' })),
    );
    const list = await api<Account[]>(u.token, 'GET', '/accounts/list');
    assert(
      list.data.length <= 5,
      `race: ${list.data.length} accounts on free (statuses ${results.map((r) => r.status)})`,
    );
  });
});

Deno.test('accounts: delete cascades subaccounts and balance entries', async () => {
  await withUsers(1, async (u) => {
    const usd = await assetByCode(u, 'fiat', 'USD');
    const account = await createAccount(u);
    const sub = await createSubaccount(u, account.id, usd, '1000');
    await api(u.token, 'POST', '/subaccounts/set_balance', {
      subaccountId: sub.id,
      amountAtomic: '2000',
      amountDecimals: usd.decimals,
    });

    assertEquals((await dbSelect('balance_entries', `subaccount_id=eq.${sub.id}&select=id`)).length, 2);

    const res = await api(u.token, 'POST', '/accounts/delete', { accountId: account.id });
    assertEquals(res.status, 200);

    assertEquals((await dbSelect('subaccounts', `account_id=eq.${account.id}&select=id`)).length, 0);
    assertEquals((await dbSelect('balance_entries', `subaccount_id=eq.${sub.id}&select=id`)).length, 0);
  });
});
