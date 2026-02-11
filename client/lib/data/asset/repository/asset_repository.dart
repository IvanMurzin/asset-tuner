import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/asset/data_source/supabase_asset_data_source.dart';
import 'package:asset_tuner/data/asset/mapper/asset_mapper.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/repository/i_asset_repository.dart';

@LazySingleton(as: IAssetRepository)
class AssetRepository implements IAssetRepository {
  AssetRepository(this._dataSource);

  final SupabaseAssetDataSource _dataSource;

  @override
  Future<Result<List<AssetEntity>>> fetchAssets() async {
    try {
      final dtos = await _dataSource.fetchAssets();
      final entities = dtos.map(AssetMapper.toEntity).toList();
      logger.i('AssetRepository.fetchAssets success: ${entities.length}');
      return Success(entities);
    } catch (error) {
      logger.e('AssetRepository.fetchAssets failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to load assets',
        ),
      );
    }
  }
}
