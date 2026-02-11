import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account_asset/repository/i_account_asset_repository.dart';

@injectable
class RemoveAssetFromAccountUseCase {
  RemoveAssetFromAccountUseCase(this._repository);

  final IAccountAssetRepository _repository;

  Future<Result<void>> call({
    required String accountId,
    required String assetId,
  }) {
    return _repository.removeAssetFromAccount(
      accountId: accountId,
      assetId: assetId,
    );
  }
}
