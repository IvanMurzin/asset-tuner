import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/decimal_json_converter.dart';
import 'package:asset_tuner/core/types/json_name.dart';

part 'balance_entry_dto.freezed.dart';
part 'balance_entry_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class BalanceEntryDto with _$BalanceEntryDto {
  const factory BalanceEntryDto({
    required String id,
    @JsonName('subaccount_id') required String subaccountId,
    @JsonName('entry_date') required String entryDateIso,
    @JsonName('snapshot_amount') @DecimalJsonConverter() required Decimal snapshotAmount,
    @JsonName('diff_amount') @NullableDecimalJsonConverter() Decimal? diffAmount,
    @JsonName('created_at') required String createdAtIso,
  }) = _BalanceEntryDto;

  factory BalanceEntryDto.fromJson(Map<String, dynamic> json) {
    return _$BalanceEntryDtoFromJson(json);
  }
}
