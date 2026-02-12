import 'package:asset_tuner/data/account_asset/dto/account_asset_dto.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';

abstract final class AccountAssetMapper {
  static AccountAssetEntity toEntity(AccountAssetDto dto) {
    return AccountAssetEntity(
      id: dto.id,
      accountId: dto.accountId,
      assetId: dto.assetId,
      name: dto.name,
      archived: dto.archived,
      sortOrder: dto.sortOrder,
      createdAt: DateTime.parse(dto.createdAtIso),
      updatedAt: DateTime.parse(dto.updatedAtIso),
    );
  }
}
