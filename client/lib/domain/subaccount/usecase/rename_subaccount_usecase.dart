import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/domain/subaccount/repository/i_subaccount_repository.dart';

@injectable
class RenameSubaccountUseCase {
  RenameSubaccountUseCase(this._repository);

  final ISubaccountRepository _repository;

  Future<Result<SubaccountEntity>> call({required String subaccountId, required String name}) {
    return _repository.renameSubaccount(subaccountId: subaccountId, name: name);
  }
}
