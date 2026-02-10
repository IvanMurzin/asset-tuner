import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';

abstract interface class IAssetRepository {
  Future<Result<List<AssetEntity>>> fetchAssets();
}
