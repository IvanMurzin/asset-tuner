import { assert, assertEquals } from 'jsr:@std/assert@1';
import { api, dbSelect } from '../lib/client.ts';
import { withUsers } from '../lib/users.ts';
import { assetByCode, createAccount, createSubaccount } from '../lib/fixtures.ts';

Deno.test('contact_developer: validation, default subject, hourly rate limit', async () => {
  await withUsers(1, async (u) => {
    for (const body of [
      { description: 'no name' },
      { name: 'QA', description: '' },
      { name: 'QA', description: 'x', email: 'not-an-email' },
      { name: 'QA', description: 'x'.repeat(5001) },
    ]) {
      const res = await api(u.token, 'POST', '/contact_developer', body);
      assertEquals(res.status, 400, JSON.stringify(body));
    }

    const first = await api<{ id: string; accepted: boolean }>(u.token, 'POST', '/contact_developer', {
      name: 'QA',
      email: u.email,
      description: 'QA regression message, safe to ignore',
    });
    assertEquals(first.status, 200, JSON.stringify(first.raw));
    const rows = await dbSelect<{ subject: string }>('support_messages', `id=eq.${first.data.id}&select=subject`);
    assertEquals(rows[0]?.subject, 'Contact developer');

    for (let i = 0; i < 4; i++) {
      const res = await api(u.token, 'POST', '/contact_developer', { name: 'QA', description: `QA ${i}` });
      assertEquals(res.status, 200);
    }
    const sixth = await api(u.token, 'POST', '/contact_developer', { name: 'QA', description: 'QA 6' });
    assertEquals(sixth.status, 429, JSON.stringify(sixth.raw));
  });
});

Deno.test('delete_my_account: requires confirm and removes the user and data', async () => {
  await withUsers(1, async (u) => {
    const noConfirm = await api(u.token, 'POST', '/delete_my_account', {});
    assertEquals(noConfirm.status, 400);

    const usd = await assetByCode(u, 'fiat', 'USD');
    const account = await createAccount(u);
    await createSubaccount(u, account.id, usd, '1');

    const res = await api(u.token, 'POST', '/delete_my_account', { confirm: true });
    assertEquals(res.status, 200, JSON.stringify(res.raw));

    const after = await api(u.token, 'GET', '/me');
    assert(after.status === 401, `token still works after deletion: ${after.status}`);

    const profiles = await dbSelect('profiles', `user_id=eq.${u.id}&select=user_id`);
    const accounts = await dbSelect('accounts', `user_id=eq.${u.id}&select=id`);
    assertEquals(
      { profiles: profiles.length, accounts: accounts.length },
      { profiles: 0, accounts: 0 },
      'user data survives account deletion (soft delete)',
    );
  }, 'delete');
});
