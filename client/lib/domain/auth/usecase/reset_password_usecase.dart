import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';

@injectable
class ResetPasswordUseCase {
  ResetPasswordUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<void>> call({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _repository.resetPassword(email: email, code: code, newPassword: newPassword);
  }
}
