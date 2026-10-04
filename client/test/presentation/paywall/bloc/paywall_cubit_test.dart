import 'dart:async';

import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
}

class _FakeRevenueCatService extends RevenueCatService {
  @override
  Future<Offerings> getOfferings() => Completer<Offerings>().future;

  @override
  Future<CustomerInfo> restorePurchases() async => _FakeCustomerInfo();
}

class _FakeCustomerInfo implements CustomerInfo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
