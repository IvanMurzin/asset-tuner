import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/account_asset/data_source/account_asset_mock_data_source.dart';
import 'package:asset_tuner/data/account_asset/mapper/account_asset_mapper.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/repository/i_account_asset_repository.dart';

@LazySingleton(as: IAccountAssetRepository)
class AccountAssetRepository implements IAccountAssetRepository {
  AccountAssetRepository(this._dataSource);

  final AccountAssetMockDataSource _dataSource;

  @override
  Future<Result<List<AccountAssetEntity>>> fetchAccountAssets({
    required String userId,
    required String accountId,
  }) async {
    try {
      final stored = await _dataSource.fetchAccountPositions(
        userId: userId,
        accountId: accountId,
      );
      logger.i('AccountAssetRepository.fetchAccountAssets success');
      return Success(stored.map(AccountAssetMapper.toEntity).toList());
    } catch (_) {
      logger.e('AccountAssetRepository.fetchAccountAssets failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to load account assets'),
      );
    }
  }

  @override
  Future<Result<int>> countAssetPositions(String userId) async {
    try {
      final count = await _dataSource.countPositions(userId);
      logger.i('AccountAssetRepository.countAssetPositions success: $count');
      return Success(count);
    } catch (_) {
      logger.e('AccountAssetRepository.countAssetPositions failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to count positions'),
      );
    }
  }

  @override
  Future<Result<AccountAssetEntity>> addAssetToAccount({
    required String userId,
    required String accountId,
    required String assetId,
  }) async {
    try {
      final stored = await _dataSource.addPosition(
        userId: userId,
        accountId: accountId,
        assetId: assetId,
      );
      logger.i('AccountAssetRepository.addAssetToAccount success');
      return Success(AccountAssetMapper.toEntity(stored));
    } on MockAccountAssetException catch (e) {
      logger.w('AccountAssetRepository.addAssetToAccount failed: ${e.code}');
      return FailureResult(_mapMockFailure(e));
    } catch (_) {
      logger.e('AccountAssetRepository.addAssetToAccount failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to add asset to account'),
      );
    }
  }

  @override
  Future<Result<void>> removeAssetFromAccount({
    required String userId,
    required String accountId,
    required String assetId,
  }) async {
    try {
      await _dataSource.removePosition(
        userId: userId,
        accountId: accountId,
        assetId: assetId,
      );
      logger.i('AccountAssetRepository.removeAssetFromAccount success');
      return const Success(null);
    } on MockAccountAssetException catch (e) {
      logger.w(
        'AccountAssetRepository.removeAssetFromAccount failed: ${e.code}',
      );
      return FailureResult(_mapMockFailure(e));
    } catch (_) {
      logger.e('AccountAssetRepository.removeAssetFromAccount failed');
      return const FailureResult(
        Failure(
          code: 'unknown',
          message: 'Unable to remove asset from account',
        ),
      );
    }
  }

  Failure _mapMockFailure(MockAccountAssetException e) {
    final code = switch (e.code) {
      MockAccountAssetErrorCode.network => 'network',
      MockAccountAssetErrorCode.unauthorized => 'unauthorized',
      MockAccountAssetErrorCode.notFound => 'not_found',
      MockAccountAssetErrorCode.validation => 'validation',
      MockAccountAssetErrorCode.unknown => 'unknown',
    };
    return Failure(code: code, message: e.message);
  }
}
