import 'package:asset_tuner/data/profile/dto/entitlements_dto.dart';
import 'package:asset_tuner/domain/entitlement/entity/entitlements_entity.dart';
import 'package:asset_tuner/data/asset/mapper/asset_mapper.dart';
import 'package:asset_tuner/data/profile/dto/profile_dto.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';

abstract final class ProfileMapper {
  static ProfileEntity toEntity(ProfileDto dto) {
    return ProfileEntity(
      userId: dto.userId,
      baseAssetId: dto.baseAssetId,
      baseAsset: dto.baseAsset == null
          ? null
          : AssetMapper.toEntity(dto.baseAsset!),
      revenuecatAppUserId: dto.revenuecatAppUserId,
      createdAt: _parseDateOrNull(dto.createdAtIso),
      updatedAt: _parseDateOrNull(dto.updatedAtIso),
      plan: dto.plan,
      entitlements: _entitlementsToEntity(dto.entitlements),
    );
  }

  static ProfileDto toDto(ProfileEntity entity) {
    return ProfileDto(
      userId: entity.userId,
      baseAssetId: entity.baseAssetId,
      plan: entity.plan,
      entitlements: _entitlementsToDto(entity.entitlements),
      revenuecatAppUserId: entity.revenuecatAppUserId,
      createdAtIso: entity.createdAt?.toIso8601String(),
      updatedAtIso: entity.updatedAt?.toIso8601String(),
      baseAsset: entity.baseAsset == null
          ? null
          : AssetMapper.toDto(entity.baseAsset!),
    );
  }

  static EntitlementsEntity _entitlementsToEntity(EntitlementsDto dto) {
    return EntitlementsEntity(
      plan: dto.plan,
      maxAccounts: dto.maxAccounts,
      maxSubaccounts: dto.maxSubaccounts,
      fiatLimit: dto.fiatLimit,
      cryptoLimit: dto.cryptoLimit,
    );
  }

  static EntitlementsDto _entitlementsToDto(EntitlementsEntity entity) {
    return EntitlementsDto(
      plan: entity.plan,
      maxAccounts: entity.maxAccounts,
      maxSubaccounts: entity.maxSubaccounts,
      fiatLimit: entity.fiatLimit,
      cryptoLimit: entity.cryptoLimit,
    );
  }

  static DateTime? _parseDateOrNull(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
