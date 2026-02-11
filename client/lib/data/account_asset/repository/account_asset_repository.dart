import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/account_asset/data_source/supabase_account_asset_data_source.dart';
import 'package:asset_tuner/data/account_asset/mapper/account_asset_mapper.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/repository/i_account_asset_repository.dart';

@LazySingleton(as: IAccountAssetRepository)
class AccountAssetRepository implements IAccountAssetRepository {
  AccountAssetRepository(this._dataSource);

  final SupabaseAccountAssetDataSource _dataSource;

  @override
  Future<Result<List<AccountAssetEntity>>> fetchAccountAssets({
    required String accountId,
  }) async {
    try {
      final dtos = await _dataSource.fetchAccountAssets(accountId: accountId);
      logger.i('AccountAssetRepository.fetchAccountAssets success');
      return Success(dtos.map(AccountAssetMapper.toEntity).toList());
    } catch (error) {
      logger.e(
        'AccountAssetRepository.fetchAccountAssets failed',
        error: error,
      );
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to load account assets',
        ),
      );
    }
  }

  @override
  Future<Result<int>> countAssetPositions() async {
    try {
      final count = await _dataSource.countAssetPositions();
      logger.i('AccountAssetRepository.countAssetPositions success: $count');
      return Success(count);
    } catch (error) {
      logger.e(
        'AccountAssetRepository.countAssetPositions failed',
        error: error,
      );
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to count positions',
        ),
      );
    }
  }

  @override
  Future<Result<AccountAssetEntity>> addAssetToAccount({
    required String accountId,
    required String assetId,
  }) async {
    try {
      final dto = await _dataSource.addAssetToAccount(
        accountId: accountId,
        assetId: assetId,
      );
      logger.i('AccountAssetRepository.addAssetToAccount success');
      return Success(AccountAssetMapper.toEntity(dto));
    } catch (error) {
      logger.e('AccountAssetRepository.addAssetToAccount failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to add asset to account',
        ),
      );
    }
  }

  @override
  Future<Result<void>> removeAssetFromAccount({
    required String accountId,
    required String assetId,
  }) async {
    try {
      await _dataSource.removeAssetFromAccount(
        accountId: accountId,
        assetId: assetId,
      );
      logger.i('AccountAssetRepository.removeAssetFromAccount success');
      return const Success(null);
    } catch (error) {
      logger.e(
        'AccountAssetRepository.removeAssetFromAccount failed',
        error: error,
      );
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to remove asset from account',
        ),
      );
    }
  }
}
