import 'package:decimal/decimal.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_history_page_entity.dart';

abstract interface class IBalanceRepository {
  Future<Result<BalanceHistoryPageEntity>> fetchHistory({
    required String userId,
    required String accountAssetId,
    required int limit,
    int? offset,
  });

  Future<Result<BalanceEntryEntity>> updateBalance({
    required String userId,
    required String accountAssetId,
    required DateTime entryDate,
    Decimal? snapshotAmount,
    Decimal? deltaAmount,
  });
}
