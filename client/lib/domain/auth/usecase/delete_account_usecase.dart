import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';

@injectable
class DeleteAccountUseCase {
  DeleteAccountUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<void>> call(String userId) {
    return _repository.deleteAccount(userId);
  }
}
