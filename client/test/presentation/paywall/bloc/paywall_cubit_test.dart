import 'dart:async';

import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../paywall_fixtures.dart';

void main() {
  late _FakeRevenueCatService revenueCat;
  late PaywallCubit cubit;

  setUp(() {
    revenueCat = _FakeRevenueCatService();
    cubit = PaywallCubit(
      revenueCat,
      AppAnalytics(),
      const PaywallArgs(reason: PaywallReason.subaccountsLimit),
    );
  });

  tearDown(() => cubit.close());

  test('restore success goes through verifying and reaches done once', () async {
    final statuses = <PaywallStatus>[];
    final sub = cubit.stream.listen((state) => statuses.add(state.status));

    await cubit.restore();
    expect(cubit.state.status, PaywallStatus.verifying);

    // Profile turns Pro during verification: must not short-circuit to done.
    cubit.onProfileChanged(isPro: true);
    expect(cubit.state.status, PaywallStatus.verifying);

    cubit.onVerified(isPro: true);
    cubit.onVerified(isPro: true);
    cubit.onProfileChanged(isPro: true);
    cubit.dismiss();
    await Future<void>.delayed(Duration.zero);

    expect(statuses.where((s) => s == PaywallStatus.done), hasLength(1));
    await sub.cancel();
  });

  test('restore success without Pro keeps the paywall open with an error', () async {
    await cubit.restore();
    cubit.onVerified(isPro: false);

    expect(cubit.state.status, PaywallStatus.ready);
    expect(cubit.state.failureCode, 'paywall_sync_not_pro');
  });

  test('already Pro on entry is dismissed', () {
    cubit.onProfileChanged(isPro: true);
    expect(cubit.state.status, PaywallStatus.done);
  });

  group('offerings loading (QA-034)', () {
    test('store refuses → storeUnavailable', () async {
      revenueCat.offeringsError = PlatformException(
        code: '${PurchasesErrorCode.purchaseNotAllowedError.index}',
      );
      await cubit.loadOfferings();
      expect(cubit.state.offerings, PaywallOfferings.storeUnavailable);
      expect(cubit.state.canContinue, isFalse);
    });

    test('other failure → failed', () async {
      revenueCat.offeringsError = PlatformException(
        code: '${PurchasesErrorCode.networkError.index}',
      );
      await cubit.loadOfferings();
      expect(cubit.state.offerings, PaywallOfferings.failed);
    });

    test('retry after a failure loads the offer', () async {
      revenueCat.offeringsError = PlatformException(
        code: '${PurchasesErrorCode.storeProblemError.index}',
      );
      await cubit.loadOfferings();
      revenueCat
        ..offeringsError = null
        ..offerings = offeringsWithAnnual();
      await cubit.loadOfferings();
      expect(cubit.state.offerings, PaywallOfferings.loaded);
      expect(cubit.state.canContinue, isTrue);
    });
  });

  group('purchase outcome by store error code', () {
    Future<void> purchaseFailingWith(PurchasesErrorCode code) async {
      revenueCat
        ..offerings = offeringsWithAnnual()
        ..purchaseError = PlatformException(code: '${code.index}', message: 'store says no');
      await cubit.loadOfferings();
      await cubit.purchase();
    }

    test('pending payment → pending, terminal, no error (QA-006)', () async {
      await purchaseFailingWith(PurchasesErrorCode.paymentPendingError);

      expect(cubit.state.status, PaywallStatus.pending);
      expect(cubit.state.isTerminal, isTrue);
      expect(cubit.state.failureCode, isNull);

      // Terminal: nothing moves it to `done` or back.
      cubit.onProfileChanged(isPro: true);
      cubit.dismiss();
      await cubit.restore();
      expect(cubit.state.status, PaywallStatus.pending);
    });

    test('cancelled → ready without an error', () async {
      await purchaseFailingWith(PurchasesErrorCode.purchaseCancelledError);

      expect(cubit.state.status, PaywallStatus.ready);
      expect(cubit.state.failureCode, isNull);
    });

    test('other store errors → ready with the store message', () async {
      await purchaseFailingWith(PurchasesErrorCode.storeProblemError);

      expect(cubit.state.status, PaywallStatus.ready);
      expect(cubit.state.failureCode, 'paywall_purchase');
      expect(cubit.state.failureMessage, 'store says no');
    });
  });
}

class _FakeRevenueCatService extends RevenueCatService {
  /// Null keeps offerings loading forever.
  Offerings? offerings;
  PlatformException? offeringsError;
  PlatformException? purchaseError;

  @override
  Future<Offerings> getOfferings() {
    final error = offeringsError;
    if (error != null) {
      return Future.error(error);
    }
    final value = offerings;
    return value == null ? Completer<Offerings>().future : Future.value(value);
  }

  @override
  Future<PurchaseResult> purchasePackage(Package package) {
    final error = purchaseError;
    return error == null ? Completer<PurchaseResult>().future : Future.error(error);
  }

  @override
  Future<CustomerInfo> restorePurchases() async => FakeCustomerInfo();
}
