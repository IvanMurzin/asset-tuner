import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_history_page_entity.dart';
import 'package:asset_tuner/domain/balance/repository/i_balance_repository.dart';
import 'package:asset_tuner/domain/balance/usecase/get_balance_history_usecase.dart';
import 'package:asset_tuner/domain/balance/usecase/get_current_balances_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/domain/subaccount/repository/i_subaccount_repository.dart';
import 'package:asset_tuner/domain/subaccount/usecase/get_subaccounts_usecase.dart';
import 'package:asset_tuner/presentation/analytics/bloc/analytics_cubit.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsCubit', () {
    test('excludes zero-delta updates from analytics feed', () async {
      final subaccount = SubaccountEntity(
        id: 'sub-1',
        accountId: 'acc-1',
        assetId: 'asset-1',
        name: 'BTC wallet',
        archived: false,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );

      final historyEntries = [
        BalanceEntryEntity(
          id: 'history-zero',
          subaccountId: 'sub-1',
          amountAtomic: Decimal.parse('10000'),
          amountDecimals: 2,
          diffAmount: Decimal.zero,
          createdAt: DateTime.utc(2026, 3, 10),
        ),
        BalanceEntryEntity(
          id: 'history-positive',
          subaccountId: 'sub-1',
          amountAtomic: Decimal.parse('10500'),
          amountDecimals: 2,
          diffAmount: Decimal.parse('5'),
          createdAt: DateTime.utc(2026, 3, 9),
        ),
      ];

      final subaccountRepository = _FakeSubaccountRepository(
        subaccountsByAccount: {
          'acc-1': [subaccount],
        },
      );
      final balanceRepository = _FakeBalanceRepository(
        currentBalances: {'sub-1': Decimal.parse('100')},
        historyBySubaccount: {'sub-1': BalanceHistoryPageEntity(entries: historyEntries)},
      );

      final cubit = AnalyticsCubit(
        GetSubaccountsUseCase(subaccountRepository),
        GetCurrentBalancesUseCase(balanceRepository),
        GetBalanceHistoryUseCase(balanceRepository),
      );

      await cubit.onSourceDataReady(
        ProfileEntity(
          plan: 'free',
          entitlements: const EntitlementsEntity(plan: 'free'),
        ),
        RatesSnapshotEntity(
          usdPriceByAssetId: {'asset-1': Decimal.one},
          asOf: DateTime.utc(2026, 3, 10),
        ),
        const [
          AssetEntity(
            id: 'asset-1',
            kind: AssetKind.crypto,
            code: 'BTC',
            name: 'Bitcoin',
            decimals: 8,
            isActive: true,
            isLocked: false,
          ),
        ],
        [
          AccountEntity(
            id: 'acc-1',
            name: 'Wallet',
            type: AccountType.wallet,
            archived: false,
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ],
      );

      expect(cubit.state.status, AnalyticsStatus.ready);
      expect(cubit.state.updates, hasLength(1));
      expect(cubit.state.updates.first.diffAmount, Decimal.parse('5'));

      await cubit.close();
    });
  });
}

class _FakeSubaccountRepository implements ISubaccountRepository {
  _FakeSubaccountRepository({required this.subaccountsByAccount});

  final Map<String, List<SubaccountEntity>> subaccountsByAccount;

  @override
  Future<Result<List<SubaccountEntity>>> fetchSubaccounts({required String accountId}) async {
    return Success(subaccountsByAccount[accountId] ?? const <SubaccountEntity>[]);
  }

  @override
  Future<Result<SubaccountEntity>> createSubaccount({
    required String accountId,
    required String name,
    required AssetEntity asset,
    required Decimal snapshotAmount,
    required DateTime entryDate,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<SubaccountEntity>> renameSubaccount({
    required String subaccountId,
    required String name,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteSubaccount({required String subaccountId}) {
    throw UnimplementedError();
  }
}

class _FakeBalanceRepository implements IBalanceRepository {
  _FakeBalanceRepository({required this.currentBalances, required this.historyBySubaccount});

  final Map<String, Decimal> currentBalances;
  final Map<String, BalanceHistoryPageEntity> historyBySubaccount;

  @override
  Future<Result<BalanceHistoryPageEntity>> fetchHistory({
    required String subaccountId,
    required int limit,
    String? cursor,
  }) async {
    return Success(
      historyBySubaccount[subaccountId] ?? const BalanceHistoryPageEntity(entries: []),
    );
  }

  @override
  Future<Result<BalanceEntryEntity>> updateBalance({
    required String subaccountId,
    required DateTime entryDate,
    required Decimal snapshotAmount,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, Decimal>>> fetchCurrentBalances({
    required Set<String> subaccountIds,
  }) async {
    return Success(currentBalances);
  }
}
