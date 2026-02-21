import 'package:asset_tuner/data/asset/mapper/asset_mapper.dart';
import 'package:asset_tuner/data/rate/dto/asset_rate_usd_dto.dart';
import 'package:asset_tuner/data/subaccount/dto/subaccount_dto.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';

abstract final class SubaccountMapper {
  static SubaccountEntity toEntity(SubaccountDto dto) {
    return SubaccountEntity(
      id: dto.id,
      userId: dto.userId,
      accountId: dto.accountId,
      assetId: dto.assetId,
      name: dto.name,
      archived: dto.archived,
      currentAmountAtomic: dto.currentAmountAtomic,
      currentAmountDecimals: dto.currentAmountDecimals,
      asset: dto.asset == null ? null : AssetMapper.toEntity(dto.asset!),
      usdRate: _usdRateToEntity(dto.usdRate),
      createdAt: DateTime.parse(dto.createdAtIso),
      updatedAt: DateTime.parse(dto.updatedAtIso),
    );
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
