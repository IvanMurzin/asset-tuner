import { assert, assertEquals } from 'jsr:@std/assert@1';
import { api, dbSelect, rawFetch } from '../lib/client.ts';
import { env, functionsBase } from '../lib/env.ts';
import { withUsers } from '../lib/users.ts';

const webhookUrl = `${functionsBase}/revenuecat_webhook`;

function webhookEvent(appUserId: string, id = `qa-${crypto.randomUUID()}`) {
  return {
    api_version: '1.0',
    event: {
      id,
      type: 'TEST',
      app_user_id: appUserId,
      event_timestamp_ms: Date.now(),
      entitlement_ids: [],
      environment: 'SANDBOX',
    },
  };
}

async function postWebhook(body: unknown, secret: string | null) {
  const headers: Record<string, string> = { 'Content-Type': 'application/json' };
  if (secret !== null) headers.Authorization = `Bearer ${secret}`;
  return await rawFetch(webhookUrl, { method: 'POST', headers, body: JSON.stringify(body) });
}

Deno.test('webhook: rejects missing or wrong secret', async () => {
  const body = webhookEvent(crypto.randomUUID());
  assertEquals((await postWebhook(body, null)).status, 403);
  assertEquals((await postWebhook(body, 'wrong-secret')).status, 403);
});

Deno.test('webhook: processes once, dedupes replays, keeps free plan', async () => {
  await withUsers(1, async (u) => {
    const body = webhookEvent(u.id);
    const first = await postWebhook(body, env.webhookSecret);
    assertEquals(first.status, 200, JSON.stringify(first.body));
    const result = (first.body as { data: { is_pro: boolean; result: { processed: boolean } } }).data;
    assertEquals(result.is_pro, false);
    assertEquals(result.result.processed, true);

    const replay = await postWebhook(body, env.webhookSecret);
    assertEquals(replay.status, 200);
    const replayResult = (replay.body as { data: { result: { reason: string } } }).data.result;
    assertEquals(replayResult.reason, 'duplicate');

    const me = await api<{ profile: { plan: string } }>(u.token, 'GET', '/me');
    assertEquals(me.data.profile.plan, 'free');
  }, 'webhook');
});

Deno.test('webhook: unknown app user asks RevenueCat to retry (503)', async () => {
  const res = await postWebhook(webhookEvent(crypto.randomUUID()), env.webhookSecret);
  assertEquals(res.status, 503, JSON.stringify(res.body));
});

Deno.test('webhook: TRANSFER without app_user_id is handled', async () => {
  const body = {
    api_version: '1.0',
    event: {
      id: `qa-${crypto.randomUUID()}`,
      type: 'TRANSFER',
      event_timestamp_ms: Date.now(),
      transferred_from: [crypto.randomUUID()],
      transferred_to: [crypto.randomUUID()],
      environment: 'SANDBOX',
    },
  };
  const res = await postWebhook(body, env.webhookSecret);
  assert(res.status !== 400, `TRANSFER rejected: ${res.status} ${JSON.stringify(res.body)}`);
});

Deno.test('revenuecat/refresh: free user stays free, one ledger row per user', async () => {
  await withUsers(1, async (u) => {
    for (let i = 0; i < 2; i++) {
      const res = await api<{ appUserId: string; isPro: boolean }>(u.token, 'POST', '/revenuecat/refresh');
      assertEquals(res.status, 200, JSON.stringify(res.raw));
      assertEquals(res.data.appUserId, u.id);
      assertEquals(res.data.isPro, false);
    }
    const rows = await dbSelect('webhook_events', `external_id=eq.refresh:${u.id}&select=id`);
    assertEquals(rows.length, 1);
  }, 'refresh');
});

Deno.test('rates_sync: rejects missing or wrong scheduler secret', async () => {
  const url = `${functionsBase}/rates_sync`;
  const none = await rawFetch(url, { method: 'POST' });
  assertEquals(none.status, 403);
  const wrong = await rawFetch(url, { method: 'POST', headers: { 'x-scheduler-secret': 'nope' } });
  assertEquals(wrong.status, 403);
});

Deno.test('security: api_* RPCs are not callable through PostgREST with the publishable key', async () => {
  await withUsers(1, async (u) => {
    // Uses the QA user's own id: proves exposure without touching anyone else's data.
    const probes: Array<[string, Record<string, unknown>]> = [
      ['api_get_me', { p_user_id: u.id }],
      ['api_list_accounts', { p_user_id: u.id }],
      ['api_create_account', { p_user_id: u.id, p_name: 'QA RPC probe', p_type: 'bank' }],
      ['api_update_account', {
        p_user_id: u.id,
        p_account_id: crypto.randomUUID(),
        p_name: null,
        p_type: null,
        p_archived: null,
      }],
    ];
    const exposed: string[] = [];
    for (const [fn, args] of probes) {
      const res = await rawFetch(`${env.supabaseUrl}/rest/v1/rpc/${fn}`, {
        method: 'POST',
        headers: { apikey: env.publishableKey, 'Content-Type': 'application/json' },
        body: JSON.stringify(args),
      });
      const text = JSON.stringify(res.body);
      // 401/403/404 (or PostgREST permission errors) mean the function is not executable.
      const denied = [401, 403, 404].includes(res.status) || /permission denied/i.test(text);
      if (!denied) exposed.push(`${fn} -> ${res.status} ${text.slice(0, 120)}`);
    }
    assertEquals(exposed, [], `exposed RPCs:\n${exposed.join('\n')}`);
  }, 'rpc');
});
