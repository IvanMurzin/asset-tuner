import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core_ui/components/ds_chip.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/profile/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/overview/page/overview_page.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('overview base currency opens as pushed route and returns to main', (tester) async {
    SharedPreferences.setMockInitialValues({'guided_tour_overview_completed': true});
    final profileCubit = _TestProfileCubit(
      ProfileState(status: ProfileStatus.ready, profile: _profile()),
    );
    final accountsCubit = _TestAccountsCubit(const AccountsState(status: AccountsStatus.ready));
    final assetsCubit = _TestAssetsCubit(
      AssetsState(
        status: AssetsStatus.ready,
        assets: [_asset(id: 'asset-USD', code: 'USD')],
      ),
    );
    addTearDown(profileCubit.close);
    addTearDown(accountsCubit.close);
    addTearDown(assetsCubit.close);

    late final GoRouter router;
    router = GoRouter(
      initialLocation: AppRoutes.main,
      routes: [
        GoRoute(
          path: AppRoutes.main,
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<ProfileCubit>.value(value: profileCubit),
              BlocProvider<AccountsCubit>.value(value: accountsCubit),
              BlocProvider<AssetsCubit>.value(value: assetsCubit),
            ],
            child: const OverviewPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const Scaffold(body: Text('PROFILE')),
        ),
        GoRoute(
          path: AppRoutes.baseCurrencySettingsPush,
          builder: (context, state) => const Scaffold(body: Text('BASE_CURRENCY_PUSH')),
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

    expect(router.routerDelegate.currentConfiguration.uri.path, AppRoutes.main);

    final chip = tester.widget<DSChip>(find.byKey(const Key('overview_base_currency_chip')));
    chip.onTap!.call();
    await tester.pumpAndSettle();

    expect(find.text('BASE_CURRENCY_PUSH'), findsOneWidget);
    expect(router.canPop(), isTrue);

    router.pop();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('overview_base_currency_chip')), findsOneWidget);
    expect(find.text('PROFILE'), findsNothing);
  });
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

class _TestAccountsCubit extends Cubit<AccountsState> implements AccountsCubit {
  _TestAccountsCubit(super.initialState);

  @override
  Future<void> archive(AccountEntity account) async {}

  @override
  Future<void> create(AccountEntity account) async {}

  @override
  Future<void> delete(String accountId) async {}

  @override
  AccountEntity? findById(String id) => null;

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh({bool silent = false}) async {}

  @override
  Future<void> update(AccountEntity account) async {}

  @override
  void applyArchived(AccountEntity account) {}

  @override
  void applyCreated(AccountEntity account) {}

  @override
  void applyDeleted(String accountId) {}

  @override
  void applyUpdated(AccountEntity account) {}
}

class _TestAssetsCubit extends Cubit<AssetsState> implements AssetsCubit {
  _TestAssetsCubit(super.initialState);

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh({bool silent = false, bool forceRefresh = false}) async {}
}

ProfileEntity _profile() {
  return ProfileEntity(
    userId: 'u-1',
    baseAssetId: 'asset-USD',
    baseAsset: _asset(id: 'asset-USD', code: 'USD'),
    plan: 'pro',
    entitlements: const EntitlementsEntity(),
  );
}

AssetEntity _asset({required String id, required String code}) {
  return AssetEntity(
    id: id,
    kind: AssetKind.fiat,
    code: code,
    name: code,
    provider: '',
    providerRef: '',
    rank: 1,
    decimals: 2,
    isActive: true,
    isLocked: false,
  );
}
