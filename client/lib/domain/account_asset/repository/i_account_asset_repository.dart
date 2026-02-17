import 'package:decimal/decimal.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';

abstract interface class IAccountAssetRepository {
  Future<Result<List<AccountAssetEntity>>> fetchAccountAssets({required String accountId});

  Future<Result<int>> countAssetPositions();

  Future<Result<AccountAssetEntity>> addAssetToAccount({
    required String accountId,
    required String name,
    required String assetId,
    required Decimal snapshotAmount,
    required DateTime entryDate,
  });

  Future<Result<AccountAssetEntity>> renameSubaccount({
    required String subaccountId,
    required String name,
  });

  Future<Result<void>> removeAssetFromAccount({required String subaccountId});
}
