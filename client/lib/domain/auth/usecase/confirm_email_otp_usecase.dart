import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';

@injectable
class ConfirmEmailOtpUseCase {
  ConfirmEmailOtpUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<AuthSessionEntity>> call(String email) {
    return _repository.confirmEmailOtp(email);
  }
}
