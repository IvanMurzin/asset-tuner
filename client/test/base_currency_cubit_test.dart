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
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';
import 'package:asset_tuner/presentation/onboarding/bloc/base_currency_cubit.dart';

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
}

class FakeProfileRepository implements IProfileRepository {
  FakeProfileRepository({this.profileResult, this.updateResult});

  final Result<ProfileEntity>? profileResult;
  final Result<ProfileEntity>? updateResult;

  @override
  Future<Result<ProfileEntity>> getProfile(String userId) async {
    return profileResult ??
        const Success(ProfileEntity(userId: 'user_1', baseCurrency: 'USD', plan: 'free'));
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(String userId, String baseCurrency) async {
    return updateResult ??
        Success(ProfileEntity(userId: userId, baseCurrency: baseCurrency, plan: 'free'));
  }

  @override
  Future<Result<ProfileBootstrapEntity>> ensureProfile(String userId) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }
}

class FakeCurrencyRepository implements ICurrencyRepository {
  FakeCurrencyRepository({this.currencyResult});

  final Result<List<CurrencyEntity>>? currencyResult;

  @override
  Future<Result<List<CurrencyEntity>>> fetchFiatCurrencies() async {
    return currencyResult ??
        const Success([
          CurrencyEntity(code: 'USD', name: 'United States Dollar', symbol: '\$'),
          CurrencyEntity(code: 'GBP', name: 'British Pound', symbol: 'GBP'),
        ]);
  }
}

void main() {
  test('load navigates to sign-in when session missing', () async {
    final cubit = BaseCurrencyCubit(
      GetCachedSessionUseCase(FakeAuthRepository()),
      GetFiatCurrenciesUseCase(FakeCurrencyRepository()),
      GetProfileUseCase(FakeProfileRepository()),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(cubit.state.navigation?.destination, BaseCurrencyDestination.signIn);
  });

  test('continueNext routes to paywall when currency blocked', () async {
    final cubit = BaseCurrencyCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(userId: 'user_1', email: 'user@example.com'),
        ),
      ),
      GetFiatCurrenciesUseCase(FakeCurrencyRepository()),
      GetProfileUseCase(
        FakeProfileRepository(
          profileResult: const Success(
            ProfileEntity(userId: 'user_1', baseCurrency: 'USD', plan: 'free'),
          ),
        ),
      ),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1));

    cubit.selectCurrency('GBP');
    await cubit.continueNext();

    expect(cubit.state.navigation?.destination, BaseCurrencyDestination.paywall);
  });

  test('continueNext saves when currency allowed', () async {
    final cubit = BaseCurrencyCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(userId: 'user_1', email: 'user@example.com'),
        ),
      ),
      GetFiatCurrenciesUseCase(FakeCurrencyRepository()),
      GetProfileUseCase(FakeProfileRepository()),
      UpdateBaseCurrencyUseCase(FakeProfileRepository()),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1));

    cubit.selectCurrency('USD');
    await cubit.continueNext();

    expect(cubit.state.navigation?.destination, BaseCurrencyDestination.overview);
  });
}
