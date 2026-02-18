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

export function fromError(error: unknown): Response {
  if (error instanceof ApiHttpError) {
    return fail(error.status, error.code, error.message, error.details);
  }

  if (typeof error === 'object' && error !== null) {
    const maybeMessage = (error as { message?: unknown }).message;
    if (typeof maybeMessage === 'string' && maybeMessage.trim().length > 0) {
      const code = (error as { code?: unknown }).code;
      const details = (error as { details?: unknown }).details;
      const hint = (error as { hint?: unknown }).hint;
      return fail(500, 'INTERNAL_ERROR', maybeMessage, {
        ...(code === undefined ? {} : { code }),
        ...(details === undefined ? {} : { details }),
        ...(hint === undefined ? {} : { hint }),
      });
    }
  }

  if (error instanceof Error) {
    return fail(500, 'INTERNAL_ERROR', error.message);
  }

  return fail(500, 'INTERNAL_ERROR', 'Unexpected internal error');
}
