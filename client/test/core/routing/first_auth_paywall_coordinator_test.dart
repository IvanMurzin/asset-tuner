import 'package:asset_tuner/core/local_storage/onboarding_paywall_storage.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/core/routing/first_auth_paywall_coordinator.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  group('FirstAuthPaywallCoordinator', () {
    testWidgets('seen=false + revenuecat ready -> opens paywall once and sets seen', (t) async {
      final authCubit = _FakeAuthCubit();
      final storage = _FakeOnboardingPaywallStorage(seen: false);
      var opens = 0;

      await _pumpCoordinator(
        t: t,
        authCubit: authCubit,
        storage: storage,
        revenueCatService: _FakeRevenueCatService.available(),
        onOpenPaywall: () async => opens += 1,
      );

      authCubit.setState(_readyState);
      await t.pumpAndSettle();

      expect(opens, 1);
      expect(storage.setSeenCalls, 1);
    });

    testWidgets('repeated ready emissions do not open paywall twice', (t) async {
      final authCubit = _FakeAuthCubit();
      final storage = _FakeOnboardingPaywallStorage(seen: false);
      var opens = 0;

      await _pumpCoordinator(
        t: t,
        authCubit: authCubit,
        storage: storage,
        revenueCatService: _FakeRevenueCatService.available(),
        onOpenPaywall: () async => opens += 1,
      );

      authCubit.setState(_readyState);
      await t.pumpAndSettle();
      authCubit.setState(_readyState);
      await t.pumpAndSettle();

      expect(opens, 1);
      expect(storage.setSeenCalls, 1);
    });

    testWidgets('seen=true does not open paywall', (t) async {
      final authCubit = _FakeAuthCubit();
      final storage = _FakeOnboardingPaywallStorage(seen: true);
      var opens = 0;

      await _pumpCoordinator(
        t: t,
        authCubit: authCubit,
        storage: storage,
        revenueCatService: _FakeRevenueCatService.available(),
        onOpenPaywall: () async => opens += 1,
      );

      authCubit.setState(_readyState);
      await t.pumpAndSettle();

      expect(opens, 0);
      expect(storage.setSeenCalls, 0);
    });

    testWidgets('not ready state does not open paywall', (t) async {
      final authCubit = _FakeAuthCubit();
      final storage = _FakeOnboardingPaywallStorage(seen: false);
      var opens = 0;

      await _pumpCoordinator(
        t: t,
        authCubit: authCubit,
        storage: storage,
        revenueCatService: _FakeRevenueCatService.available(),
        onOpenPaywall: () async => opens += 1,
      );

      authCubit.setState(
        const AuthState(
          status: AuthStatus.authenticated,
          session: AuthSessionEntity(userId: 'u-1', email: 'u-1@example.com'),
          revenueCatStatus: RevenueCatIdentityStatus.syncing,
          revenueCatUserId: null,
        ),
      );
      await t.pumpAndSettle();

      expect(opens, 0);
      expect(storage.setSeenCalls, 0);
    });

    testWidgets('store unavailable does not open paywall and does not set seen', (t) async {
      final authCubit = _FakeAuthCubit();
      final storage = _FakeOnboardingPaywallStorage(seen: false);
      var opens = 0;

      await _pumpCoordinator(
        t: t,
        authCubit: authCubit,
        storage: storage,
        revenueCatService: _FakeRevenueCatService.unavailable(),
        onOpenPaywall: () async => opens += 1,
      );

      authCubit.setState(_readyState);
      await t.pumpAndSettle(const Duration(seconds: 2));

      expect(opens, 0);
      expect(storage.setSeenCalls, 0);
    });
  });
}

Future<void> _pumpCoordinator({
  required WidgetTester t,
  required _FakeAuthCubit authCubit,
  required _FakeOnboardingPaywallStorage storage,
  required _FakeRevenueCatService revenueCatService,
  required Future<void> Function() onOpenPaywall,
}) {
  return t.pumpWidget(
    MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: FirstAuthPaywallCoordinator(
          authCubit: authCubit,
          router: _router,
          revenueCatService: revenueCatService,
          storage: storage,
          onOpenPaywall: onOpenPaywall,
          child: const SizedBox.shrink(),
        ),
      ),
    ),
  );
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [GoRoute(path: '/', builder: (context, state) => const SizedBox.shrink())],
);

const _readyState = AuthState(
  status: AuthStatus.authenticated,
  session: AuthSessionEntity(userId: 'u-1', email: 'u-1@example.com'),
  revenueCatStatus: RevenueCatIdentityStatus.synced,
  revenueCatUserId: 'u-1',
);

class _FakeOnboardingPaywallStorage extends OnboardingPaywallStorage {
  _FakeOnboardingPaywallStorage({required bool seen}) : _seen = seen;

  bool _seen;
  int setSeenCalls = 0;

  @override
  Future<bool> getSeen() async => _seen;

  @override
  Future<void> setSeen() async {
    setSeenCalls += 1;
    _seen = true;
  }
}

class _FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _FakeAuthCubit() : super(const AuthState());

  void setState(AuthState state) => emit(state);

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> forceLocalSignOut() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> syncRevenueCat() async {}
}

class _FakeRevenueCatService extends RevenueCatService {
  _FakeRevenueCatService._(this._available);

  final bool _available;

  factory _FakeRevenueCatService.available() => _FakeRevenueCatService._(true);
  factory _FakeRevenueCatService.unavailable() => _FakeRevenueCatService._(false);

  @override
  Future<Offerings> getOfferings() async {
    if (!_available) {
      throw Exception('store unavailable');
    }
    return Offerings(
      const {},
      current: Offering(
        'default',
        'default',
        const {},
        const [],
      ),
    );
  }
}
