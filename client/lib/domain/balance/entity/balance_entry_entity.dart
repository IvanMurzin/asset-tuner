import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_entry_entity.freezed.dart';

@freezed
abstract class BalanceEntryEntity with _$BalanceEntryEntity {
  const factory BalanceEntryEntity({
    required String id,
    required String subaccountId,
    required DateTime entryDate,
    required Decimal snapshotAmount,
    Decimal? diffAmount,
    required DateTime createdAt,
  }) = _BalanceEntryEntity;
}
