import 'package:asset_tuner/data/asset/dto/asset_picker_item_dto.dart';
import 'package:asset_tuner/data/rate/dto/asset_rate_usd_dto.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_picker_item_entity.dart';

abstract final class AssetPickerItemMapper {
  static AssetPickerItemEntity toEntity(AssetPickerItemDto dto) {
    return AssetPickerItemEntity(
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
    );
  }

  static AssetKind _kindFromWire(String kind) {
    return switch (kind) {
      'fiat' => AssetKind.fiat,
      'crypto' => AssetKind.crypto,
      _ => AssetKind.fiat,
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
}
