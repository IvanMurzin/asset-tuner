import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/repository/i_account_repository.dart';

@injectable
class DeleteAccountUseCase {
  DeleteAccountUseCase(this._repository);

  final IAccountRepository _repository;

  Future<Result<void>> call({required String accountId}) {
    return _repository.deleteAccount(accountId: accountId);
  }
}
