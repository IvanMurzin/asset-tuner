import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_history_page_entity.dart';
import 'package:asset_tuner/domain/balance/repository/i_balance_repository.dart';
import 'package:asset_tuner/domain/balance/usecase/get_balance_history_usecase.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_info_cubit.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubaccountInfoCubit', () {
    late _FakeBalanceRepository balanceRepository;
    late SubaccountInfoCubit cubit;

    setUp(() {
      balanceRepository = _FakeBalanceRepository(
        pages: [
          BalanceHistoryPageEntity(
            entries: [
              _entry(id: 'entry-zero-initial', diffAmount: Decimal.zero),
              _entry(id: 'entry-positive', diffAmount: Decimal.parse('10')),
              _entry(id: 'entry-first', diffAmount: null),
            ],
            nextCursor: 'cursor-1',
          ),
          BalanceHistoryPageEntity(
            entries: [
              _entry(id: 'entry-zero-more', diffAmount: Decimal.zero),
              _entry(id: 'entry-negative', diffAmount: Decimal.parse('-2')),
            ],
          ),
        ],
      );

      cubit = SubaccountInfoCubit(GetBalanceHistoryUseCase(balanceRepository));
    });

    tearDown(() async {
      await cubit.close();
    });

    test('filters zero-delta history entries on refresh and pagination', () async {
      await cubit.load(account: _account(), subaccount: _subaccount());

      expect(cubit.state.entries.map((e) => e.id), ['entry-positive', 'entry-first']);
      expect(cubit.state.nextCursor, 'cursor-1');

      await cubit.loadMore();

      expect(cubit.state.entries.map((e) => e.id), [
        'entry-positive',
        'entry-first',
        'entry-negative',
      ]);
      expect(cubit.state.nextCursor, isNull);
    });
  });
}

BalanceEntryEntity _entry({required String id, required Decimal? diffAmount}) {
  return BalanceEntryEntity(
    id: id,
    subaccountId: 'sub-1',
    amountAtomic: Decimal.parse('10000'),
    amountDecimals: 2,
    diffAmount: diffAmount,
    createdAt: DateTime.utc(2026, 3, 1),
  );
}

AccountEntity _account() {
  return AccountEntity(
    id: 'acc-1',
    name: 'Wallet',
    type: AccountType.wallet,
    archived: false,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}

SubaccountEntity _subaccount() {
  return SubaccountEntity(
    id: 'sub-1',
    accountId: 'acc-1',
    assetId: 'asset-1',
    name: 'Main',
    archived: false,
    asset: const AssetEntity(
      id: 'asset-1',
      kind: AssetKind.crypto,
      code: 'BTC',
      name: 'Bitcoin',
      decimals: 8,
      isActive: true,
      isLocked: false,
    ),
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );
}

class _FakeBalanceRepository implements IBalanceRepository {
  _FakeBalanceRepository({required this.pages});

  final List<BalanceHistoryPageEntity> pages;
  int _fetchCalls = 0;

  @override
  Future<Result<BalanceHistoryPageEntity>> fetchHistory({
    required String subaccountId,
    required int limit,
    String? cursor,
  }) async {
    final index = _fetchCalls < pages.length ? _fetchCalls : pages.length - 1;
    _fetchCalls += 1;
    return Success(pages[index]);
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
  Future<Result<Map<String, Decimal>>> fetchCurrentBalances({required Set<String> subaccountIds}) {
    throw UnimplementedError();
  }
}
