import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';

@injectable
class VerifySignUpOtpUseCase {
  VerifySignUpOtpUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<AuthSessionEntity>> call(String email, String code) {
    return _repository.verifySignUpOtp(email, code);
  }
}
