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
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';
import 'package:asset_tuner/presentation/settings/bloc/base_currency_settings_cubit.dart';
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
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<AuthSessionEntity>> signInWithOAuth(provider) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<void>> signInWithPassword(String email, String password) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<OtpVerificationEntity>> signUpWithPassword(String email, String password) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<AuthSessionEntity>> verifySignUpOtp(String email, String code) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
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
  FakeProfileRepository({this.ensureResult, this.updateResult});

  final Result<ProfileBootstrapEntity>? ensureResult;
  final Result<ProfileEntity>? updateResult;

  @override
  Future<Result<ProfileBootstrapEntity>> ensureProfile() async {
    return ensureResult ??
        Success(
          ProfileBootstrapEntity(
            profile: freeProfile(),
          ),
        );
  }

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(String baseCurrency) async {
    return updateResult ?? Success(freeProfile(baseCurrency: baseCurrency));
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String plan) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }
}

List<AssetPickerItemEntity> _fiatPickerItems() => [
  const AssetPickerItemEntity(
    id: 'a1',
    kind: AssetKind.fiat,
    code: 'USD',
    name: 'United States Dollar',
    rank: 1,
    isLocked: false,
  ),
  const AssetPickerItemEntity(
    id: 'a2',
    kind: AssetKind.fiat,
    code: 'EUR',
    name: 'Euro',
    rank: 2,
    isLocked: false,
  ),
  const AssetPickerItemEntity(
    id: 'a3',
    kind: AssetKind.fiat,
    code: 'GBP',
    name: 'British Pound',
    rank: 3,
    isLocked: false,
  ),
  const AssetPickerItemEntity(
    id: 'a4',
    kind: AssetKind.fiat,
    code: 'JPY',
    name: 'Japanese Yen',
    rank: 4,
    isLocked: false,
  ),
  const AssetPickerItemEntity(
    id: 'a5',
    kind: AssetKind.fiat,
    code: 'CNY',
    name: 'Chinese Yuan',
    rank: 5,
    isLocked: false,
  ),
  const AssetPickerItemEntity(
    id: 'a6',
    kind: AssetKind.fiat,
    code: 'AUD',
    name: 'Australian Dollar',
    rank: 6,
    isLocked: true,
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
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(FakeAuthRepository()),
      BootstrapProfileUseCase(FakeProfileRepository()),
      GetAssetsForSubaccountPickerUseCase(FakeAssetRepository()),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.navigation?.destination, BaseCurrencySettingsDestination.signIn);
  });

  test('load treats empty catalog as error', () async {
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(userId: 'user_1', email: 'user@example.com'),
        ),
      ),
      BootstrapProfileUseCase(FakeProfileRepository()),
      GetAssetsForSubaccountPickerUseCase(FakeAssetRepository(pickerResult: const Success([]))),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, BaseCurrencySettingsStatus.error);
    expect(cubit.state.loadFailureCode, 'unknown');
  });

  test('free plan selection of code outside top-5 routes to paywall', () async {
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(userId: 'user_1', email: 'user@example.com'),
        ),
      ),
      BootstrapProfileUseCase(
        FakeProfileRepository(
          ensureResult: Success(
            ProfileBootstrapEntity(
              profile: freeProfile(),
            ),
          ),
        ),
      ),
      GetAssetsForSubaccountPickerUseCase(FakeAssetRepository()),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );
    addTearDown(cubit.close);

    await cubit.load();

    cubit.selectCurrency('AUD');

    expect(cubit.state.navigation?.destination, BaseCurrencySettingsDestination.paywall);
    expect(cubit.state.navigation?.requestedCode, 'AUD');
    expect(cubit.state.selectedCode, 'USD');
  });

  test('paid plan can select any code without paywall', () async {
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(userId: 'user_1', email: 'user@example.com'),
        ),
      ),
      BootstrapProfileUseCase(
        FakeProfileRepository(
          ensureResult: Success(
            ProfileBootstrapEntity(
              profile: paidProfile(),
            ),
          ),
        ),
      ),
      GetAssetsForSubaccountPickerUseCase(FakeAssetRepository()),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );
    addTearDown(cubit.close);

    await cubit.load();

    cubit.selectCurrency('AUD');

    expect(cubit.state.navigation, isNull);
    expect(cubit.state.selectedCode, 'AUD');
  });

  test('save with unchanged selection navigates back', () async {
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(userId: 'user_1', email: 'user@example.com'),
        ),
      ),
      BootstrapProfileUseCase(FakeProfileRepository()),
      GetAssetsForSubaccountPickerUseCase(FakeAssetRepository()),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );
    addTearDown(cubit.close);

    await cubit.load();
    await cubit.save();

    expect(cubit.state.navigation?.destination, BaseCurrencySettingsDestination.back);
  });

  test('save persists allowed selection and navigates back', () async {
    final profileRepo = FakeProfileRepository();
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(userId: 'user_1', email: 'user@example.com'),
        ),
      ),
      BootstrapProfileUseCase(profileRepo),
      GetAssetsForSubaccountPickerUseCase(FakeAssetRepository()),
      UpdateBaseCurrencyUseCase(profileRepo),
    );
    addTearDown(cubit.close);

    await cubit.load();
    cubit.selectCurrency('EUR');
    await cubit.save();

    expect(cubit.state.currentCode, 'EUR');
    expect(cubit.state.selectedCode, 'EUR');
    expect(cubit.state.navigation?.destination, BaseCurrencySettingsDestination.back);
  });

  test('save shows banner when update fails', () async {
    final profileRepo = FakeProfileRepository(
      updateResult: const FailureResult(Failure(code: 'network', message: 'No connection')),
    );
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(userId: 'user_1', email: 'user@example.com'),
        ),
      ),
      BootstrapProfileUseCase(profileRepo),
      GetAssetsForSubaccountPickerUseCase(FakeAssetRepository()),
      UpdateBaseCurrencyUseCase(profileRepo),
    );
    addTearDown(cubit.close);

    await cubit.load();
    cubit.selectCurrency('EUR');
    await cubit.save();

    expect(cubit.state.bannerType, BaseCurrencySettingsBannerType.saveFailure);
    expect(cubit.state.bannerFailureCode, 'network');
  });
}
