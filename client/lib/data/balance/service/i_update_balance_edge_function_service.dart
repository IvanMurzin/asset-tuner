import 'package:decimal/decimal.dart';
import 'package:asset_tuner/data/balance/dto/balance_entry_dto.dart';

abstract interface class IUpdateBalanceEdgeFunctionService {
  Future<BalanceEntryDto> updateBalance({
    required String userId,
    required String accountAssetId,
    required DateTime entryDate,
    Decimal? snapshotAmount,
    Decimal? deltaAmount,
  });
}
