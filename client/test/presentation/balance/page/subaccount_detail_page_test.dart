import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/profile/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/account/bloc/account_info_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';
import 'package:asset_tuner/presentation/asset/bloc/assets_cubit.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_delete_cubit.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_info_cubit.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_update_cubit.dart';
import 'package:asset_tuner/presentation/balance/page/subaccount_detail_page.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('SubaccountDetailPage scroll and refresh', () {
    late _TestSubaccountInfoCubit subaccountInfoCubit;
    late _TestAccountInfoCubit accountInfoCubit;
    late _TestAccountsCubit accountsCubit;
    late _TestProfileCubit profileCubit;
    late _TestAssetsCubit assetsCubit;
    late _TestSubaccountUpdateCubit updateCubit;
    late _TestSubaccountDeleteCubit deleteCubit;

    setUp(() {
      final account = _account();
      final subaccount = _subaccount();
      subaccountInfoCubit = _TestSubaccountInfoCubit(
        SubaccountInfoState(
          status: SubaccountInfoStatus.ready,
          account: account,
          subaccount: subaccount,
          entries: _entries(subaccount.id),
          nextCursor: 'cursor-1',
        ),
      );
      accountInfoCubit = _TestAccountInfoCubit(
        AccountInfoState(
          status: AccountInfoStatus.ready,
          account: account,
          subaccounts: [subaccount],
        ),
      );
      accountsCubit = _TestAccountsCubit(
        AccountsState(status: AccountsStatus.ready, accounts: [account]),
      );
      profileCubit = _TestProfileCubit(
        ProfileState(
          status: ProfileStatus.ready,
          profile: ProfileEntity(
            plan: 'free',
            entitlements: const EntitlementsEntity(plan: 'free', fiatLimit: 100),
          ),
        ),
      );
      assetsCubit = _TestAssetsCubit(const AssetsState(status: AssetsStatus.ready));
      updateCubit = _TestSubaccountUpdateCubit();
      deleteCubit = _TestSubaccountDeleteCubit();
    });

    tearDown(() async {
      await subaccountInfoCubit.close();
      await accountInfoCubit.close();
      await accountsCubit.close();
      await profileCubit.close();
      await assetsCubit.close();
      await updateCubit.close();
      await deleteCubit.close();
    });

    testWidgets('scrolls entire screen with a single root list', (tester) async {
      await _pumpPage(
        tester,
        subaccountInfoCubit: subaccountInfoCubit,
        accountInfoCubit: accountInfoCubit,
        accountsCubit: accountsCubit,
        profileCubit: profileCubit,
        assetsCubit: assetsCubit,
        updateCubit: updateCubit,
        deleteCubit: deleteCubit,
      );

      expect(find.byType(ListView), findsOneWidget);

      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.pixels, 0);

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(scrollable.position.pixels, greaterThan(0));
    });

    testWidgets('refresh triggers only from top position', (tester) async {
      await _pumpPage(
        tester,
        subaccountInfoCubit: subaccountInfoCubit,
        accountInfoCubit: accountInfoCubit,
        accountsCubit: accountsCubit,
        profileCubit: profileCubit,
        assetsCubit: assetsCubit,
        updateCubit: updateCubit,
        deleteCubit: deleteCubit,
      );

      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(scrollable.position.pixels, greaterThan(0));

      await tester.drag(find.byType(ListView), const Offset(0, 120));
      await tester.pumpAndSettle();
      expect(scrollable.position.pixels, greaterThan(0));
      expect(subaccountInfoCubit.refreshCalls, 0);

      scrollable.position.jumpTo(0);
      await tester.pump();

      await tester.drag(find.byType(ListView), const Offset(0, 340));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(subaccountInfoCubit.refreshCalls, 1);
    });

    testWidgets('shows set balance action label', (tester) async {
      await _pumpPage(
        tester,
        subaccountInfoCubit: subaccountInfoCubit,
        accountInfoCubit: accountInfoCubit,
        accountsCubit: accountsCubit,
        profileCubit: profileCubit,
        assetsCubit: assetsCubit,
        updateCubit: updateCubit,
        deleteCubit: deleteCubit,
      );

      expect(find.text('Set balance'), findsOneWidget);
      expect(find.text('Update balance'), findsNothing);
    });
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required SubaccountInfoCubit subaccountInfoCubit,
  required AccountInfoCubit accountInfoCubit,
  required AccountsCubit accountsCubit,
  required ProfileCubit profileCubit,
  required AssetsCubit assetsCubit,
  required SubaccountUpdateCubit updateCubit,
  required SubaccountDeleteCubit deleteCubit,
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<SubaccountInfoCubit>.value(value: subaccountInfoCubit),
              BlocProvider<AccountInfoCubit>.value(value: accountInfoCubit),
              BlocProvider<AccountsCubit>.value(value: accountsCubit),
              BlocProvider<ProfileCubit>.value(value: profileCubit),
              BlocProvider<AssetsCubit>.value(value: assetsCubit),
              BlocProvider<SubaccountUpdateCubit>.value(value: updateCubit),
              BlocProvider<SubaccountDeleteCubit>.value(value: deleteCubit),
            ],
            child: const SubaccountDetailPage(
              accountId: 'account-1',
              subaccountId: 'subaccount-1',
              initialTitle: 'Wallet',
            ),
          );
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

