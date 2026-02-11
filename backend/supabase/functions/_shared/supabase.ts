import { createClient, type SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { requireEnv } from './env.ts';

export function getServiceClient(): SupabaseClient {
  const url = requireEnv('SUPABASE_URL');
  const serviceKey = requireEnv('SUPABASE_SERVICE_ROLE_KEY');
  return createClient(url, serviceKey);
}

export function getUserClient(authHeader: string): SupabaseClient {
  const url = requireEnv('SUPABASE_URL');
  const anonKey = requireEnv('SUPABASE_ANON_KEY');
  return createClient(url, anonKey, {
    global: {
      headers: {
        Authorization: authHeader,
      },
    },
  });
}

