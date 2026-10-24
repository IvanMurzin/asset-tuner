import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_unlock_currencies_card.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/profile/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/asset/widget/asset_currency_badge.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_args.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';
import 'package:asset_tuner/presentation/settings/page/base_currency_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asset_tuner/domain/profile/entity/plan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('BaseCurrencySettingsPage', () {
    late _TestAuthCubit sessionCubit;
    late _TestProfileCubit profileCubit;
    late _TestAssetsCubit assetsCubit;

    setUp(() {
      if (!getIt.isRegistered<AppAnalytics>()) {
        getIt.registerLazySingleton<AppAnalytics>(AppAnalytics.new);
      }
      sessionCubit = _TestAuthCubit(
        AuthState(
          status: AuthStatus.authenticated,
          session: const AuthSessionEntity(userId: 'user-1', email: 'user@example.com'),
        ),
      );
      profileCubit = _TestProfileCubit(
        ProfileState(
          status: ProfileStatus.ready,
          profile: _profile(baseCode: 'USD'),
        ),
      );
      assetsCubit = _TestAssetsCubit(
        AssetsState(
          status: AssetsStatus.ready,
          assets: [
            _asset(id: 'fiat-usd', kind: AssetKind.fiat, code: 'USD', name: 'US Dollar'),
            _asset(id: 'fiat-eur', kind: AssetKind.fiat, code: 'EUR', name: 'Euro'),
          ],
        ),
      );
    });

    tearDown(() async {
      await sessionCubit.close();
      await profileCubit.close();
      await assetsCubit.close();
    });

    testWidgets('renders top card text and currency badge', (tester) async {
      await _pumpPage(
        tester,
        sessionCubit: sessionCubit,
        profileCubit: profileCubit,
        assetsCubit: assetsCubit,
      );

      final context = tester.element(find.byType(BaseCurrencySettingsPage));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.baseCurrencySettingsCurrentTitle), findsOneWidget);
      expect(find.text(l10n.baseCurrencySettingsCurrentBody), findsOneWidget);
      expect(find.byType(AssetCurrencyBadge), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
    });

    testWidgets('changes selected badge code after choosing another fiat currency', (tester) async {
      await _pumpPage(
        tester,
        sessionCubit: sessionCubit,
        profileCubit: profileCubit,
        assetsCubit: assetsCubit,
      );

      await tester.tap(find.byType(AssetCurrencyBadge));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Euro'));
      await tester.pumpAndSettle();

      expect(find.text('EUR'), findsOneWidget);
      expect(find.text('USD'), findsNothing);
    });

    testWidgets('shows unlock card for free plan and opens paywall by action tap', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      profileCubit = _TestProfileCubit(
        ProfileState(
          status: ProfileStatus.ready,
          profile: _profile(baseCode: 'USD', plan: Plan.free, fiatLimit: 5),
        ),
      );
      PaywallArgs? openedArgs;

      await _pumpPage(
        tester,
        sessionCubit: sessionCubit,
        profileCubit: profileCubit,
        assetsCubit: assetsCubit,
        onPaywallOpened: (args) => openedArgs = args,
      );

      final context = tester.element(find.byType(BaseCurrencySettingsPage));
      final l10n = AppLocalizations.of(context)!;

      expect(find.byType(DSUnlockCurrenciesCard), findsOneWidget);
      expect(find.text(l10n.paywallFeatureCurrencies), findsOneWidget);
      expect(find.text(l10n.baseCurrencySettingsPaywallHint), findsOneWidget);
      expect(find.text(l10n.paywallUpgrade), findsOneWidget);

      final unlockCardFinder = find.byType(DSUnlockCurrenciesCard);
      await tester.ensureVisible(unlockCardFinder);
      await tester.tap(unlockCardFinder);
      await tester.pumpAndSettle();

      expect(openedArgs?.reason, PaywallReason.baseCurrency);
    });

    group('locked currency from the picker (QA-021)', () {
      late _TestProfileCubit freeProfile;

      setUp(() {
        freeProfile = _TestProfileCubit(
          ProfileState(
            status: ProfileStatus.ready,
            profile: _profile(baseCode: 'USD', plan: Plan.free, fiatLimit: 5),
          ),
        );
        assetsCubit.emit(
          assetsCubit.state.copyWith(
            assets: [
              ...assetsCubit.state.assets,
              _asset(
                id: 'fiat-cad',
                kind: AssetKind.fiat,
                code: 'CAD',
                name: 'Canadian Dollar',
                isLocked: true,
              ),
            ],
          ),
        );
      });

      tearDown(() => freeProfile.close());

      /// A stand-in paywall: "buy" unlocks every currency, "close" leaves the plan as is.
      Widget fakePaywall(BuildContext context) => Scaffold(
        body: Column(
          children: [
            TextButton(
              onPressed: () {
                freeProfile.emit(
                  ProfileState(
                    status: ProfileStatus.ready,
                    profile: _profile(baseCode: 'USD'),
                  ),
                );
                context.pop();
              },
              child: const Text('fake-buy'),
            ),
            TextButton(onPressed: () => context.pop(), child: const Text('fake-close')),
          ],
        ),
      );

      Future<void> pickLockedCad(WidgetTester tester) async {
        await _pumpPage(
          tester,
          sessionCubit: sessionCubit,
          profileCubit: freeProfile,
          assetsCubit: assetsCubit,
          paywallBuilder: fakePaywall,
        );
        await tester.tap(find.byType(AssetCurrencyBadge));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Canadian Dollar'));
        await tester.pumpAndSettle();
      }

      testWidgets('buying Pro applies the requested currency', (tester) async {
        await pickLockedCad(tester);
        await tester.tap(find.text('fake-buy'));
        await tester.pumpAndSettle();

        expect(freeProfile.updatedBaseCurrencies, ['CAD']);
        expect(find.text('CAD'), findsOneWidget);
      });

      testWidgets('closing the paywall changes nothing', (tester) async {
        await pickLockedCad(tester);
        await tester.tap(find.text('fake-close'));
        await tester.pumpAndSettle();

        expect(freeProfile.updatedBaseCurrencies, isEmpty);
        expect(find.text('USD'), findsOneWidget);
      });
    });
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required AuthCubit sessionCubit,
  required ProfileCubit profileCubit,
  required AssetsCubit assetsCubit,
  ValueChanged<PaywallArgs?>? onPaywallOpened,
  WidgetBuilder? paywallBuilder,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.baseCurrencySettings,
    routes: [
      GoRoute(
        path: AppRoutes.baseCurrencySettings,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: sessionCubit),
            BlocProvider<ProfileCubit>.value(value: profileCubit),
            BlocProvider<AssetsCubit>.value(value: assetsCubit),
          ],
          child: const BaseCurrencySettingsPage(),
        ),
      ),
      GoRoute(path: AppRoutes.signIn, builder: (context, state) => const SizedBox.shrink()),
      GoRoute(
        path: AppRoutes.paywall,
        builder: (context, state) {
          onPaywallOpened?.call(state.extra as PaywallArgs?);
          return paywallBuilder?.call(context) ?? const SizedBox.shrink();
        },
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
  await tester.pumpAndSettle();
}

