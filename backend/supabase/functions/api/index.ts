import { handleCors } from '../_shared/cors.ts';
import { requireUser } from '../_shared/auth.ts';
import { getAdminClient } from '../_shared/db.ts';
import { requiredEnv } from '../_shared/env.ts';
import {
  ApiHttpError,
  fromError,
  ok,
  type ApiErrorCode,
} from '../_shared/responses.ts';
import {
  contactDeveloperSchema,
  createAccountSchema,
  createSubaccountSchema,
  deleteAccountSchema,
  deleteMyAccountSchema,
  deleteSubaccountSchema,
  parseBoolean,
  parseJsonBody,
  parsePositiveInt,
  profileUpdateSchema,
  setSubaccountBalanceSchema,
  updateAccountSchema,
  updateSubaccountSchema,
} from '../_shared/validation.ts';

type MePayload = {
  profile: {
    user_id: string;
    plan: 'free' | 'pro';
    base_asset_id: string | null;
    revenuecat_app_user_id: string | null;
    created_at: string;
    updated_at: string;
  };
  limits: {
    plan: 'free' | 'pro';
    max_accounts: number | null;
    max_subaccounts: number | null;
    fiat_limit: number | null;
    crypto_limit: number | null;
  };
  baseAsset: {
    id: string;
    kind: 'fiat' | 'crypto';
    code: string;
    name: string;
    provider: string;
    provider_ref: string;
    rank: number;
    decimals: number;
    is_active: boolean;
    created_at: string;
    updated_at: string;
  } | null;
};

type SubaccountHistoryPayload = {
  items: Array<{
    id: string;
    user_id: string;
    subaccount_id: string;
    amount_atomic: string;
    amount_decimals: number;
    note: string | null;
    created_at: string;
  }>;
  nextCursor: string | null;
};

const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function routePath(req: Request): string {
  const url = new URL(req.url);
  const parts = url.pathname.split('/').filter(Boolean);
  const apiIndex = parts.indexOf('api');
  const routeParts = apiIndex >= 0 ? parts.slice(apiIndex + 1) : parts;
  return `/${routeParts.join('/')}`;
}

function parseUuidList(raw: string | null): string[] {
  if (!raw) {
    return [];
  }

  return raw
    .split(',')
    .map((value) => value.trim())
    .filter((value) => value.length > 0)
    .filter((value) => UUID_RE.test(value));
}

function parseDbError(error: unknown): ApiHttpError {
  if (
    typeof error === 'object' &&
    error !== null &&
    'message' in error &&
    typeof (error as { message: unknown }).message === 'string'
  ) {
    const message = (error as { message: string }).message;
    const match = message.match(/^([A-Z_]+):\s*(.+)$/);
    if (match) {
      const code = match[1] as ApiErrorCode;
      const detail = match[2];
      switch (code) {
        case 'VALIDATION_ERROR':
          return new ApiHttpError(400, code, detail);
        case 'UNAUTHORIZED':
          return new ApiHttpError(401, code, detail);
        case 'FORBIDDEN':
        case 'ASSET_NOT_ALLOWED_FOR_PLAN':
          return new ApiHttpError(403, code, detail);
        case 'NOT_FOUND':
          return new ApiHttpError(404, code, detail);
        case 'LIMIT_ACCOUNTS_REACHED':
        case 'LIMIT_SUBACCOUNTS_REACHED':
          return new ApiHttpError(409, code, detail);
        case 'RATE_LIMITED':
          return new ApiHttpError(429, code, detail);
        case 'EXTERNAL_API_ERROR':
          return new ApiHttpError(502, code, detail);
        default:
          return new ApiHttpError(500, 'INTERNAL_ERROR', detail);
      }
    }

    return new ApiHttpError(500, 'INTERNAL_ERROR', message);
  }

  return new ApiHttpError(500, 'INTERNAL_ERROR', 'Unknown database error');
}

async function rpc<T>(fn: string, params: Record<string, unknown>): Promise<T> {
  const db = getAdminClient();
  const { data, error } = await db.rpc(fn, params);
  if (error) {
    throw parseDbError(error);
  }
  return data as T;
}

