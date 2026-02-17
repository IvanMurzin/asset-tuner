import { z } from 'https://esm.sh/zod@3.24.2';
import { ApiHttpError } from './responses.ts';

export const uuidSchema = z.string().uuid();
export const atomicStringSchema = z.string().regex(/^-?\d+$/);
export const decimalsSchema = z.number().int().min(0).max(18);

export const profileUpdateSchema = z.object({
  baseAssetId: uuidSchema,
});

export const deleteMyAccountSchema = z.object({
  confirm: z.literal(true),
});

export const contactDeveloperSchema = z.object({
  name: z.string().trim().min(1).max(120),
  email: z.string().trim().email().optional(),
  subject: z.string().trim().min(1).max(200).optional(),
  description: z.string().trim().min(1).max(5000),
  meta: z.record(z.unknown()).optional(),
});

export const createAccountSchema = z.object({
  name: z.string().trim().min(1).max(120),
  type: z.string().trim().min(1).max(80),
});

export const updateAccountSchema = z.object({
  accountId: uuidSchema,
  name: z.string().trim().min(1).max(120).optional(),
  type: z.string().trim().min(1).max(80).optional(),
  archived: z.boolean().optional(),
});

export const deleteAccountSchema = z.object({
  accountId: uuidSchema,
});

export const createSubaccountSchema = z.object({
  accountId: uuidSchema,
  assetId: uuidSchema,
  name: z.string().trim().min(1).max(120),
  initialAmountAtomic: atomicStringSchema,
  initialAmountDecimals: decimalsSchema,
});

export const updateSubaccountSchema = z.object({
  subaccountId: uuidSchema,
  name: z.string().trim().min(1).max(120).optional(),
  archived: z.boolean().optional(),
});

export const deleteSubaccountSchema = z.object({
  subaccountId: uuidSchema,
});

export const setSubaccountBalanceSchema = z.object({
  subaccountId: uuidSchema,
  amountAtomic: atomicStringSchema,
  amountDecimals: decimalsSchema,
  note: z.string().max(1000).optional(),
});

export async function parseJsonBody<T>(req: Request, schema: z.ZodSchema<T>): Promise<T> {
  const rawBody = await req.json().catch(() => {
    throw new ApiHttpError(400, 'VALIDATION_ERROR', 'Invalid JSON body');
  });

  const parsed = schema.safeParse(rawBody);
  if (!parsed.success) {
    throw new ApiHttpError(400, 'VALIDATION_ERROR', 'Validation failed', parsed.error.flatten());
  }

  return parsed.data;
}

export function parsePositiveInt(
  value: string | null,
  fallback: number,
  maxValue: number,
): number {
  if (!value) {
    return fallback;
  }
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return fallback;
  }
  return Math.min(maxValue, Math.floor(parsed));
}

export function parseBoolean(value: string | null, fallback: boolean): boolean {
  if (value == null) {
    return fallback;
  }
  if (value === 'true' || value === '1') {
    return true;
  }
  if (value === 'false' || value === '0') {
    return false;
  }
  return fallback;
}
