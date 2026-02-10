import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';

@injectable
class SignOutUseCase {
  SignOutUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<void>> call() {
    return _repository.signOut();
  }
}
