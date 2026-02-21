import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/domain/subaccount/repository/i_subaccount_repository.dart';

@injectable
class GetSubaccountsUseCase {
  GetSubaccountsUseCase(this._repository);

  final ISubaccountRepository _repository;

  Future<Result<List<SubaccountEntity>>> call({required String accountId}) {
    return _repository.fetchSubaccounts(accountId: accountId);
  }
}
