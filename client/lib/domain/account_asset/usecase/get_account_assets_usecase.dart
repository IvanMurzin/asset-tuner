import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/repository/i_account_asset_repository.dart';

@injectable
class GetAccountAssetsUseCase {
  GetAccountAssetsUseCase(this._repository);

  final IAccountAssetRepository _repository;

  Future<Result<List<AccountAssetEntity>>> call({required String accountId}) {
    return _repository.fetchAccountAssets(accountId: accountId);
  }
}