class _TestAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _TestAuthCubit(super.initialState);

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> syncRevenueCat() async {}
}

class _TestProfileCubit extends Cubit<ProfileState> implements ProfileCubit {
  _TestProfileCubit(super.initialState);

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> refresh({bool silent = false, bool forceRefresh = false}) async {}

  final updatedBaseCurrencies = <String>[];

  @override
  Future<void> updateBaseCurrency(String code) async => updatedBaseCurrencies.add(code);

  @override
  Future<void> syncSubscription({
    bool silent = true,
    bool force = false,
    String placement = 'auto',
  }) async {}
}

class _TestAssetsCubit extends Cubit<AssetsState> implements AssetsCubit {
  _TestAssetsCubit(super.initialState);

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh({bool silent = false, bool forceRefresh = false}) async {}
}

ProfileEntity _profile({required String baseCode, Plan plan = Plan.pro, int? fiatLimit}) {
  return ProfileEntity(
    userId: 'user-1',
    baseAssetId: 'asset-$baseCode',
    baseAsset: _asset(id: 'asset-$baseCode', kind: AssetKind.fiat, code: baseCode, name: baseCode),
    plan: plan,
    entitlements: EntitlementsEntity(fiatLimit: fiatLimit),
  );
}

AssetEntity _asset({
  required String id,
  required AssetKind kind,
  required String code,
  required String name,
  bool isLocked = false,
}) {
  return AssetEntity(
    id: id,
    kind: kind,
    code: code,
    name: name,
    provider: '',
    providerRef: '',
    rank: 1,
    decimals: 2,
    isActive: true,
    isLocked: isLocked,
  );
}
