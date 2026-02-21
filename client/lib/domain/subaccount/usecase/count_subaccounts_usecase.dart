import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/subaccount/repository/i_subaccount_repository.dart';

@injectable
class CountSubaccountsUseCase {
  CountSubaccountsUseCase(this._repository);

  final ISubaccountRepository _repository;

  Future<Result<int>> call() {
    return _repository.countSubaccounts();
  }
}
