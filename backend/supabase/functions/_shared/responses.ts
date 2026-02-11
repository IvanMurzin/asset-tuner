import { corsHeaders } from './cors.ts';

export type FailureCode =
  | 'network'
  | 'unauthorized'
  | 'forbidden'
  | 'not_found'
  | 'validation'
  | 'conflict'
  | 'rate_limited'
  | 'unknown';

export function json(data: unknown, init: ResponseInit = {}): Response {
  const headers = new Headers(init.headers);
  headers.set('Content-Type', 'application/json');
  for (const [key, value] of Object.entries(corsHeaders)) {
    headers.set(key, value);
  }
  return new Response(JSON.stringify(data), { ...init, headers });
}

export function jsonError(
  code: FailureCode,
  message: string,
  status: number,
  details?: Record<string, unknown>,
): Response {
  return json(
    {
      error: {
        code,
        message,
        ...(details ? { details } : {}),
      },
    },
    { status },
  );
}

