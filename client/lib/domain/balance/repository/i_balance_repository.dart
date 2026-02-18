import 'package:decimal/decimal.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_history_page_entity.dart';

abstract interface class IBalanceRepository {
  Future<Result<BalanceHistoryPageEntity>> fetchHistory({
    required String subaccountId,
    required int limit,
    String? cursor,
  });

  Future<Result<BalanceEntryEntity>> updateBalance({
    required String subaccountId,
    required DateTime entryDate,
    required Decimal snapshotAmount,
  });

  Future<Result<Map<String, Decimal>>> fetchCurrentBalances({
    required Set<String> subaccountIds,
  });
}
