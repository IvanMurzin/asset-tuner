import { createClient, type SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';
import { requiredEnv } from './env.ts';

let adminClient: SupabaseClient | null = null;

export function getAdminClient(): SupabaseClient {
  if (adminClient) {
    return adminClient;
  }

  const url = requiredEnv('SUPABASE_URL');
  const serviceRoleKey = requiredEnv('SUPABASE_SERVICE_ROLE_KEY');

  adminClient = createClient(url, serviceRoleKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });

  return adminClient;
}
