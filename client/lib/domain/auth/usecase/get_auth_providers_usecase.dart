import 'package:injectable/injectable.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';

@injectable
class GetAuthProvidersUseCase {
  GetAuthProvidersUseCase(this._repository);

  final IAuthRepository _repository;

  Future<List<AuthProvider>> call() {
    return _repository.getAvailableProviders();
  }
}
