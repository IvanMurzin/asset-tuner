import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/json_name.dart';
import 'package:asset_tuner/data/asset/dto/asset_dto.dart';
import 'package:asset_tuner/data/profile/dto/entitlements_dto.dart';

part 'profile_dto.freezed.dart';
part 'profile_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class ProfileDto with _$ProfileDto {
  const factory ProfileDto({
    @JsonName('user_id') String? userId,
    @JsonName('base_asset_id') String? baseAssetId,
    required String plan,
    required EntitlementsDto entitlements,
    @JsonName('revenuecat_app_user_id') String? revenuecatAppUserId,
    @JsonName('created_at') String? createdAtIso,
    @JsonName('updated_at') String? updatedAtIso,
    AssetDto? baseAsset,
  }) = _ProfileDto;

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return _$ProfileDtoFromJson(json);
  }

  factory ProfileDto.fromMeJson(Map<String, dynamic> json) {
    final profile =
        (json['profile'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final limits =
        (json['limits'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final baseAssetRaw = json['baseAsset'] as Map<String, dynamic>?;

    return ProfileDto(
      userId: profile['user_id'] as String?,
      baseAssetId: profile['base_asset_id'] as String?,
      plan: ((profile['plan'] as String?) ?? 'free').toLowerCase(),
      entitlements: EntitlementsDto.fromJson(limits),
      revenuecatAppUserId: profile['revenuecat_app_user_id'] as String?,
      createdAtIso: profile['created_at'] as String?,
      updatedAtIso: profile['updated_at'] as String?,
      baseAsset: baseAssetRaw == null ? null : AssetDto.fromJson(baseAssetRaw),
    );
  }
}
