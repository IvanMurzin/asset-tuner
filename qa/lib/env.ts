// Runtime configuration for the QA suite. Values come from the process environment that
// `qa/run.sh` prepares; nothing here is ever printed.

function required(name: string): string {
  const value = Deno.env.get(name)?.trim();
  if (!value) {
    throw new Error(`Missing env ${name}. Run the suite through qa/run.sh.`);
  }
  return value;
}

export const env = {
  supabaseUrl: required('QA_SUPABASE_URL').replace(/\/+$/, ''),
  publishableKey: required('QA_PUBLISHABLE_KEY'),
  secretKey: required('QA_SECRET_KEY'),
  webhookSecret: required('QA_REVENUECAT_WEBHOOK_SECRET'),
};

export const apiBase = `${env.supabaseUrl}/functions/v1/api`;
export const functionsBase = `${env.supabaseUrl}/functions/v1`;

/** Headers for admin (service) access to Auth admin and PostgREST. */
export function adminHeaders(): Record<string, string> {
  const headers: Record<string, string> = {
    apikey: env.secretKey,
    'Content-Type': 'application/json',
  };
  // Legacy service_role keys are JWTs and must also be sent as a bearer token.
  if (env.secretKey.startsWith('eyJ')) {
    headers.Authorization = `Bearer ${env.secretKey}`;
  }
  return headers;
}
