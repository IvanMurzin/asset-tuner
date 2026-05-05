import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/utils/money_atomic.dart';

part 'balance_entry_entity.freezed.dart';

@freezed
abstract class BalanceEntryEntity with _$BalanceEntryEntity {
  const BalanceEntryEntity._();

  const factory BalanceEntryEntity({
    required String id,
    String? userId,
    required String subaccountId,
    required Decimal amountAtomic,
    required int amountDecimals,
    String? note,
    Decimal? diffAmount,
    required DateTime createdAt,
  }) = _BalanceEntryEntity;

  DateTime get entryDate => createdAt;

  Decimal get snapshotAmount {
    return MoneyAtomic.fromAtomic(amountAtomic.toString(), amountDecimals);
  }
}
