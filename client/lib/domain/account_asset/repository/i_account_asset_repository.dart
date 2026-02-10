import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';

abstract interface class IAccountAssetRepository {
  Future<Result<List<AccountAssetEntity>>> fetchAccountAssets({
    required String userId,
    required String accountId,
  });

  Future<Result<int>> countAssetPositions(String userId);

  Future<Result<AccountAssetEntity>> addAssetToAccount({
    required String userId,
    required String accountId,
    required String assetId,
  });

  Future<Result<void>> removeAssetFromAccount({
    required String userId,
    required String accountId,
    required String assetId,
  });
}
