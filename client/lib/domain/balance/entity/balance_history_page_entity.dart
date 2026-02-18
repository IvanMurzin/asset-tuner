import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';

class BalanceHistoryPageEntity {
  const BalanceHistoryPageEntity({required this.entries, this.nextCursor});

  final List<BalanceEntryEntity> entries;
  final String? nextCursor;
}
