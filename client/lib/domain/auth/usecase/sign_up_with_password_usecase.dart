import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/sign_up_result_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';

@injectable
class SignUpWithPasswordUseCase {
  SignUpWithPasswordUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<SignUpResultEntity>> call(String email, String password) {
    return _repository.signUpWithPassword(email, password);
  }
}
