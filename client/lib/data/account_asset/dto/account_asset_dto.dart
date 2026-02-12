import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/json_name.dart';

part 'account_asset_dto.freezed.dart';
part 'account_asset_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class AccountAssetDto with _$AccountAssetDto {
  const factory AccountAssetDto({
    required String id,
    @JsonName('account_id') required String accountId,
    @JsonName('asset_id') required String assetId,
    required String name,
    required bool archived,
    @JsonName('sort_order') int? sortOrder,
    @JsonName('created_at') required String createdAtIso,
    @JsonName('updated_at') required String updatedAtIso,
  }) = _AccountAssetDto;

  factory AccountAssetDto.fromJson(Map<String, dynamic> json) {
    return _$AccountAssetDtoFromJson(json);
  }
}