class _TestSubaccountInfoCubit extends Cubit<SubaccountInfoState> implements SubaccountInfoCubit {
  _TestSubaccountInfoCubit(super.initialState);

  int refreshCalls = 0;

  @override
  Future<void> load({required AccountEntity account, required SubaccountEntity subaccount}) async {}

  @override
  Future<void> refreshHistory({bool showLoading = true}) async {
    refreshCalls += 1;
  }

  @override
  Future<void> loadMore() async {}

  @override
  void updateSubaccount(SubaccountEntity subaccount) {}

  @override
  void onDeleted() {}

  @override
  void consumeNavigation() {}
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

class _TestAccountsCubit extends Cubit<AccountsState> implements AccountsCubit {
  _TestAccountsCubit(super.initialState);

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh({bool silent = false}) async {}

  @override
  Future<void> create(AccountEntity account) async {}

  @override
  Future<void> update(AccountEntity account) async {}

  @override
  Future<void> archive(AccountEntity account) async {}

  @override
  Future<void> delete(String accountId) async {}

  @override
  void applyCreated(AccountEntity account) {}

  @override
  void applyUpdated(AccountEntity account) {}

  @override
  void applyArchived(AccountEntity account) {}

  @override
  void applyDeleted(String accountId) {}

  @override
  AccountEntity? findById(String id) {
    return null;
  }
}

class _TestProfileCubit extends Cubit<ProfileState> implements ProfileCubit {
  _TestProfileCubit(super.initialState);

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> refresh({bool silent = false}) async {}

  @override
  Future<void> updateBaseCurrency(String code) async {}

  @override
  Future<void> syncSubscription() async {}
}

class _TestAssetsCubit extends Cubit<AssetsState> implements AssetsCubit {
  _TestAssetsCubit(super.initialState);

  @override
  Future<void> load() async {}

  @override
  Future<void> refresh({bool silent = false}) async {}
}

class _TestSubaccountUpdateCubit extends Cubit<SubaccountUpdateState>
    implements SubaccountUpdateCubit {
  _TestSubaccountUpdateCubit() : super(const SubaccountUpdateState());

  @override
  Future<void> submit({required String subaccountId, required String name}) async {}

  @override
  void reset() {}
}

class _TestSubaccountDeleteCubit extends Cubit<SubaccountDeleteState>
    implements SubaccountDeleteCubit {
  _TestSubaccountDeleteCubit() : super(const SubaccountDeleteState());

  @override
  Future<void> submit(String subaccountId) async {}

  @override
  void reset() {}
}

AccountEntity _account() {
  return AccountEntity(
    id: 'account-1',
    name: 'Wallet',
    type: AccountType.wallet,
    archived: false,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}

SubaccountEntity _subaccount() {
  return SubaccountEntity(
    id: 'subaccount-1',
    accountId: 'account-1',
    assetId: 'asset-1',
    name: 'Main',
    archived: false,
    currentAmountAtomic: Decimal.fromInt(12345),
    currentAmountDecimals: 2,
    asset: AssetEntity(
      id: 'asset-1',
      kind: AssetKind.fiat,
      code: 'USD',
      name: 'US Dollar',
      rank: 1,
      decimals: 2,
      isActive: true,
      isLocked: false,
    ),
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}

List<BalanceEntryEntity> _entries(String subaccountId) {
  return List<BalanceEntryEntity>.generate(20, (index) {
    return BalanceEntryEntity(
      id: 'entry-$index',
      subaccountId: subaccountId,
      amountAtomic: Decimal.fromInt(12345 + index * 100),
      amountDecimals: 2,
      diffAmount: index == 0 ? null : Decimal.fromInt(100),
      createdAt: DateTime.utc(2026, 1, 1).subtract(Duration(days: index)),
    );
  });
}
