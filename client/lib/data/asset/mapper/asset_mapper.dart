import 'package:asset_tuner/data/asset/dto/asset_dto.dart';
import 'package:asset_tuner/data/rate/dto/asset_rate_usd_dto.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';

abstract final class AssetMapper {
  static AssetEntity toEntity(AssetDto dto) {
    return AssetEntity(
      id: dto.id,
      kind: _kindFromWire(dto.kind),
      code: dto.code,
      name: dto.name,
      provider: dto.provider,
      providerRef: dto.providerRef,
      rank: dto.rank,
      decimals: dto.decimals,
      isActive: dto.isActive,
      isLocked: dto.isLocked,
      usdRate: _usdRateToEntity(dto.usdRate),
      createdAt: _parseDateOrNull(dto.createdAtIso),
      updatedAt: _parseDateOrNull(dto.updatedAtIso),
    );
  }

  static AssetDto toDto(AssetEntity entity) {
    return AssetDto(
      id: entity.id,
      kind: _kindToWire(entity.kind),
      code: entity.code,
      name: entity.name,
      provider: entity.provider ?? '',
      providerRef: entity.providerRef ?? '',
      rank: entity.rank ?? 0,
      decimals: entity.decimals ?? 0,
      isActive: entity.isActive,
      isLocked: entity.isLocked,
      usdRate: _usdRateToDto(entity.usdRate),
      createdAtIso: entity.createdAt?.toIso8601String(),
      updatedAtIso: entity.updatedAt?.toIso8601String(),
    );
  }

  static AssetKind _kindFromWire(String kind) {
    return switch (kind) {
      'fiat' => AssetKind.fiat,
      'crypto' => AssetKind.crypto,
      _ => AssetKind.fiat,
    };
  }

  static String _kindToWire(AssetKind kind) {
    return switch (kind) {
      AssetKind.fiat => 'fiat',
      AssetKind.crypto => 'crypto',
    };
  }

  static AssetUsdRateEntity? _usdRateToEntity(AssetRateUsdDto? dto) {
    if (dto == null) {
      return null;
    }
    final asOf = DateTime.tryParse(dto.asOfIso);
    if (asOf == null) {
      return null;
    }
    return AssetUsdRateEntity(
      assetId: dto.assetId,
      usdPriceAtomic: dto.usdPriceAtomic,
      usdPriceDecimals: dto.usdPriceDecimals,
      asOf: asOf,
    );
  }

  static AssetRateUsdDto? _usdRateToDto(AssetUsdRateEntity? rate) {
    if (rate == null) {
      return null;
    }
    return AssetRateUsdDto(
      assetId: rate.assetId,
      usdPriceAtomic: rate.usdPriceAtomic,
      usdPriceDecimals: rate.usdPriceDecimals,
      asOfIso: rate.asOf.toIso8601String(),
    );
  }

  static DateTime? _parseDateOrNull(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
