import 'package:asset_tuner/core/local_storage/account_asset_storage.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';

abstract final class AccountAssetMapper {
  static AccountAssetEntity toEntity(StoredAccountAsset stored) {
    return AccountAssetEntity(
      id: stored.id,
      accountId: stored.accountId,
      assetId: stored.assetId,
      sortOrder: stored.sortOrder,
      createdAt: DateTime.parse(stored.createdAtIso),
    );
  }
}
