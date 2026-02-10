import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/profile/data_source/profile_mock_data_source.dart';
import 'package:asset_tuner/data/profile/mapper/profile_mapper.dart';
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';

@LazySingleton(as: IProfileRepository)
class ProfileRepository implements IProfileRepository {
  ProfileRepository(this._dataSource);

  final ProfileMockDataSource _dataSource;

  @override
  Future<Result<ProfileBootstrapEntity>> ensureProfile(String userId) async {
    try {
      final existing = await _dataSource.fetchProfile(userId);
      if (existing == null) {
        final created = await _dataSource.upsertProfile(
          ProfileMapper.toDto(
            ProfileEntity(userId: userId, baseCurrency: 'USD', plan: 'free'),
          ),
        );
        final entity = ProfileMapper.toEntity(created);
        logger.i('ProfileRepository.ensureProfile created');
        return Success(
          ProfileBootstrapEntity(
            profile: entity,
            isNew: true,
            wasBaseCurrencyDefaulted: true,
          ),
        );
      }

      final normalized = existing.baseCurrency.trim().isEmpty
          ? existing.copyWith(baseCurrency: 'USD')
          : existing;
      final wasDefaulted = existing.baseCurrency.trim().isEmpty;
      if (wasDefaulted) {
        await _dataSource.upsertProfile(normalized);
        logger.i('ProfileRepository.ensureProfile defaulted base currency');
      }
      final entity = ProfileMapper.toEntity(normalized);
      logger.i('ProfileRepository.ensureProfile existing');
      return Success(
        ProfileBootstrapEntity(
          profile: entity,
          isNew: false,
          wasBaseCurrencyDefaulted: wasDefaulted,
        ),
      );
    } catch (_) {
      logger.e('ProfileRepository.ensureProfile failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to load profile'),
      );
    }
  }

  @override
  Future<Result<ProfileEntity>> getProfile(String userId) async {
    try {
      final profile = await _dataSource.fetchProfile(userId);
      if (profile == null) {
        logger.w('ProfileRepository.getProfile not found');
        return const FailureResult(
          Failure(code: 'not_found', message: 'Profile not found'),
        );
      }
      logger.i('ProfileRepository.getProfile success');
      return Success(ProfileMapper.toEntity(profile));
    } catch (_) {
      logger.e('ProfileRepository.getProfile failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to load profile'),
      );
    }
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(
    String userId,
    String baseCurrency,
  ) async {
    try {
      final existing = await _dataSource.fetchProfile(userId);
      if (existing == null) {
        logger.w('ProfileRepository.updateBaseCurrency not found');
        return const FailureResult(
          Failure(code: 'not_found', message: 'Profile not found'),
        );
      }
      final updated = existing.copyWith(baseCurrency: baseCurrency);
      final stored = await _dataSource.upsertProfile(updated);
      logger.i('ProfileRepository.updateBaseCurrency success');
      return Success(ProfileMapper.toEntity(stored));
    } catch (_) {
      logger.e('ProfileRepository.updateBaseCurrency failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to update profile'),
      );
    }
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String userId, String plan) async {
    try {
      final existing = await _dataSource.fetchProfile(userId);
      if (existing == null) {
        logger.w('ProfileRepository.updatePlan not found');
        return const FailureResult(
          Failure(code: 'not_found', message: 'Profile not found'),
        );
      }
      final updated = existing.copyWith(plan: plan);
      final stored = await _dataSource.upsertProfile(updated);
      logger.i('ProfileRepository.updatePlan success');
      return Success(ProfileMapper.toEntity(stored));
    } catch (_) {
      logger.e('ProfileRepository.updatePlan failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to update profile'),
      );
    }
  }
}
