import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_entry_entity.freezed.dart';

enum BalanceEntryType { snapshot, delta }

@freezed
abstract class BalanceEntryEntity with _$BalanceEntryEntity {
  const factory BalanceEntryEntity({
    required String id,
    required String accountAssetId,
    required DateTime entryDate,
    required BalanceEntryType entryType,
    Decimal? snapshotAmount,
    Decimal? deltaAmount,
    Decimal? impliedDeltaAmount,
    required DateTime createdAt,
  }) = _BalanceEntryEntity;
}
