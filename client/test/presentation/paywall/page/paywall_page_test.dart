import 'dart:async';

import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/profile/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/plan.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_cubit.dart';
import 'package:asset_tuner/presentation/paywall/page/paywall_page.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_loading_skeleton.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  group('PaywallPage', () {
    late _TestAuthCubit authCubit;
    late _TestProfileCubit profileCubit;
    late _TestAssetsCubit assetsCubit;

    setUp(() {
      if (getIt.isRegistered<AppAnalytics>()) {
        getIt.unregister<AppAnalytics>();
      }
      if (getIt.isRegistered<RevenueCatService>()) {
        getIt.unregister<RevenueCatService>();
      }
      getIt.registerLazySingleton<AppAnalytics>(AppAnalytics.new);
      getIt.registerLazySingleton<RevenueCatService>(_NeverCompletesRevenueCatService.new);
      if (getIt.isRegistered<PaywallCubit>()) {
        getIt.unregister<PaywallCubit>();
      }
      getIt.registerFactoryParam<PaywallCubit, PaywallArgs, dynamic>(
        (args, _) => PaywallCubit(getIt<RevenueCatService>(), getIt<AppAnalytics>(), args),
      );

      authCubit = _TestAuthCubit(
        const AuthState(
          status: AuthStatus.authenticated,
          session: AuthSessionEntity(userId: 'u-1', email: 'u@example.com'),
          revenueCatStatus: RevenueCatIdentityStatus.synced,
          revenueCatUserId: 'u-1',
        ),
      );
      profileCubit = _TestProfileCubit(const ProfileState(status: ProfileStatus.loading));
      assetsCubit = _TestAssetsCubit(const AssetsState(status: AssetsStatus.ready));
    });

    tearDown(() async {
      await authCubit.close();
      await profileCubit.close();
      await assetsCubit.close();
      if (getIt.isRegistered<AppAnalytics>()) {
        getIt.unregister<AppAnalytics>();
      }
      if (getIt.isRegistered<RevenueCatService>()) {
        getIt.unregister<RevenueCatService>();
      }
      if (getIt.isRegistered<PaywallCubit>()) {
        getIt.unregister<PaywallCubit>();
      }
    });

    testWidgets('shows loading skeleton while profile is loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthCubit>.value(value: authCubit),
              BlocProvider<ProfileCubit>.value(value: profileCubit),
              BlocProvider<AssetsCubit>.value(value: assetsCubit),
            ],
            child: const PaywallPage(args: PaywallArgs(reason: PaywallReason.onboarding)),
          ),
        ),
      );

      expect(find.byType(PaywallLoadingSkeleton), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
    });

    testWidgets('successful restore pops only the paywall (QA-003)', (tester) async {
      getIt.unregister<RevenueCatService>();
      getIt.registerLazySingleton<RevenueCatService>(_RestoreSucceedsRevenueCatService.new);
      profileCubit.emit(
        const ProfileState(
          status: ProfileStatus.ready,
          profile: ProfileEntity(
            userId: 'u-1',
            plan: Plan.free,
            entitlements: EntitlementsEntity(),
          ),
        ),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('home')),
            routes: [
              GoRoute(
                path: 'form',
                builder: (context, state) => const Scaffold(body: Text('form')),
                routes: [
                  GoRoute(
                    path: 'paywall',
                    builder: (context, state) =>
                        const PaywallPage(args: PaywallArgs(reason: PaywallReason.onboarding)),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
            BlocProvider<AssetsCubit>.value(value: assetsCubit),
          ],
          child: MaterialApp.router(
            theme: lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      router.go('/form');
      await tester.pumpAndSettle();
      unawaited(router.push('/form/paywall'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Restore'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(PaywallPage), findsNothing);
      expect(find.text('form'), findsOneWidget);
      expect(find.text('home'), findsNothing);
    });
  });
}

class _NeverCompletesRevenueCatService extends RevenueCatService {
  @override
  Future<Offerings> getOfferings() => Completer<Offerings>().future;
}

class _RestoreSucceedsRevenueCatService extends _NeverCompletesRevenueCatService {
  @override
  Future<CustomerInfo> restorePurchases() async => _FakeCustomerInfo();
}

class _FakeCustomerInfo implements CustomerInfo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _TestAuthCubit(super.initialState);

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

class _TestProfileCubit extends Cubit<ProfileState> implements ProfileCubit {
  _TestProfileCubit(super.initialState);

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> refresh({bool silent = false}) async {}

  @override
  Future<void> syncSubscription({
    bool silent = true,
    bool force = false,
    String placement = 'auto',
  }) async {
    final profile = state.profile;
    if (profile != null) {
      emit(state.copyWith(profile: profile.copyWith(plan: Plan.pro)));
    }
  }

  @override
  Future<void> updateBaseCurrency(String code) async {}
}

class _TestAssetsCubit extends Cubit<AssetsState> implements AssetsCubit {
  _TestAssetsCubit(super.initialState);

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh({bool silent = false, bool forceRefresh = false}) async {}
}
