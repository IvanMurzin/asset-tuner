import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/account_info_cubit.dart';
import 'package:asset_tuner/presentation/account/page/add_subaccount_page.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/asset/widget/asset_currency_badge.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_create_cubit.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AddSubaccountPage currency selector', () {
    late _TestAssetsCubit assetsCubit;
    late _TestAccountInfoCubit accountInfoCubit;

    setUp(() async {
      await getIt.reset();
      getIt.registerFactory<SubaccountCreateCubit>(() => _TestSubaccountCreateCubit());
      assetsCubit = _TestAssetsCubit(
        AssetsState(
          status: AssetsStatus.ready,
          assets: [
            _asset(id: 'fiat-usd', kind: AssetKind.fiat, code: 'USD', name: 'US Dollar'),
            _asset(id: 'crypto-btc', kind: AssetKind.crypto, code: 'BTC', name: 'Bitcoin'),
          ],
        ),
      );
    });

    tearDown(() async {
      await assetsCubit.close();
      await accountInfoCubit.close();
      await getIt.reset();
    });

    Future<void> pumpPage(WidgetTester tester, {required AccountType accountType}) async {
      accountInfoCubit = _TestAccountInfoCubit(
        AccountInfoState(
          status: AccountInfoStatus.ready,
          account: _account(type: accountType),
        ),
      );

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider<AssetsCubit>.value(value: assetsCubit),
                  BlocProvider<AccountInfoCubit>.value(value: accountInfoCubit),
                ],
                child: const AddSubaccountPage(accountId: 'account-1'),
              );
            },
          ),
          GoRoute(path: '/paywall', builder: (context, state) => const SizedBox.shrink()),
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

    testWidgets('removes type radio row and selects crypto from badge sheet', (tester) async {
      await pumpPage(tester, accountType: AccountType.bank);

      expect(find.byType(AssetCurrencyBadge), findsOneWidget);
      expect(find.text('Fiat'), findsNothing);
      expect(find.text('Crypto'), findsNothing);

      await tester.tap(find.byType(AssetCurrencyBadge));
      await tester.pumpAndSettle();

      expect(find.text('Fiat'), findsOneWidget);
      expect(find.text('Crypto'), findsOneWidget);

      await tester.tap(find.text('Crypto'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BTC • Bitcoin'));
      await tester.pumpAndSettle();

      expect(find.text('BTC'), findsOneWidget);
      expect(find.text('USD'), findsNothing);
    });

    testWidgets('preselects first fiat currency for bank account type', (tester) async {
      await pumpPage(tester, accountType: AccountType.bank);

      expect(find.text('USD'), findsOneWidget);
    });

    testWidgets('preselects first crypto currency for wallet account type', (tester) async {
      await pumpPage(tester, accountType: AccountType.wallet);

      expect(find.text('BTC'), findsOneWidget);
      expect(find.text('USD'), findsNothing);
    });

    testWidgets('does not preselect locked currency by default', (tester) async {
      assetsCubit.pushState(
        AssetsState(
          status: AssetsStatus.ready,
          assets: [
            _asset(
              id: 'fiat-locked',
              kind: AssetKind.fiat,
              code: 'LCK',
              name: 'Locked Fiat',
              isLocked: true,
            ),
          ],
        ),
      );
      await pumpPage(tester, accountType: AccountType.bank);

      expect(find.text('LCK'), findsNothing);
    });
  });
}

class _TestAssetsCubit extends Cubit<AssetsState> implements AssetsCubit {
  _TestAssetsCubit(super.initialState);

  void pushState(AssetsState state) => emit(state);

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh({bool silent = false}) async {}
}

class _TestSubaccountCreateCubit extends Cubit<SubaccountCreateState>
    implements SubaccountCreateCubit {
  _TestSubaccountCreateCubit() : super(const SubaccountCreateState());

  @override
  Future<void> submit({
    required String accountId,
    required String name,
    required AssetEntity asset,
    required Decimal snapshotAmount,
  }) async {}

  @override
  void clearNameError() {}

  @override
  void reset() {}
}

class _TestAccountInfoCubit extends Cubit<AccountInfoState> implements AccountInfoCubit {
  _TestAccountInfoCubit(super.initialState);

  @override
  Future<void> load({required String accountId, required AccountEntity? account}) async {}

  @override
  void setAccount(AccountEntity? account) {}

  @override
  Future<void> refreshSubaccounts({bool silent = true}) async {}

  @override
  Future<void> applyUpdatedSubaccount(SubaccountEntity updated) async {}

  @override
  Future<void> applyUpdatedSubaccountBalance({
    required String subaccountId,
    required Decimal amountAtomic,
    required int amountDecimals,
  }) async {}

  @override
  Future<void> applyDeletedSubaccount(String subaccountId) async {}

  @override
  Future<void> applyCreatedSubaccount(SubaccountEntity created) async {}

  @override
  void updateSubaccount(SubaccountEntity updated) {}

  @override
  void updateSubaccountBalance({
    required String subaccountId,
    required Decimal amountAtomic,
    required int amountDecimals,
  }) {}

  @override
  void deleteSubaccount(String subaccountId) {}

  @override
  void createSubaccount(SubaccountEntity created) {}

  @override
  void consumeNavigation() {}
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

AccountEntity _account({required AccountType type}) {
  return AccountEntity(
    id: 'account-1',
    name: 'Account',
    type: type,
    archived: false,
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
  );
}
