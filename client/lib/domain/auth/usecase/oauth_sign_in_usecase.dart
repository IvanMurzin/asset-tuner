import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';

@injectable
class OAuthSignInUseCase {
  OAuthSignInUseCase(this._repository);

  final IAuthRepository _repository;

  Future<Result<AuthSessionEntity>> call(AuthProvider provider) {
    return _repository.signInWithOAuth(provider);
  }
}
