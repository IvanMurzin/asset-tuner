import 'package:asset_tuner/data/profile/dto/entitlements_dto.dart';
import 'package:asset_tuner/domain/entitlement/entity/entitlements_entity.dart';
import 'package:asset_tuner/data/profile/dto/profile_dto.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';

abstract final class ProfileMapper {
  static ProfileEntity toEntity(ProfileDto dto) {
    return ProfileEntity(
      baseAssetId: dto.baseAssetId,
      baseCurrencyCode: dto.baseCurrencyCode,
      plan: dto.plan,
      entitlements: _entitlementsToEntity(dto.entitlements),
    );
  }

  static ProfileDto toDto(ProfileEntity entity) {
    return ProfileDto(
      baseAssetId: entity.baseAssetId,
      baseCurrencyCode: entity.baseCurrencyCode,
      plan: entity.plan,
      entitlements: _entitlementsToDto(entity.entitlements),
    );
  }

  static EntitlementsEntity _entitlementsToEntity(EntitlementsDto dto) {
    return EntitlementsEntity(
      maxAccounts: dto.maxAccounts,
      maxSubaccounts: dto.maxSubaccounts,
      fiatLimit: dto.fiatLimit,
      cryptoLimit: dto.cryptoLimit,
    );
  }

  static EntitlementsDto _entitlementsToDto(EntitlementsEntity entity) {
    return EntitlementsDto(
      maxAccounts: entity.maxAccounts,
      maxSubaccounts: entity.maxSubaccounts,
      fiatLimit: entity.fiatLimit,
      cryptoLimit: entity.cryptoLimit,
    );
  }
}
