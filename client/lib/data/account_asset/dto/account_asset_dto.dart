import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:decimal/decimal.dart';
import 'package:asset_tuner/core/types/json_name.dart';
import 'package:asset_tuner/core/types/decimal_json_converter.dart';
import 'package:asset_tuner/data/asset/dto/asset_dto.dart';
import 'package:asset_tuner/data/rate/dto/asset_rate_usd_dto.dart';

part 'account_asset_dto.freezed.dart';
part 'account_asset_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class AccountAssetDto with _$AccountAssetDto {
  const factory AccountAssetDto({
    required String id,
    @JsonName('user_id') String? userId,
    @JsonName('account_id') required String accountId,
    @JsonName('asset_id') required String assetId,
    required String name,
    required bool archived,
    @JsonName('current_amount_atomic')
    @NullableDecimalJsonConverter()
    Decimal? currentAmountAtomic,
    @JsonName('current_amount_decimals') int? currentAmountDecimals,
    AssetDto? asset,
    @JsonName('usd_rate') AssetRateUsdDto? usdRate,
    @JsonName('created_at') required String createdAtIso,
    @JsonName('updated_at') required String updatedAtIso,
  }) = _AccountAssetDto;

  factory AccountAssetDto.fromJson(Map<String, dynamic> json) {
    return _$AccountAssetDtoFromJson(json);
  }
}
