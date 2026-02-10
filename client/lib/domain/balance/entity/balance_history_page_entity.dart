import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';

part 'balance_history_page_entity.freezed.dart';

@freezed
abstract class BalanceHistoryPageEntity with _$BalanceHistoryPageEntity {
  const factory BalanceHistoryPageEntity({
    required List<BalanceEntryEntity> entries,
    int? nextOffset,
  }) = _BalanceHistoryPageEntity;
}
