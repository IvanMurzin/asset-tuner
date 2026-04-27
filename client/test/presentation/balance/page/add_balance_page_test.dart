import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core_ui/components/ds_decimal_field.dart';
import 'package:asset_tuner/core_ui/theme/app_theme.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/l10n/app_localizations.dart';
import 'package:asset_tuner/presentation/asset/widget/asset_currency_badge.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_balance_cubit.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_info_cubit.dart';
import 'package:asset_tuner/presentation/balance/page/add_balance_page.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AddBalancePage', () {
    late _TestSubaccountInfoCubit subaccountInfoCubit;

    setUp(() async {
      await getIt.reset();
      getIt.registerFactory<SubaccountBalanceCubit>(() => _TestSubaccountBalanceCubit());

      subaccountInfoCubit = _TestSubaccountInfoCubit(
        SubaccountInfoState(
          status: SubaccountInfoStatus.ready,
          subaccount: _subaccountWithAssetCode('USD'),
        ),
      );
    });

    tearDown(() async {
      await subaccountInfoCubit.close();
      await getIt.reset();
    });

    testWidgets('shows readonly currency badge in set-balance form', (tester) async {
      await _pumpPage(tester, subaccountInfoCubit);
      await tester.pumpAndSettle();

      final badge = tester.widget<AssetCurrencyBadge>(find.byType(AssetCurrencyBadge));
      expect(find.text('USD'), findsOneWidget);
      expect(badge.enabled, isFalse);
    });

    testWidgets('prefills amount with current balance', (tester) async {
      await _pumpPage(tester, subaccountInfoCubit);
      await tester.pumpAndSettle();

      final amountField = tester.widget<DSDecimalField>(find.byType(DSDecimalField));
      expect(amountField.controller?.text, '123.45');
    });

    testWidgets('shows inline validation error when amount is empty', (tester) async {
      await _pumpPage(tester, subaccountInfoCubit);
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(AddBalancePage));
      final l10n = AppLocalizations.of(context)!;

      await tester.enterText(
        find.descendant(of: find.byType(DSDecimalField), matching: find.byType(EditableText)),
        '',
      );
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      expect(find.text(l10n.addBalanceValidationAmount), findsOneWidget);
    });

    testWidgets('shows set balance copy in english', (tester) async {
      await _pumpPage(tester, subaccountInfoCubit, locale: const Locale('en'));
      await tester.pumpAndSettle();

      expect(find.text('Set balance'), findsOneWidget);
      expect(find.text('Set the new current balance value for this subaccount.'), findsOneWidget);
    });

    testWidgets('shows set balance copy in russian', (tester) async {
      await _pumpPage(tester, subaccountInfoCubit, locale: const Locale('ru'));
      await tester.pumpAndSettle();

      expect(find.text('Установить баланс'), findsOneWidget);
      expect(find.text('Вы задаете новое текущее значение баланса этого счёта.'), findsOneWidget);
    });
  });
}

Future<void> _pumpPage(
  WidgetTester tester,
  SubaccountInfoCubit subaccountInfoCubit, {
  Locale locale = const Locale('en'),
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider<SubaccountInfoCubit>.value(
          value: subaccountInfoCubit,
          child: const AddBalancePage(accountId: 'account-1', subaccountId: 'subaccount-1'),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      locale: locale,
      theme: lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

class _TestSubaccountBalanceCubit extends Cubit<SubaccountBalanceState>
    implements SubaccountBalanceCubit {
  _TestSubaccountBalanceCubit() : super(const SubaccountBalanceState());

  @override
  Future<void> submit({
    required String subaccountId,
    required DateTime entryDate,
    required Decimal snapshotAmount,
  }) async {}

  @override
  void reset() {}
}

class _TestSubaccountInfoCubit extends Cubit<SubaccountInfoState> implements SubaccountInfoCubit {
  _TestSubaccountInfoCubit(super.initialState);

  @override
  Future<void> load({required AccountEntity account, required SubaccountEntity subaccount}) async {}

  @override
  Future<void> refreshHistory({bool showLoading = true}) async {}

  @override
  Future<void> loadMore() async {}

  @override
  void updateSubaccount(SubaccountEntity subaccount) {}

  @override
  void onDeleted() {}

  @override
  void consumeNavigation() {}
}

SubaccountEntity _subaccountWithAssetCode(String code) {
  return SubaccountEntity(
    id: 'subaccount-1',
    accountId: 'account-1',
    assetId: 'asset-1',
    name: 'Main wallet',
    archived: false,
    currentAmountAtomic: Decimal.parse('12345'),
    currentAmountDecimals: 2,
    asset: AssetEntity(
      id: 'asset-1',
      kind: AssetKind.fiat,
      code: code,
      name: code,
      provider: '',
      providerRef: '',
      rank: 1,
      decimals: 2,
      isActive: true,
      isLocked: false,
    ),
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}
