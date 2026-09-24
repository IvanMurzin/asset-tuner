import { assert, assertEquals } from 'jsr:@std/assert@1';
import { api } from './client.ts';
import type { QaUser } from './users.ts';

export type Asset = {
  id: string;
  kind: 'fiat' | 'crypto';
  code: string;
  rank: number;
  decimals: number;
  is_locked: boolean;
};

export type Account = { id: string; name: string; type: string; archived: boolean };
export type Subaccount = {
  id: string;
  account_id: string;
  asset_id: string;
  name: string;
  archived: boolean;
  current_amount_atomic: string;
  current_amount_decimals: number;
};

export async function listAssets(user: QaUser, kind: 'fiat' | 'crypto'): Promise<Asset[]> {
  const res = await api<Asset[]>(user.token, 'GET', `/assets/list?kind=${kind}`);
  assertEquals(res.status, 200, JSON.stringify(res.raw));
  return res.data;
}

export async function assetByCode(
  user: QaUser,
  kind: 'fiat' | 'crypto',
  code: string,
): Promise<Asset> {
  const asset = (await listAssets(user, kind)).find((a) => a.code === code);
  assert(asset, `asset ${kind}/${code} not found`);
  return asset;
}

/** First asset of `kind` whose rank exceeds the free-plan limit of 5. */
export async function lockedAsset(user: QaUser, kind: 'fiat' | 'crypto'): Promise<Asset> {
  const asset = (await listAssets(user, kind)).find((a) => a.rank > 5);
  assert(asset, `no ${kind} asset with rank > 5`);
  return asset;
}

export async function createAccount(user: QaUser, name = 'QA account', type = 'bank') {
  const res = await api<Account>(user.token, 'POST', '/accounts/create', { name, type });
  assertEquals(res.status, 200, JSON.stringify(res.raw));
  return res.data;
}

export async function createSubaccount(
  user: QaUser,
  accountId: string,
  asset: Asset,
  amountAtomic = '100',
  name = 'QA sub',
) {
  const res = await api<Subaccount>(user.token, 'POST', '/subaccounts/create', {
    accountId,
    assetId: asset.id,
    name,
    initialAmountAtomic: amountAtomic,
    initialAmountDecimals: asset.decimals,
  });
  assertEquals(res.status, 200, JSON.stringify(res.raw));
  return res.data;
}

export async function setBalance(user: QaUser, sub: Subaccount, amountAtomic: string) {
  return await api(user.token, 'POST', '/subaccounts/set_balance', {
    subaccountId: sub.id,
    amountAtomic,
    amountDecimals: sub.current_amount_decimals,
  });
}
