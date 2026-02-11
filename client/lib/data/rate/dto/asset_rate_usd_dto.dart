import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/json_name.dart';

part 'asset_rate_usd_dto.freezed.dart';
part 'asset_rate_usd_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class AssetRateUsdDto with _$AssetRateUsdDto {
  const factory AssetRateUsdDto({
    @JsonName('asset_id') required String assetId,
    @JsonName('usd_price') required String usdPrice,
    @JsonName('as_of') required String asOfIso,
  }) = _AssetRateUsdDto;

  factory AssetRateUsdDto.fromJson(Map<String, dynamic> json) {
    return _$AssetRateUsdDtoFromJson(json);
  }
}
