// Hard-deletes QA users by id, including rows that do not cascade from auth.users.
// Run through the secrets wrapper:
//   qa/run.sh tool qa/tools/delete_users.ts <user-id> [<user-id> ...]
//
// Safety: a user is deleted only if its email is a QA address, or it is already soft-deleted
// (the app's delete flow scrambles the email) and owns data created by QA runs.
import { dbDelete, dbSelect } from '../lib/client.ts';
import { adminHeaders, env } from '../lib/env.ts';
import { QA_EMAIL_DOMAIN, QA_EMAIL_PREFIX } from '../lib/users.ts';

for (const id of Deno.args) {
  const res = await fetch(`${env.supabaseUrl}/auth/v1/admin/users/${id}`, { headers: adminHeaders() });
  if (res.status === 404) {
    console.log(`${id}: already gone`);
    continue;
  }
  const user = await res.json();
  const email: string = user.email ?? '';
  const isQaEmail = email.startsWith(QA_EMAIL_PREFIX) && email.endsWith(`@${QA_EMAIL_DOMAIN}`);
  const accounts = await dbSelect<{ name: string }>('accounts', `user_id=eq.${id}&select=name`);
  const isSoftDeletedQa = Boolean(user.deleted_at) &&
    accounts.every((a) => /^(QA|Rel|Seed|Offline)/i.test(a.name));
  if (!isQaEmail && !isSoftDeletedQa) {
    console.log(`${id}: REFUSED, not a QA user (${email})`);
    continue;
  }
  await dbDelete('support_messages', `user_id=eq.${id}`);
  await dbDelete('webhook_events', `app_user_id=eq.${id}`);
  const del = await fetch(`${env.supabaseUrl}/auth/v1/admin/users/${id}`, {
    method: 'DELETE',
    headers: adminHeaders(),
    body: JSON.stringify({ should_soft_delete: false }),
  });
  const left = await dbSelect('profiles', `user_id=eq.${id}&select=user_id`);
  console.log(`${id}: hard delete ${del.status}, profiles left ${left.length}`);
}
