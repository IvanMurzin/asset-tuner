import { createClient, type SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';
import { requiredEnv } from './env.ts';

let adminClient: SupabaseClient | null = null;

export function getAdminClient(): SupabaseClient {
  if (adminClient) {
    return adminClient;
  }

  const url = requiredEnv('SUPABASE_URL');
  const secretKeys = JSON.parse(requiredEnv('SUPABASE_SECRET_KEYS')) as Record<string, string>;
  const secretKey = secretKeys['default'];
  if (!secretKey || secretKey.trim().length === 0) {
    throw new Error('Missing default Supabase Secret key');
  }

  adminClient = createClient(url, secretKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });

  return adminClient;
}
