import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/repository/i_account_repository.dart';

@injectable
class CreateAccountUseCase {
  CreateAccountUseCase(this._repository);

  final IAccountRepository _repository;

  Future<Result<AccountEntity>> call({
    required String name,
    required AccountType type,
  }) {
    return _repository.createAccount(name: name, type: type);
  }
}
