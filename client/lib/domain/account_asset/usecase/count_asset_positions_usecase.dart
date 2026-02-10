import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account_asset/repository/i_account_asset_repository.dart';

@injectable
class CountAssetPositionsUseCase {
  CountAssetPositionsUseCase(this._repository);

  final IAccountAssetRepository _repository;

  Future<Result<int>> call(String userId) {
    return _repository.countAssetPositions(userId);
  }
}
