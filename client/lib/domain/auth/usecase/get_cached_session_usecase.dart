import 'package:injectable/injectable.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';

@injectable
class GetCachedSessionUseCase {
  GetCachedSessionUseCase(this._repository);

  final IAuthRepository _repository;

  Future<AuthSessionEntity?> call() {
    return _repository.getCachedSession();
  }
}
