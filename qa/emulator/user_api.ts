// Acts as an app user through the public API (publishable key + the user's own password).
// No service secrets are used, so it can run without qa/run.sh.
//
//   deno run --allow-net --allow-read qa/emulator/user_api.ts <creds-file> seed-subaccounts <account-name> <count>
//   deno run --allow-net --allow-read qa/emulator/user_api.ts <creds-file> seed-accounts <count>
//   deno run --allow-net --allow-read qa/emulator/user_api.ts <creds-file> seed-history <account-name> <subaccount-name> <count>
//   deno run --allow-net --allow-read qa/emulator/user_api.ts <creds-file> revoke-sessions
//
// <creds-file> holds two lines: email, password. Keep it outside the repository.

type Json = Record<string, unknown>;

const cfg = JSON.parse(await Deno.readTextFile('.config.dev.json'));
const [credsFile, command, ...rest] = Deno.args;
const [email, password] = (await Deno.readTextFile(credsFile)).trim().split('\n');
const base = cfg.SUPABASE_URL as string;
const headers = { apikey: cfg.SUPABASE_PUBLISHABLE_KEY as string, 'Content-Type': 'application/json' };

const session = await (await fetch(`${base}/auth/v1/token?grant_type=password`, {
  method: 'POST',
  headers,
  body: JSON.stringify({ email, password }),
})).json();
if (!session.access_token) throw new Error(`sign in failed: ${JSON.stringify(session)}`);
const auth = { ...headers, Authorization: `Bearer ${session.access_token}` };

async function call(method: string, path: string, body?: unknown): Promise<Json> {
  const res = await fetch(`${base}/functions/v1/api${path}`, {
    method,
    headers: auth,
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  return await res.json();
}

async function account(name: string): Promise<Json> {
  const list = (await call('GET', '/accounts/list')).data as Json[];
  const found = list.find((a) => a.name === name);
  if (!found) throw new Error(`account "${name}" not found`);
  return found;
}

async function usd(): Promise<Json> {
  const list = (await call('GET', '/assets/list?kind=fiat')).data as Json[];
  return list.find((a) => a.code === 'USD')!;
}

switch (command) {
  case 'seed-accounts': {
    for (let i = 0; i < Number(rest[0]); i++) {
      const r = await call('POST', '/accounts/create', { name: `Seed account ${i + 1}`, type: 'bank' });
      if (!r.ok) console.log('fail', i, JSON.stringify(r.error));
    }
    console.log('accounts now:', ((await call('GET', '/accounts/list')).data as Json[]).length);
    break;
  }
  case 'seed-subaccounts': {
    const acc = await account(rest[0]);
    const asset = await usd();
    for (let i = 0; i < Number(rest[1]); i++) {
      const r = await call('POST', '/subaccounts/create', {
        accountId: acc.id,
        assetId: asset.id,
        name: `Seed ${i + 1}`,
        initialAmountAtomic: `${(i + 1) * 100}`,
        initialAmountDecimals: asset.decimals,
      });
      if (!r.ok) console.log('fail', i, JSON.stringify(r.error));
    }
    const subs = (await call('GET', `/subaccounts/list?accountId=${acc.id}`)).data as Json[];
    console.log('subaccounts in account:', subs.length);
    break;
  }
  case 'seed-history': {
    const acc = await account(rest[0]);
    const subs = (await call('GET', `/subaccounts/list?accountId=${acc.id}`)).data as Json[];
    const sub = subs.find((s) => s.name === rest[1]);
    if (!sub) throw new Error(`subaccount "${rest[1]}" not found`);
    for (let i = 1; i <= Number(rest[2]); i++) {
      await call('POST', '/subaccounts/set_balance', {
        subaccountId: sub.id,
        amountAtomic: `${1000 + i}`,
        amountDecimals: sub.current_amount_decimals,
      });
    }
    console.log('history seeded');
    break;
  }
  case 'revoke-sessions': {
    const r = await fetch(`${base}/auth/v1/logout?scope=global`, { method: 'POST', headers: auth });
    console.log('global logout', r.status);
    break;
  }
  default:
    throw new Error(`unknown command ${command}`);
}
