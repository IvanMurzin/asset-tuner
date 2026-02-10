import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/json_name.dart';

part 'balance_entry_dto.freezed.dart';
part 'balance_entry_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class BalanceEntryDto with _$BalanceEntryDto {
  const factory BalanceEntryDto({
    required String id,
    @JsonName('account_asset_id') required String accountAssetId,
    @JsonName('entry_date') required String entryDateIso,
    @JsonName('entry_type') required String entryType,
    @JsonName('snapshot_amount') String? snapshotAmount,
    @JsonName('delta_amount') String? deltaAmount,
    @JsonName('implied_delta_amount') String? impliedDeltaAmount,
    @JsonName('created_at') required String createdAtIso,
  }) = _BalanceEntryDto;

  factory BalanceEntryDto.fromJson(Map<String, dynamic> json) {
    return _$BalanceEntryDtoFromJson(json);
  }
}
