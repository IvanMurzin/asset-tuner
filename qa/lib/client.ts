import { adminHeaders, apiBase, env } from './env.ts';

export type ApiResult<T = unknown> = {
  status: number;
  ok: boolean;
  data: T;
  meta?: Record<string, unknown>;
  error?: { code: string; message: string; details?: unknown };
  raw: unknown;
};

async function parse<T>(res: Response): Promise<ApiResult<T>> {
  const text = await res.text();
  let body: Record<string, unknown> = {};
  try {
    body = text ? JSON.parse(text) : {};
  } catch {
    body = { nonJson: text };
  }
  return {
    status: res.status,
    ok: body.ok === true,
    data: body.data as T,
    meta: body.meta as Record<string, unknown> | undefined,
    error: body.error as ApiResult['error'],
    raw: body,
  };
}

/** Calls the `api` Edge Function. `token` null sends no Authorization header. */
export async function api<T = unknown>(
  token: string | null,
  method: 'GET' | 'POST',
  path: string,
  body?: unknown,
): Promise<ApiResult<T>> {
  const headers: Record<string, string> = {
    apikey: env.publishableKey,
    'Content-Type': 'application/json',
  };
  if (token !== null) {
    headers.Authorization = `Bearer ${token}`;
  }
  const res = await fetch(`${apiBase}${path}`, {
    method,
    headers,
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  return parse<T>(res);
}

/** Raw fetch helper that returns status plus parsed JSON (or text). */
export async function rawFetch(
  url: string,
  init: RequestInit,
): Promise<{ status: number; body: unknown }> {
  const res = await fetch(url, init);
  const text = await res.text();
  try {
    return { status: res.status, body: text ? JSON.parse(text) : null };
  } catch {
    return { status: res.status, body: text };
  }
}

/** Service-role PostgREST select, used only for assertions and cleanup. */
export async function dbSelect<T = Record<string, unknown>>(
  table: string,
  query: string,
): Promise<T[]> {
  const res = await fetch(`${env.supabaseUrl}/rest/v1/${table}?${query}`, {
    headers: adminHeaders(),
  });
  if (!res.ok) {
    throw new Error(`dbSelect ${table} failed: ${res.status} ${await res.text()}`);
  }
  return (await res.json()) as T[];
}

export async function dbUpdate(table: string, query: string, patch: unknown): Promise<void> {
  const res = await fetch(`${env.supabaseUrl}/rest/v1/${table}?${query}`, {
    method: 'PATCH',
    headers: { ...adminHeaders(), Prefer: 'return=minimal' },
    body: JSON.stringify(patch),
  });
  if (!res.ok) {
    throw new Error(`dbUpdate ${table} failed: ${res.status} ${await res.text()}`);
  }
}

export async function dbDelete(table: string, query: string): Promise<void> {
  const res = await fetch(`${env.supabaseUrl}/rest/v1/${table}?${query}`, {
    method: 'DELETE',
    headers: { ...adminHeaders(), Prefer: 'return=minimal' },
  });
  if (!res.ok) {
    throw new Error(`dbDelete ${table} failed: ${res.status} ${await res.text()}`);
  }
}