async function handleGetMe(userId: string): Promise<Response> {
  const data = await rpc<MePayload>('api_get_me', {
    p_user_id: userId,
  });
  return ok(data);
}

async function handleProfileUpdate(req: Request, userId: string): Promise<Response> {
  const body = await parseJsonBody(req, profileUpdateSchema);

  const data = await rpc<unknown>('api_profile_update_base_asset', {
    p_user_id: userId,
    p_base_asset_id: body.baseAssetId,
  });

  return ok(data);
}

async function handleDeleteMyAccount(req: Request, userId: string): Promise<Response> {
  await parseJsonBody(req, deleteMyAccountSchema);

  const db = getAdminClient();
  const { error } = await db.auth.admin.deleteUser(userId, true);
  if (error) {
    throw new ApiHttpError(500, 'INTERNAL_ERROR', 'Failed to delete auth user', error);
  }

  return ok({ deleted: true });
}

async function handleContactDeveloper(req: Request, userId: string): Promise<Response> {
  const body = await parseJsonBody(req, contactDeveloperSchema);

  const data = await rpc<{
    id: string;
    created_at: string;
  }>('api_create_support_message', {
    p_user_id: userId,
    p_name: body.name,
    p_email: body.email ?? null,
    p_subject: body.subject ?? null,
    p_message: body.description,
    p_meta: body.meta ?? {},
    p_max_per_hour: 5,
  });

  return ok({ id: data.id, accepted: true, created_at: data.created_at });
}

async function handleAssetsList(req: Request, userId: string): Promise<Response> {
  const url = new URL(req.url);
  const kindRaw = url.searchParams.get('kind');
  const kind = kindRaw === 'fiat' || kindRaw === 'crypto' ? kindRaw : null;
  const limit = parsePositiveInt(url.searchParams.get('limit'), 100, 200);
  const onlyAllowed = parseBoolean(url.searchParams.get('onlyAllowed'), true);

  const data = await rpc<unknown[]>('api_list_assets', {
    p_user_id: userId,
    p_kind: kind,
    p_limit: limit,
    p_only_allowed: onlyAllowed,
  });

  return ok(data, {
    onlyAllowed,
    requested_kind: kind,
  });
}

async function handleRatesUsd(req: Request): Promise<Response> {
  const url = new URL(req.url);
  const assetIds = parseUuidList(url.searchParams.get('assetIds'));
  if (assetIds.length === 0) {
    throw new ApiHttpError(400, 'VALIDATION_ERROR', 'assetIds query param is required');
  }

  const data = await rpc<Record<string, {
    usd_price_atomic: string;
    usd_price_decimals: number;
    as_of: string;
  }>>('api_get_rates_usd', {
    p_asset_ids: assetIds,
  });

  return ok(data);
}

async function handleAccountsList(userId: string): Promise<Response> {
  const data = await rpc<unknown[]>('api_list_accounts', {
    p_user_id: userId,
  });

  return ok(data);
}

async function handleCreateAccount(req: Request, userId: string): Promise<Response> {
  const body = await parseJsonBody(req, createAccountSchema);

  const data = await rpc<unknown>('api_create_account', {
    p_user_id: userId,
    p_name: body.name,
    p_type: body.type,
  });

  return ok(data);
}

async function handleUpdateAccount(req: Request, userId: string): Promise<Response> {
  const body = await parseJsonBody(req, updateAccountSchema);

  if (body.name === undefined && body.type === undefined && body.archived === undefined) {
    throw new ApiHttpError(400, 'VALIDATION_ERROR', 'Nothing to update');
  }

  const data = await rpc<unknown>('api_update_account', {
    p_user_id: userId,
    p_account_id: body.accountId,
    p_name: body.name ?? null,
    p_type: body.type ?? null,
    p_archived: body.archived ?? null,
  });

  return ok(data);
}

async function handleDeleteAccount(req: Request, userId: string): Promise<Response> {
  const body = await parseJsonBody(req, deleteAccountSchema);

  await rpc<unknown>('api_delete_account', {
    p_user_id: userId,
    p_account_id: body.accountId,
  });

  return ok({ deleted: true, accountId: body.accountId });
}

