import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/json_name.dart';
import 'package:asset_tuner/data/rate/dto/asset_rate_usd_dto.dart';

part 'asset_dto.freezed.dart';
part 'asset_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class AssetDto with _$AssetDto {
  const factory AssetDto({
    required String id,
    required String kind,
    required String code,
    required String name,
    required String provider,
    @JsonName('provider_ref') required String providerRef,
    required int rank,
    required int decimals,
    @JsonName('is_active') bool? isActive,
    @JsonName('is_locked') bool? isLocked,
    @JsonName('usd_rate') AssetRateUsdDto? usdRate,
    @JsonName('created_at') String? createdAtIso,
    @JsonName('updated_at') String? updatedAtIso,
  }) = _AssetDto;

  factory AssetDto.fromJson(Map<String, dynamic> json) {
    return _$AssetDtoFromJson(json);
  }
}
