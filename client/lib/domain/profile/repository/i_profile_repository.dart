import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';

abstract interface class IProfileRepository {
  Future<Result<ProfileBootstrapEntity>> ensureProfile(String userId);
  Future<Result<ProfileEntity>> getProfile(String userId);
  Future<Result<ProfileEntity>> updateBaseCurrency(String userId, String baseCurrency);
}
