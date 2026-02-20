import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/data/balance/dto/balance_entry_dto.dart';

part 'balance_history_response_dto.freezed.dart';
part 'balance_history_response_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class BalanceHistoryResponseDto with _$BalanceHistoryResponseDto {
  const factory BalanceHistoryResponseDto({
    required List<BalanceEntryDto> items,
    String? nextCursor,
  }) = _BalanceHistoryResponseDto;

  factory BalanceHistoryResponseDto.fromJson(Map<String, dynamic> json) {
    return _$BalanceHistoryResponseDtoFromJson(json);
  }
}
