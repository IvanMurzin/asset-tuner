import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_picker_item_entity.dart';
import 'package:asset_tuner/domain/asset/repository/i_asset_repository.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_for_subaccount_picker_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';
import 'package:asset_tuner/presentation/onboarding/bloc/base_currency_cubit.dart';
import 'test_fixtures.dart';

class FakeAuthRepository implements IAuthRepository {
  FakeAuthRepository({this.cachedSession});

  final AuthSessionEntity? cachedSession;

  @override
  Future<Result<AuthSessionEntity?>> restoreSession() async {
    return Success(cachedSession);
  }

  @override
  Future<AuthSessionEntity?> getCachedSession() async {
    return cachedSession;
  }

  @override
  Future<Result<void>> requestEmailOtp(String email) async {
    return const Success(null);
  }

  @override
  Future<Result<AuthSessionEntity>> confirmEmailOtp(String email) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<AuthSessionEntity>> signInWithOAuth(provider) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<void>> signInWithPassword(String email, String password) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<OtpVerificationEntity>> signUpWithPassword(
    String email,
    String password,
  ) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<AuthSessionEntity>> verifySignUpOtp(
    String email,
    String code,
  ) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<void>> signOut() async {
    return const Success(null);
  }

  @override
  Future<List<AuthProvider>> getAvailableProviders() async {
    return const [AuthProvider.google, AuthProvider.apple];
  }

  @override
  Future<Result<void>> deleteAccount() async {
    return const Success(null);
  }
}

class FakeProfileRepository implements IProfileRepository {
  FakeProfileRepository({this.profileResult, this.updateResult});

  final Result<ProfileEntity>? profileResult;
  final Result<ProfileEntity>? updateResult;

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    return profileResult ?? Success(freeProfile());
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(String baseCurrency) async {
    return updateResult ?? Success(freeProfile(baseCurrency: baseCurrency));
  }

  @override
  Future<Result<ProfileBootstrapEntity>> ensureProfile() async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String plan) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }
}

List<AssetPickerItemEntity> _fiatPickerItems() => [
      const AssetPickerItemEntity(
        id: 'a1',
        kind: AssetKind.fiat,
        code: 'USD',
        name: 'United States Dollar',
        rank: 1,
        isUnlocked: true,
      ),
      const AssetPickerItemEntity(
        id: 'a2',
        kind: AssetKind.fiat,
        code: 'EUR',
        name: 'Euro',
        rank: 2,
        isUnlocked: true,
      ),
      const AssetPickerItemEntity(
        id: 'a3',
        kind: AssetKind.fiat,
        code: 'GBP',
        name: 'British Pound',
        rank: 3,
        isUnlocked: true,
      ),
      const AssetPickerItemEntity(
        id: 'a4',
        kind: AssetKind.fiat,
        code: 'JPY',
        name: 'Japanese Yen',
        rank: 4,
        isUnlocked: true,
      ),
      const AssetPickerItemEntity(
        id: 'a5',
        kind: AssetKind.fiat,
        code: 'CNY',
        name: 'Chinese Yuan',
        rank: 5,
        isUnlocked: true,
      ),
      const AssetPickerItemEntity(
        id: 'a6',
        kind: AssetKind.fiat,
        code: 'AUD',
        name: 'Australian Dollar',
        rank: 6,
        isUnlocked: false,
      ),
    ];

class FakeAssetRepository implements IAssetRepository {
  FakeAssetRepository({this.pickerResult});

  final Result<List<AssetPickerItemEntity>>? pickerResult;

  @override
  Future<Result<List<AssetEntity>>> fetchAssets() async {
    return const Success([]);
  }

  @override
  Future<Result<List<AssetPickerItemEntity>>> fetchAssetsForPicker({
    required AssetKind kind,
  }) async {
    return pickerResult ?? Success(_fiatPickerItems());
  }
}

void main() {
  test('load navigates to sign-in when session missing', () async {
    final cubit = BaseCurrencyCubit(
      GetCachedSessionUseCase(FakeAuthRepository()),
      GetAssetsForSubaccountPickerUseCase(FakeAssetRepository()),
      GetProfileUseCase(FakeProfileRepository()),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(cubit.state.navigation?.destination, BaseCurrencyDestination.signIn);
  });

  test(
    'continueNext routes to paywall when currency outside free top-5',
    () async {
      final cubit = BaseCurrencyCubit(
        GetCachedSessionUseCase(
          FakeAuthRepository(
            cachedSession: const AuthSessionEntity(
              userId: 'user_1',
              email: 'user@example.com',
            ),
          ),
        ),
        GetAssetsForSubaccountPickerUseCase(FakeAssetRepository()),
        GetProfileUseCase(
          FakeProfileRepository(
            profileResult: const Success(
              ProfileEntity(
                baseCurrency: 'USD',
                plan: 'free',
                entitlements: freeEntitlements,
              ),
            ),
          ),
        ),
        UpdateBaseCurrencyUseCase(FakeProfileRepository()),
      );

      await Future<void>.delayed(const Duration(milliseconds: 1));

      cubit.selectCurrency('AUD');
      await cubit.continueNext();

      expect(
        cubit.state.navigation?.destination,
        BaseCurrencyDestination.paywall,
      );
    },
  );

  test('continueNext saves when currency allowed', () async {
    final cubit = BaseCurrencyCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      GetAssetsForSubaccountPickerUseCase(FakeAssetRepository()),
      GetProfileUseCase(FakeProfileRepository()),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1));

    cubit.selectCurrency('USD');
    await cubit.continueNext();

    expect(cubit.state.navigation?.destination, BaseCurrencyDestination.main);
  });
}
