import { corsHeaders } from './cors.ts';

export type ApiErrorCode =
  | 'UNAUTHORIZED'
  | 'FORBIDDEN'
  | 'NOT_FOUND'
  | 'VALIDATION_ERROR'
  | 'LIMIT_ACCOUNTS_REACHED'
  | 'LIMIT_SUBACCOUNTS_REACHED'
  | 'ASSET_NOT_ALLOWED_FOR_PLAN'
  | 'RATE_LIMITED'
  | 'EXTERNAL_API_ERROR'
  | 'INTERNAL_ERROR';

export class ApiHttpError extends Error {
  public readonly status: number;
  public readonly code: ApiErrorCode;
  public readonly details?: unknown;

  constructor(status: number, code: ApiErrorCode, message: string, details?: unknown) {
    super(message);
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

function withHeaders(init?: ResponseInit): ResponseInit {
  const headers = new Headers(init?.headers);
  headers.set('Content-Type', 'application/json');
  for (const [key, value] of Object.entries(corsHeaders)) {
    headers.set(key, value);
  }
  return { ...(init ?? {}), headers };
}

export function ok<TData>(data: TData, meta?: Record<string, unknown>, status = 200): Response {
  return new Response(
    JSON.stringify({ ok: true, data, ...(meta ? { meta } : {}) }),
    withHeaders({ status }),
  );
}

export function fail(
  status: number,
  code: ApiErrorCode,
  message: string,
  details?: unknown,
): Response {
  return new Response(
    JSON.stringify({
      ok: false,
      error: {
        code,
        message,
        ...(details === undefined ? {} : { details }),
      },
    }),
    withHeaders({ status }),
  );
}

/**
 * Maps a thrown value to a response. Deliberate client errors (`ApiHttpError` below 500) are
 * returned as raised. Anything else is logged here with its details and answered with a generic
 * message, so database messages, details and hints never reach clients.
 */
export function fromError(error: unknown): Response {
  if (error instanceof ApiHttpError && error.status < 500) {
    return fail(error.status, error.code, error.message, error.details);
  }

  console.error(JSON.stringify({ op: 'internal_error', error: describeError(error) }));
  if (error instanceof ApiHttpError) {
    return fail(error.status, error.code, 'Internal error');
  }
  return fail(500, 'INTERNAL_ERROR', 'Internal error');
}

function describeError(error: unknown): Record<string, unknown> {
  if (typeof error !== 'object' || error === null) {
    return { value: String(error) };
  }
  const { message, code, details, hint } = error as Record<string, unknown>;
  return { message, code, details, hint };
}
