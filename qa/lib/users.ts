import { adminHeaders, env } from './env.ts';
import { api, dbDelete, dbUpdate } from './client.ts';

export const QA_EMAIL_PREFIX = 'qa+';
export const QA_EMAIL_DOMAIN = 'asset-tuner.test';

export type QaUser = {
  id: string;
  email: string;
  password: string;
  token: string;
};

function randomSuffix(): string {
  return `${Date.now()}-${crypto.randomUUID().slice(0, 8)}`;
}

export async function signIn(email: string, password: string): Promise<string> {
  const res = await fetch(`${env.supabaseUrl}/auth/v1/token?grant_type=password`, {
    method: 'POST',
    headers: { apikey: env.publishableKey, 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });
  const body = await res.json();
  if (!res.ok || !body.access_token) {
    throw new Error(`signIn failed: ${res.status} ${JSON.stringify(body)}`);
  }
  return body.access_token as string;
}

/** Creates a confirmed disposable QA user and returns a signed-in session. */
export async function createQaUser(label = 'api'): Promise<QaUser> {
  const email = `${QA_EMAIL_PREFIX}${label}-${randomSuffix()}@${QA_EMAIL_DOMAIN}`;
  const password = `Qa${crypto.randomUUID().replaceAll('-', '').slice(0, 16)}1`;

  const res = await fetch(`${env.supabaseUrl}/auth/v1/admin/users`, {
    method: 'POST',
    headers: adminHeaders(),
    body: JSON.stringify({ email, password, email_confirm: true }),
  });
  const body = await res.json();
  if (!res.ok || !body.id) {
    throw new Error(`createQaUser failed: ${res.status} ${JSON.stringify(body)}`);
  }

  const token = await signIn(email, password);
  // Ensures the profile row exists before tests touch plan state.
  await api(token, 'GET', '/me');
  return { id: body.id as string, email, password, token };
}

export async function setPlan(user: QaUser, plan: 'free' | 'pro'): Promise<void> {
  await dbUpdate('profiles', `user_id=eq.${user.id}`, { plan });
}

/** Hard-deletes a QA user and the rows that do not cascade from auth.users. */
export async function deleteQaUser(user: QaUser): Promise<void> {
  if (!user.email.startsWith(QA_EMAIL_PREFIX)) {
    throw new Error(`Refusing to delete non-QA user ${user.id}`);
  }
  await dbDelete('support_messages', `user_id=eq.${user.id}`);
  await dbDelete('webhook_events', `app_user_id=eq.${user.id}`);
  const res = await fetch(`${env.supabaseUrl}/auth/v1/admin/users/${user.id}`, {
    method: 'DELETE',
    headers: adminHeaders(),
    body: JSON.stringify({ should_soft_delete: false }),
  });
  // 404 is fine: the user may already be gone.
  if (!res.ok && res.status !== 404) {
    throw new Error(`deleteQaUser failed: ${res.status} ${await res.text()}`);
  }
}

/** Runs `fn` with fresh QA users and always cleans them up. */
export async function withUsers(
  count: number,
  fn: (...users: QaUser[]) => Promise<void>,
  label = 'api',
): Promise<void> {
  const users: QaUser[] = [];
  try {
    for (let i = 0; i < count; i++) {
      users.push(await createQaUser(label));
    }
    await fn(...users);
  } finally {
    for (const user of users) {
      await deleteQaUser(user).catch((e) => console.error(`cleanup ${user.id}: ${e}`));
    }
  }
}
