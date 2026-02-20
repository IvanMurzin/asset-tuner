import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/json_name.dart';
import 'package:asset_tuner/data/rate/dto/asset_rate_usd_dto.dart';

part 'asset_picker_item_dto.freezed.dart';
part 'asset_picker_item_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class AssetPickerItemDto with _$AssetPickerItemDto {
  const factory AssetPickerItemDto({
    required String id,
    required String kind,
    required String code,
    required String name,
    required String provider,
    @JsonName('provider_ref') required String providerRef,
    required int rank,
    required int decimals,
    @JsonName('is_active') required bool isActive,
    @JsonName('is_locked') required bool isLocked,
    @JsonName('usd_rate') AssetRateUsdDto? usdRate,
  }) = _AssetPickerItemDto;

  factory AssetPickerItemDto.fromJson(Map<String, dynamic> json) {
    return _$AssetPickerItemDtoFromJson(json);
  }
}
