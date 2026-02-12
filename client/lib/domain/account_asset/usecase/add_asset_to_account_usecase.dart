import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/repository/i_account_asset_repository.dart';

@injectable
class AddAssetToAccountUseCase {
  AddAssetToAccountUseCase(this._repository);

  final IAccountAssetRepository _repository;

  Future<Result<AccountAssetEntity>> call({
    required String accountId,
    required String name,
    required String assetId,
    required Decimal snapshotAmount,
    required DateTime entryDate,
  }) {
    return _repository.addAssetToAccount(
      accountId: accountId,
      name: name,
      assetId: assetId,
      snapshotAmount: snapshotAmount,
      entryDate: entryDate,
    );
  }
}
