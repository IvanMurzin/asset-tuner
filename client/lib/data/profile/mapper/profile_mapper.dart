import 'package:asset_tuner/data/profile/dto/entitlements_dto.dart';
import 'package:asset_tuner/domain/entitlement/entity/entitlements_entity.dart';
import 'package:asset_tuner/data/profile/dto/profile_dto.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';

abstract final class ProfileMapper {
  static ProfileEntity toEntity(ProfileDto dto) {
    return ProfileEntity(
      baseCurrency: dto.baseCurrency,
      plan: dto.plan,
      entitlements: _entitlementsToEntity(dto.entitlements),
    );
  }

  static ProfileDto toDto(ProfileEntity entity) {
    return ProfileDto(
      baseCurrency: entity.baseCurrency,
      plan: entity.plan,
      entitlements: _entitlementsToDto(entity.entitlements),
    );
  }

  static EntitlementsEntity _entitlementsToEntity(EntitlementsDto dto) {
    return EntitlementsEntity(
      maxAccounts: dto.maxAccounts,
      maxSubaccounts: dto.maxSubaccounts,
      anyBaseCurrency: dto.anyBaseCurrency,
      freeBaseCurrencyCodes: dto.allowedBaseCurrencyCodes
          .map((e) => e.toUpperCase())
          .toSet(),
      expiresAt: dto.expiresAtIso == null
          ? null
          : DateTime.parse(dto.expiresAtIso!),
    );
  }

  static EntitlementsDto _entitlementsToDto(EntitlementsEntity entity) {
    return EntitlementsDto(
      maxAccounts: entity.maxAccounts,
      maxSubaccounts: entity.maxSubaccounts,
      anyBaseCurrency: entity.anyBaseCurrency,
      allowedBaseCurrencyCodes: entity.freeBaseCurrencyCodes
          .map((e) => e.toUpperCase())
          .toList(),
      expiresAtIso: entity.expiresAt?.toIso8601String(),
    );
  }
}
