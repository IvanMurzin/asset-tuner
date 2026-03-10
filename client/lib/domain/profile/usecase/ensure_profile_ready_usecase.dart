import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';

@injectable
class EnsureProfileReadyUseCase {
  EnsureProfileReadyUseCase(this._getProfile, this._updateBaseCurrency);

  final GetProfileUseCase _getProfile;
  final UpdateBaseCurrencyUseCase _updateBaseCurrency;

  Future<Result<ProfileEntity>> call() async {
    final profileResult = await _getProfile();
    switch (profileResult) {
      case FailureResult<ProfileEntity>():
        return profileResult;
      case Success<ProfileEntity>(value: final profile):
        if (profile.baseAssetId != null) {
          return Success(profile);
        }
        return _updateBaseCurrency('USD');
    }
  }
}