async function handleSubaccountsList(req: Request, userId: string): Promise<Response> {
  const url = new URL(req.url);
  const accountId = url.searchParams.get('accountId');
  if (!accountId || !UUID_RE.test(accountId)) {
    throw new ApiHttpError(400, 'VALIDATION_ERROR', 'Valid accountId is required');
  }

  const data = await rpc<unknown[]>('api_list_subaccounts', {
    p_user_id: userId,
    p_account_id: accountId,
  });

  return ok(data);
}

async function handleCreateSubaccount(req: Request, userId: string): Promise<Response> {
  const body = await parseJsonBody(req, createSubaccountSchema);

  const data = await rpc<unknown>('api_create_subaccount', {
    p_user_id: userId,
    p_account_id: body.accountId,
    p_asset_id: body.assetId,
    p_name: body.name,
    p_initial_amount_atomic: body.initialAmountAtomic,
    p_initial_amount_decimals: body.initialAmountDecimals,
  });

  return ok(data);
}

async function handleUpdateSubaccount(req: Request, userId: string): Promise<Response> {
  const body = await parseJsonBody(req, updateSubaccountSchema);

  if (body.name === undefined && body.archived === undefined) {
    throw new ApiHttpError(400, 'VALIDATION_ERROR', 'Nothing to update');
  }

  const data = await rpc<unknown>('api_update_subaccount', {
    p_user_id: userId,
    p_subaccount_id: body.subaccountId,
    p_name: body.name ?? null,
    p_archived: body.archived ?? null,
  });

  return ok(data);
}

async function handleDeleteSubaccount(req: Request, userId: string): Promise<Response> {
  const body = await parseJsonBody(req, deleteSubaccountSchema);

  await rpc<unknown>('api_delete_subaccount', {
    p_user_id: userId,
    p_subaccount_id: body.subaccountId,
  });

  return ok({ deleted: true, subaccountId: body.subaccountId });
}

async function handleSetSubaccountBalance(req: Request, userId: string): Promise<Response> {
  const body = await parseJsonBody(req, setSubaccountBalanceSchema);

  const data = await rpc<unknown>('api_set_subaccount_balance', {
    p_user_id: userId,
    p_subaccount_id: body.subaccountId,
    p_amount_atomic: body.amountAtomic,
    p_amount_decimals: body.amountDecimals,
    p_note: body.note ?? null,
  });

  return ok(data);
}

async function handleSubaccountHistory(req: Request, userId: string): Promise<Response> {
  const url = new URL(req.url);

  const subaccountId = url.searchParams.get('subaccountId');
  if (!subaccountId || !UUID_RE.test(subaccountId)) {
    throw new ApiHttpError(400, 'VALIDATION_ERROR', 'subaccountId must be a UUID');
  }

  const cursorRaw = url.searchParams.get('cursor');
  let cursorIso: string | null = null;
  if (cursorRaw) {
    const date = new Date(cursorRaw);
    if (Number.isNaN(date.getTime())) {
      throw new ApiHttpError(400, 'VALIDATION_ERROR', 'Invalid cursor');
    }
    cursorIso = date.toISOString();
  }

  const limit = parsePositiveInt(url.searchParams.get('limit'), 50, 200);

  const data = await rpc<SubaccountHistoryPayload>('api_subaccount_history', {
    p_user_id: userId,
    p_subaccount_id: subaccountId,
    p_cursor: cursorIso,
    p_limit: limit,
  });

  return ok(data.items, { nextCursor: data.nextCursor ?? null });
}

