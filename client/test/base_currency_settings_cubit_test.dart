import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/currency/entity/currency_entity.dart';
import 'package:asset_tuner/domain/currency/repository/i_currency_repository.dart';
import 'package:asset_tuner/domain/currency/usecase/get_fiat_currencies_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';
import 'package:asset_tuner/presentation/settings/bloc/base_currency_settings_cubit.dart';

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
  Future<Result<void>> deleteAccount(String userId) async {
    return const Success(null);
  }
}

class FakeProfileRepository implements IProfileRepository {
  FakeProfileRepository({this.ensureResult, this.updateResult});

  final Result<ProfileBootstrapEntity>? ensureResult;
  final Result<ProfileEntity>? updateResult;

  @override
  Future<Result<ProfileBootstrapEntity>> ensureProfile(String userId) async {
    return ensureResult ??
        Success(
          ProfileBootstrapEntity(
            profile: ProfileEntity(
              userId: userId,
              baseCurrency: 'USD',
              plan: 'free',
            ),
            isNew: false,
            wasBaseCurrencyDefaulted: false,
          ),
        );
  }

  @override
  Future<Result<ProfileEntity>> getProfile(String userId) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(
    String userId,
    String baseCurrency,
  ) async {
    return updateResult ??
        Success(
          ProfileEntity(
            userId: userId,
            baseCurrency: baseCurrency,
            plan: 'free',
          ),
        );
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String userId, String plan) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }
}

class FakeCurrencyRepository implements ICurrencyRepository {
  FakeCurrencyRepository({this.currencyResult});

  final Result<List<CurrencyEntity>>? currencyResult;

  @override
  Future<Result<List<CurrencyEntity>>> fetchFiatCurrencies() async {
    return currencyResult ??
        const Success([
          CurrencyEntity(
            code: 'USD',
            name: 'United States Dollar',
            symbol: 'USD',
          ),
          CurrencyEntity(code: 'EUR', name: 'Euro', symbol: 'EUR'),
          CurrencyEntity(code: 'GBP', name: 'British Pound', symbol: 'GBP'),
        ]);
  }
}

void main() {
  test('load navigates to sign-in when session missing', () async {
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(FakeAuthRepository()),
      BootstrapProfileUseCase(FakeProfileRepository()),
      GetFiatCurrenciesUseCase(FakeCurrencyRepository()),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(
      cubit.state.navigation?.destination,
      BaseCurrencySettingsDestination.signIn,
    );
  });

  test('load treats empty catalog as error', () async {
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      BootstrapProfileUseCase(FakeProfileRepository()),
      GetFiatCurrenciesUseCase(
        FakeCurrencyRepository(currencyResult: const Success([])),
      ),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, BaseCurrencySettingsStatus.error);
    expect(cubit.state.loadFailureCode, 'unknown');
  });

  test('free plan selection of blocked code routes to paywall', () async {
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      BootstrapProfileUseCase(
        FakeProfileRepository(
          ensureResult: Success(
            ProfileBootstrapEntity(
              profile: const ProfileEntity(
                userId: 'user_1',
                baseCurrency: 'USD',
                plan: 'free',
              ),
              isNew: false,
              wasBaseCurrencyDefaulted: false,
            ),
          ),
        ),
      ),
      GetFiatCurrenciesUseCase(FakeCurrencyRepository()),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );
    addTearDown(cubit.close);

    await cubit.load();

    cubit.selectCurrency('GBP');

    expect(
      cubit.state.navigation?.destination,
      BaseCurrencySettingsDestination.paywall,
    );
    expect(cubit.state.navigation?.requestedCode, 'GBP');
    expect(cubit.state.selectedCode, 'USD');
  });

  test('paid plan can select any code without paywall', () async {
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      BootstrapProfileUseCase(
        FakeProfileRepository(
          ensureResult: Success(
            ProfileBootstrapEntity(
              profile: const ProfileEntity(
                userId: 'user_1',
                baseCurrency: 'USD',
                plan: 'paid',
              ),
              isNew: false,
              wasBaseCurrencyDefaulted: false,
            ),
          ),
        ),
      ),
      GetFiatCurrenciesUseCase(FakeCurrencyRepository()),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );
    addTearDown(cubit.close);

    await cubit.load();

    cubit.selectCurrency('GBP');

    expect(cubit.state.navigation, isNull);
    expect(cubit.state.selectedCode, 'GBP');
  });

  test('save with unchanged selection navigates back', () async {
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      BootstrapProfileUseCase(FakeProfileRepository()),
      GetFiatCurrenciesUseCase(FakeCurrencyRepository()),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );
    addTearDown(cubit.close);

    await cubit.load();
    await cubit.save();

    expect(
      cubit.state.navigation?.destination,
      BaseCurrencySettingsDestination.back,
    );
  });

  test('save persists allowed selection and navigates back', () async {
    final profileRepo = FakeProfileRepository();
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      BootstrapProfileUseCase(profileRepo),
      GetFiatCurrenciesUseCase(FakeCurrencyRepository()),
      UpdateBaseCurrencyUseCase(profileRepo),
    );
    addTearDown(cubit.close);

    await cubit.load();
    cubit.selectCurrency('EUR');
    await cubit.save();

    expect(cubit.state.currentCode, 'EUR');
    expect(cubit.state.selectedCode, 'EUR');
    expect(
      cubit.state.navigation?.destination,
      BaseCurrencySettingsDestination.back,
    );
  });

  test('save shows banner when update fails', () async {
    final profileRepo = FakeProfileRepository(
      updateResult: const FailureResult(
        Failure(code: 'network', message: 'No connection'),
      ),
    );
    final cubit = BaseCurrencySettingsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      BootstrapProfileUseCase(profileRepo),
      GetFiatCurrenciesUseCase(FakeCurrencyRepository()),
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
