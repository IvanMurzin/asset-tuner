import { assertEquals } from 'jsr:@std/assert';
import {
  inferIsPro,
  inferIsProFromSubscriberEntitlements,
  type RevenueCatEvent,
} from './index.ts';

Deno.test('inferIsPro: does not downgrade on cancellation when pro entitlement is still active', () => {
  const nowMs = 1_800_000_000_000;
  const event: RevenueCatEvent = {
    type: 'CANCELLATION',
    entitlement_ids: ['pro'],
    expiration_at_ms: nowMs + 60_000,
  };

  assertEquals(inferIsPro(event, nowMs), true);
});

Deno.test('inferIsPro: expires to free when pro entitlement expiration is in the past', () => {
  const nowMs = 1_800_000_000_000;
  const event: RevenueCatEvent = {
    type: 'EXPIRATION',
    entitlement_ids: ['pro'],
    expiration_at_ms: nowMs - 1,
  };

  assertEquals(inferIsPro(event, nowMs), false);
});

Deno.test('inferIsPro: stays free when pro entitlement is missing', () => {
  const nowMs = 1_800_000_000_000;
  const event: RevenueCatEvent = {
    type: 'RENEWAL',
    entitlement_ids: ['basic'],
    expiration_at_ms: nowMs + 60_000,
  };

  assertEquals(inferIsPro(event, nowMs), false);
});

Deno.test('inferIsProFromSubscriberEntitlements: active pro entitlement resolves to pro', () => {
  const nowMs = 1_800_000_000_000;
  const entitlements = {
    pro: { expires_date: '2030-01-01T00:00:00Z' },
  };
  assertEquals(inferIsProFromSubscriberEntitlements(entitlements, nowMs), true);
});

Deno.test('inferIsProFromSubscriberEntitlements: expired pro entitlement resolves to free', () => {
  const nowMs = 1_800_000_000_000;
  const entitlements = {
    pro: { expires_date: '2020-01-01T00:00:00Z' },
  };
  assertEquals(inferIsProFromSubscriberEntitlements(entitlements, nowMs), false);
});

Deno.test('inferIsProFromSubscriberEntitlements: missing pro entitlement resolves to free', () => {
  const nowMs = 1_800_000_000_000;
  const entitlements = {
    basic: { expires_date: '2030-01-01T00:00:00Z' },
  };
  assertEquals(inferIsProFromSubscriberEntitlements(entitlements, nowMs), false);
});
