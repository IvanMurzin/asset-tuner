import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/subaccount/repository/i_subaccount_repository.dart';

@injectable
class DeleteSubaccountUseCase {
  DeleteSubaccountUseCase(this._repository);

  final ISubaccountRepository _repository;

  Future<Result<void>> call({required String subaccountId}) {
    return _repository.deleteSubaccount(subaccountId: subaccountId);
  }
}
