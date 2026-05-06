import 'dart:async';

import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/paywall/page/paywall_page.dart';
import 'package:asset_tuner/presentation/paywall/widget/paywall_loading_skeleton.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });
}

class _NeverCompletesRevenueCatService extends RevenueCatService {
  @override
  Future<Offerings> getOfferings() => Completer<Offerings>().future;
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
  }) async {}

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
