import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:decimal/decimal.dart';
import 'package:asset_tuner/core/types/json_name.dart';
import 'package:asset_tuner/core/types/decimal_json_converter.dart';

part 'account_dto.freezed.dart';
part 'account_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class AccountDto with _$AccountDto {
  const factory AccountDto({
    required String id,
    @JsonName('user_id') String? userId,
    required String name,
    required String type,
    required bool archived,
    @JsonName('subaccounts_count') int? subaccountsCount,
    AccountTotalsDto? totals,
    AccountCacheDto? cache,
    @JsonName('cached_total_usd_atomic')
    @NullableDecimalJsonConverter()
    Decimal? cachedTotalUsdAtomic,
    @JsonName('cached_total_usd_decimals') int? cachedTotalUsdDecimals,
    @JsonName('cached_total_updated_at') String? cachedTotalUpdatedAtIso,
    @JsonName('created_at') required String createdAtIso,
    @JsonName('updated_at') required String updatedAtIso,
  }) = _AccountDto;

  factory AccountDto.fromJson(Map<String, dynamic> json) {
    return _$AccountDtoFromJson(json);
  }
}

@Freezed(fromJson: true, toJson: true)
abstract class AccountTotalsDto with _$AccountTotalsDto {
  const factory AccountTotalsDto({
    @JsonName('total_usd_atomic')
    @NullableDecimalJsonConverter()
    Decimal? totalUsdAtomic,
    @JsonName('total_usd_decimals') int? totalUsdDecimals,
    @JsonName('total_in_base_atomic')
    @NullableDecimalJsonConverter()
    Decimal? totalInBaseAtomic,
    @JsonName('total_in_base_decimals') int? totalInBaseDecimals,
    @JsonName('base_asset_id') String? baseAssetId,
    @JsonName('base_asset_code') String? baseAssetCode,
  }) = _AccountTotalsDto;

  factory AccountTotalsDto.fromJson(Map<String, dynamic> json) {
    return _$AccountTotalsDtoFromJson(json);
  }
}

@Freezed(fromJson: true, toJson: true)
abstract class AccountCacheDto with _$AccountCacheDto {
  const factory AccountCacheDto({
    @JsonName('cached_total_usd_atomic')
    @NullableDecimalJsonConverter()
    Decimal? cachedTotalUsdAtomic,
    @JsonName('cached_total_usd_decimals') int? cachedTotalUsdDecimals,
    @JsonName('cached_total_updated_at') String? cachedTotalUpdatedAtIso,
  }) = _AccountCacheDto;

  factory AccountCacheDto.fromJson(Map<String, dynamic> json) {
    return _$AccountCacheDtoFromJson(json);
  }
}
