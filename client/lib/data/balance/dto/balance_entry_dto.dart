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
    @JsonName('user_id') String? userId,
    @JsonName('subaccount_id') required String subaccountId,
    @JsonName('amount_atomic') @DecimalJsonConverter() required Decimal amountAtomic,
    @JsonName('amount_decimals') required int amountDecimals,
    String? note,
    @JsonName('diff_amount') @NullableDecimalJsonConverter() Decimal? diffAmount,
    @JsonName('created_at') required String createdAtIso,
  }) = _BalanceEntryDto;

  factory BalanceEntryDto.fromJson(Map<String, dynamic> json) {
    return _$BalanceEntryDtoFromJson(json);
  }
}
