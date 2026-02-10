import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/repository/i_account_repository.dart';

@injectable
class GetAccountsUseCase {
  GetAccountsUseCase(this._repository);

  final IAccountRepository _repository;

  Future<Result<List<AccountEntity>>> call(String userId) {
    return _repository.fetchAccounts(userId);
  }
}
