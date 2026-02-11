import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/profile/data_source/supabase_profile_data_source.dart';
import 'package:asset_tuner/data/profile/mapper/profile_mapper.dart';
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';

@LazySingleton(as: IProfileRepository)
class ProfileRepository implements IProfileRepository {
  ProfileRepository(this._dataSource);

  final SupabaseProfileDataSource _dataSource;

  @override
  Future<Result<ProfileBootstrapEntity>> ensureProfile() async {
    try {
      final dto = await _dataSource.bootstrapProfile();
      final entity = ProfileMapper.toEntity(dto.profile);
      logger.i('ProfileRepository.ensureProfile success');
      return Success(
        ProfileBootstrapEntity(
          profile: entity,
          isNew: dto.isNew,
          wasBaseCurrencyDefaulted: dto.wasBaseCurrencyDefaulted,
        ),
      );
    } catch (error) {
      logger.e('ProfileRepository.ensureProfile failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to load profile',
        ),
      );
    }
  }

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    try {
      final dto = await _dataSource.fetchProfile();
      if (dto == null) {
        logger.w('ProfileRepository.getProfile not found');
        return const FailureResult(
          Failure(code: 'not_found', message: 'Profile not found'),
        );
      }
      logger.i('ProfileRepository.getProfile success');
      return Success(ProfileMapper.toEntity(dto));
    } catch (error) {
      logger.e('ProfileRepository.getProfile failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to load profile',
        ),
      );
    }
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(
    String baseCurrency,
  ) async {
    try {
      final dto = await _dataSource.updateBaseCurrency(baseCurrency);
      logger.i('ProfileRepository.updateBaseCurrency success');
      return Success(ProfileMapper.toEntity(dto));
    } catch (error) {
      logger.e('ProfileRepository.updateBaseCurrency failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to update profile',
        ),
      );
    }
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String plan) async {
    try {
      final dto = await _dataSource.updatePlan(plan);
      logger.i('ProfileRepository.updatePlan success');
      return Success(ProfileMapper.toEntity(dto));
    } catch (error) {
      logger.e('ProfileRepository.updatePlan failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to update profile',
        ),
      );
    }
  }
}
