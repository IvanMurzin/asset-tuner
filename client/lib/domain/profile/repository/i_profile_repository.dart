import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';

abstract interface class IProfileRepository {
  Future<Result<ProfileEntity>> getProfile();
  Future<Result<ProfileEntity>> updateBaseCurrency(String baseCurrency);
  Future<Result<ProfileEntity>> updatePlan(String plan);
  Future<Result<void>> sendContactDeveloperMessage({
    required String name,
    required String email,
    required String description,
  });
}
