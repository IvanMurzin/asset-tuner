import 'package:asset_tuner/core/types/decimal_json_converter.dart';
import 'package:asset_tuner/core/types/json_name.dart';
import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_summary_dto.freezed.dart';
part 'analytics_summary_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class AnalyticsSummaryDto with _$AnalyticsSummaryDto {
  const factory AnalyticsSummaryDto({
    @JsonName('base_currency') required String baseCurrency,
    @JsonName('as_of') String? asOfIso,
    @Default(<AnalyticsSummaryBreakdownDto>[]) List<AnalyticsSummaryBreakdownDto> breakdown,
    @Default(<AnalyticsSummaryUpdateDto>[]) List<AnalyticsSummaryUpdateDto> updates,
  }) = _AnalyticsSummaryDto;

  factory AnalyticsSummaryDto.fromJson(Map<String, dynamic> json) {
    return _$AnalyticsSummaryDtoFromJson(json);
  }
}

@Freezed(fromJson: true, toJson: true)
abstract class AnalyticsSummaryBreakdownDto with _$AnalyticsSummaryBreakdownDto {
  const factory AnalyticsSummaryBreakdownDto({
    @JsonName('asset_code') required String assetCode,
    @JsonName('original_amount_atomic')
    @DecimalJsonConverter()
    required Decimal originalAmountAtomic,
    @JsonName('original_amount_decimals') required int originalAmountDecimals,
    @JsonName('value_atomic') @DecimalJsonConverter() required Decimal valueAtomic,
    @JsonName('value_decimals') required int valueDecimals,
  }) = _AnalyticsSummaryBreakdownDto;

  factory AnalyticsSummaryBreakdownDto.fromJson(Map<String, dynamic> json) {
    return _$AnalyticsSummaryBreakdownDtoFromJson(json);
  }
}

@Freezed(fromJson: true, toJson: true)
abstract class AnalyticsSummaryUpdateDto with _$AnalyticsSummaryUpdateDto {
  const factory AnalyticsSummaryUpdateDto({
    @JsonName('account_name') required String accountName,
    @JsonName('subaccount_name') required String subaccountName,
    @JsonName('asset_code') required String assetCode,
    @JsonName('diff_atomic') @DecimalJsonConverter() required Decimal diffAtomic,
    @JsonName('diff_decimals') required int diffDecimals,
    @JsonName('diff_base_atomic') @DecimalJsonConverter() required Decimal diffBaseAtomic,
    @JsonName('diff_base_decimals') required int diffBaseDecimals,
    @JsonName('created_at') required String createdAtIso,
  }) = _AnalyticsSummaryUpdateDto;

  factory AnalyticsSummaryUpdateDto.fromJson(Map<String, dynamic> json) {
    return _$AnalyticsSummaryUpdateDtoFromJson(json);
  }
}
