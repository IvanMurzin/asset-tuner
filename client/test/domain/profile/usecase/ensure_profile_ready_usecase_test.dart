import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/profile/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/ensure_profile_ready_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnsureProfileReadyUseCase', () {
    late _FakeProfileRepository repository;
    late EnsureProfileReadyUseCase useCase;

    setUp(() {
      repository = _FakeProfileRepository();
      useCase = EnsureProfileReadyUseCase(
        GetProfileUseCase(repository),
        UpdateBaseCurrencyUseCase(repository),
      );
    });

    test('returns existing profile when base asset is already set', () async {
      final profile = _profile(baseAssetId: 'base-asset-id');
      repository.getProfileResult = Success(profile);

      final result = await useCase();

      expect(result, isA<Success<ProfileEntity>>());
      expect((result as Success<ProfileEntity>).value, profile);
      expect(repository.updatedBaseCurrency, isNull);
    });

    test(
      'defaults base currency to USD when profile has no base asset',
      () async {
        final incomplete = _profile(baseAssetId: null);
        final fixed = _profile(baseAssetId: 'usd-asset-id');
        repository.getProfileResult = Success(incomplete);
        repository.updateBaseCurrencyResult = Success(fixed);

        final result = await useCase();

        expect(repository.updatedBaseCurrency, 'USD');
        expect(result, isA<Success<ProfileEntity>>());
        expect((result as Success<ProfileEntity>).value, fixed);
      },
    );

    test('propagates get profile failure', () async {
      repository.getProfileResult = const FailureResult(
        Failure(code: 'load_failed', message: 'load failed'),
      );

      final result = await useCase();

      expect(result, isA<FailureResult<ProfileEntity>>());
      expect(repository.updatedBaseCurrency, isNull);
    });

    test('propagates update base currency failure', () async {
      repository.getProfileResult = Success(_profile(baseAssetId: null));
      repository.updateBaseCurrencyResult = const FailureResult(
        Failure(code: 'update_failed', message: 'update failed'),
      );

      final result = await useCase();

      expect(result, isA<FailureResult<ProfileEntity>>());
      expect(repository.updatedBaseCurrency, 'USD');
    });
  });
}

class _FakeProfileRepository implements IProfileRepository {
  Result<ProfileEntity> getProfileResult = Success(
    _profile(baseAssetId: 'base-asset-id'),
  );
  Result<ProfileEntity> updateBaseCurrencyResult = Success(
    _profile(baseAssetId: 'base-asset-id'),
  );
  String? updatedBaseCurrency;

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    return getProfileResult;
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(String baseCurrency) async {
    updatedBaseCurrency = baseCurrency;
    return updateBaseCurrencyResult;
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String plan) {
    throw UnimplementedError();
  }
}

ProfileEntity _profile({required String? baseAssetId, String plan = 'free'}) {
  return ProfileEntity(
    userId: 'user-id',
    baseAssetId: baseAssetId,
    plan: plan,
    entitlements: const EntitlementsEntity(),
  );
}
