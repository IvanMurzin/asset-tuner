import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';

@injectable
class UpdateBaseCurrencyUseCase {
  UpdateBaseCurrencyUseCase(this._repository);

  final IProfileRepository _repository;

  Future<Result<ProfileEntity>> call(String baseCurrency) {
    return _repository.updateBaseCurrency(baseCurrency);
  }
}
