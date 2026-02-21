import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/domain/subaccount/repository/i_subaccount_repository.dart';

@injectable
class CreateSubaccountUseCase {
  CreateSubaccountUseCase(this._repository);

  final ISubaccountRepository _repository;

  Future<Result<SubaccountEntity>> call({
    required String accountId,
    required String name,
    required AssetEntity asset,
    required Decimal snapshotAmount,
    required DateTime entryDate,
  }) {
    return _repository.createSubaccount(
      accountId: accountId,
      name: name,
      asset: asset,
      snapshotAmount: snapshotAmount,
      entryDate: entryDate,
    );
  }
}