async function handleRevenuecatRefresh(userId: string): Promise<Response> {
  const apiKey = requiredEnv('REVENUECAT_API_KEY');

  const me = await rpc<MePayload>('api_get_me', {
    p_user_id: userId,
  });

  const appUserId = me.profile.revenuecat_app_user_id ?? userId;

  const response = await fetch(
    `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}`,
    {
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
    },
  );

  if (!response.ok) {
    const details = await response.text().catch(() => '');
    throw new ApiHttpError(502, 'EXTERNAL_API_ERROR', 'RevenueCat refresh request failed', {
      status: response.status,
      details,
    });
  }

  const payload = (await response.json()) as Record<string, unknown>;
  const subscriber = payload.subscriber as Record<string, unknown> | undefined;
  const entitlements = (subscriber?.entitlements ?? {}) as Record<string, { expires_date?: string | null }>;

  const now = Date.now();
  const isPro = Object.values(entitlements).some((entitlement) => {
    if (!entitlement) {
      return false;
    }
    const expiresAt = entitlement.expires_date;
    if (!expiresAt) {
      return true;
    }
    const expiresMs = new Date(expiresAt).getTime();
    return Number.isFinite(expiresMs) && expiresMs > now;
  });

  const externalId = `refresh:${appUserId}:${new Date().toISOString()}`;
  const sync = await rpc<unknown>('api_apply_revenuecat_event', {
    p_source: 'revenuecat_refresh',
    p_external_id: externalId,
    p_app_user_id: appUserId,
    p_payload: payload,
    p_is_pro: isPro,
  });

  return ok({ appUserId, isPro, sync });
}

Deno.serve(async (req) => {
  const startedAt = Date.now();
  const cors = handleCors(req);
  if (cors) {
    return cors;
  }

  const path = routePath(req);
  const method = req.method.toUpperCase();

  try {
    const user = await requireUser(req);
    const userId = user.id;

    let response: Response;

    if (method === 'GET' && path === '/me') {
      response = await handleGetMe(userId);
    } else if (method === 'POST' && path === '/profile/update') {
      response = await handleProfileUpdate(req, userId);
    } else if (method === 'POST' && path === '/delete_my_account') {
      response = await handleDeleteMyAccount(req, userId);
    } else if (method === 'POST' && path === '/contact_developer') {
      response = await handleContactDeveloper(req, userId);
    } else if (method === 'GET' && path === '/assets/list') {
      response = await handleAssetsList(req, userId);
    } else if (method === 'GET' && path === '/rates/usd') {
      response = await handleRatesUsd(req);
    } else if (method === 'GET' && path === '/accounts/list') {
      response = await handleAccountsList(userId);
    } else if (method === 'POST' && path === '/accounts/create') {
      response = await handleCreateAccount(req, userId);
    } else if (method === 'POST' && path === '/accounts/update') {
      response = await handleUpdateAccount(req, userId);
    } else if (method === 'POST' && path === '/accounts/delete') {
      response = await handleDeleteAccount(req, userId);
    } else if (method === 'GET' && path === '/subaccounts/list') {
      response = await handleSubaccountsList(req, userId);
    } else if (method === 'POST' && path === '/subaccounts/create') {
      response = await handleCreateSubaccount(req, userId);
    } else if (method === 'POST' && path === '/subaccounts/update') {
      response = await handleUpdateSubaccount(req, userId);
    } else if (method === 'POST' && path === '/subaccounts/delete') {
      response = await handleDeleteSubaccount(req, userId);
    } else if (method === 'POST' && path === '/subaccounts/set_balance') {
      response = await handleSetSubaccountBalance(req, userId);
    } else if (method === 'GET' && path === '/subaccounts/history') {
      response = await handleSubaccountHistory(req, userId);
    } else if (method === 'POST' && path === '/revenuecat/refresh') {
      response = await handleRevenuecatRefresh(userId);
    } else {
      throw new ApiHttpError(404, 'NOT_FOUND', 'Route not found');
    }

    console.log(
      JSON.stringify({
        function: 'api',
        user_id: userId,
        method,
        path,
        status: response.status,
        duration_ms: Date.now() - startedAt,
      }),
    );

    return response;
  } catch (error) {
    const failure = fromError(error);

    console.error(
      JSON.stringify({
        function: 'api',
        method,
        path,
        status: failure.status,
        error: error instanceof Error ? error.message : 'unknown_error',
        duration_ms: Date.now() - startedAt,
      }),
    );

    return failure;
  }
});
