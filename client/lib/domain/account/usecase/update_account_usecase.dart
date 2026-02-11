import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/repository/i_account_repository.dart';

@injectable
class UpdateAccountUseCase {
  UpdateAccountUseCase(this._repository);

  final IAccountRepository _repository;

  Future<Result<AccountEntity>> call({
    required String accountId,
    required String name,
    required AccountType type,
  }) {
    return _repository.updateAccount(
      accountId: accountId,
      name: name,
      type: type,
    );
  }
}
