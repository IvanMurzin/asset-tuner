import { assertEquals, assertThrows } from 'jsr:@std/assert';
import { inferIsPro, type RevenueCatEvent } from './index.ts';
import {
  isProFromEntitlements,
  resolveProEntitlementIdsFromEnv,
} from '../_shared/revenuecat_entitlements.ts';

const PRO = new Set(['asset tuner pro']);

Deno.test('inferIsPro: does not downgrade on cancellation when pro entitlement is still active', () => {
  const nowMs = 1_800_000_000_000;
  const event: RevenueCatEvent = {
    type: 'CANCELLATION',
    entitlement_ids: ['Asset Tuner Pro'],
    expiration_at_ms: nowMs + 60_000,
  };

  assertEquals(inferIsPro(event, nowMs, PRO), true);
});

Deno.test('inferIsPro: expires to free when pro entitlement expiration is in the past', () => {
  const nowMs = 1_800_000_000_000;
  const event: RevenueCatEvent = {
    type: 'EXPIRATION',
    entitlement_ids: ['Asset Tuner Pro'],
    expiration_at_ms: nowMs - 1,
  };

  assertEquals(inferIsPro(event, nowMs, PRO), false);
});

Deno.test('inferIsPro: stays free when pro entitlement is missing', () => {
  const nowMs = 1_800_000_000_000;
  const event: RevenueCatEvent = {
    type: 'RENEWAL',
    entitlement_ids: ['basic'],
    expiration_at_ms: nowMs + 60_000,
  };

  assertEquals(inferIsPro(event, nowMs, PRO), false);
});

Deno.test('inferIsPro: matches the entitlement identifier case-insensitively', () => {
  const nowMs = 1_800_000_000_000;
  const event: RevenueCatEvent = {
    type: 'RENEWAL',
    entitlement_ids: ['ASSET TUNER PRO'],
    expiration_at_ms: nowMs + 60_000,
  };

  assertEquals(inferIsPro(event, nowMs, PRO), true);
});

Deno.test('isProFromEntitlements: active pro entitlement resolves to pro', () => {
  const nowMs = 1_800_000_000_000;
  const entitlements = {
    'Asset Tuner Pro': { expires_date: '2030-01-01T00:00:00Z' },
  };

  assertEquals(isProFromEntitlements(entitlements, nowMs, PRO), true);
});

Deno.test('isProFromEntitlements: expired pro entitlement resolves to free', () => {
  const nowMs = 1_800_000_000_000;
  const entitlements = {
    'Asset Tuner Pro': { expires_date: '2020-01-01T00:00:00Z' },
  };

  assertEquals(isProFromEntitlements(entitlements, nowMs, PRO), false);
});

Deno.test('isProFromEntitlements: missing pro entitlement resolves to free', () => {
  const nowMs = 1_800_000_000_000;
  const entitlements = {
    basic: { expires_date: '2030-01-01T00:00:00Z' },
  };

  assertEquals(isProFromEntitlements(entitlements, nowMs, PRO), false);
});

Deno.test('isProFromEntitlements: entitlement without expiry is a lifetime grant', () => {
  const nowMs = 1_800_000_000_000;
  const entitlements = {
    'Asset Tuner Pro': { expires_date: null },
  };

  assertEquals(isProFromEntitlements(entitlements, nowMs, PRO), true);
});

Deno.test('resolveProEntitlementIdsFromEnv: unset config throws instead of defaulting', () => {
  Deno.env.delete('REVENUECAT_PRO_ENTITLEMENTS');
  assertThrows(() => resolveProEntitlementIdsFromEnv());
});
