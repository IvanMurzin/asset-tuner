import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/get_auth_providers_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/oauth_sign_in_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_in_with_password_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/presentation/auth/bloc/sign_in_cubit.dart';
import 'test_fixtures.dart';

class FakeAuthRepository implements IAuthRepository {
  FakeAuthRepository({
    this.restoreResult,
    this.cachedSession,
    this.signInResult,
    this.oauthResult,
    this.availableProviders,
  });

  final Result<AuthSessionEntity?>? restoreResult;
  final AuthSessionEntity? cachedSession;
  final Result<void>? signInResult;
  final Result<AuthSessionEntity>? oauthResult;
  final List<AuthProvider>? availableProviders;

  @override
  Future<Result<AuthSessionEntity?>> restoreSession() async {
    return restoreResult ?? const Success(null);
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
  Future<Result<void>> signInWithPassword(String email, String password) async {
    return signInResult ?? const Success(null);
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
  Future<Result<AuthSessionEntity>> signInWithOAuth(AuthProvider provider) async {
    return oauthResult ?? const Success(AuthSessionEntity(userId: 'user_1', email: 'user@x.com'));
  }

  @override
  Future<List<AuthProvider>> getAvailableProviders() async {
    return availableProviders ?? const [AuthProvider.google, AuthProvider.apple];
  }

  @override
  Future<Result<void>> signOut() async {
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    return const Success(null);
  }
}

class FakeProfileRepository implements IProfileRepository {
  FakeProfileRepository({this.ensureResult});

  final Result<ProfileBootstrapEntity>? ensureResult;

  @override
  Future<Result<ProfileBootstrapEntity>> ensureProfile() async {
    return ensureResult ??
        Success(
          ProfileBootstrapEntity(
            profile: freeProfile(),
            isNew: true,
            wasBaseCurrencyDefaulted: true,
          ),
        );
  }

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(String baseCurrency) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String plan) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }
}

void main() {
  test('invalid email sets email error', () async {
    final authRepo = FakeAuthRepository();
    final profileRepo = FakeProfileRepository();

    final cubit = SignInCubit(
      SignInWithPasswordUseCase(authRepo),
      OAuthSignInUseCase(authRepo),
      BootstrapProfileUseCase(profileRepo),
      GetAuthProvidersUseCase(authRepo),
      GetCachedSessionUseCase(authRepo),
    );

    cubit.updateEmail('invalid');
    cubit.updatePassword('abc123');
    await cubit.signIn();

    expect(cubit.state.emailError, SignInFieldError.invalidEmail);
  });

  test('weak password sets password error', () async {
    final authRepo = FakeAuthRepository();
    final profileRepo = FakeProfileRepository();

    final cubit = SignInCubit(
      SignInWithPasswordUseCase(authRepo),
      OAuthSignInUseCase(authRepo),
      BootstrapProfileUseCase(profileRepo),
      GetAuthProvidersUseCase(authRepo),
      GetCachedSessionUseCase(authRepo),
    );

    cubit.updateEmail('user@example.com');
    cubit.updatePassword('abc');
    await cubit.signIn();

    expect(cubit.state.passwordError, SignInFieldError.weakPassword);
  });

  test('signIn failure sets banner failure code', () async {
    final authRepo = FakeAuthRepository(
      signInResult: const FailureResult(
        Failure(code: 'rate_limited', message: 'Too many attempts'),
      ),
    );
    final profileRepo = FakeProfileRepository();

    final cubit = SignInCubit(
      SignInWithPasswordUseCase(authRepo),
      OAuthSignInUseCase(authRepo),
      BootstrapProfileUseCase(profileRepo),
      GetAuthProvidersUseCase(authRepo),
      GetCachedSessionUseCase(authRepo),
    );

    cubit.updateEmail('user@example.com');
    cubit.updatePassword('abc123');
    await cubit.signIn();

    expect(cubit.state.bannerFailureCode, 'rate_limited');
  });

  test('signIn success routes to onboarding when defaulted', () async {
    final authRepo = FakeAuthRepository(
      cachedSession: const AuthSessionEntity(userId: 'user_1', email: 'user@example.com'),
    );
    final profileRepo = FakeProfileRepository(
      ensureResult: Success(
        ProfileBootstrapEntity(profile: freeProfile(), isNew: true, wasBaseCurrencyDefaulted: true),
      ),
    );

    final cubit = SignInCubit(
      SignInWithPasswordUseCase(authRepo),
      OAuthSignInUseCase(authRepo),
      BootstrapProfileUseCase(profileRepo),
      GetAuthProvidersUseCase(authRepo),
      GetCachedSessionUseCase(authRepo),
    );

    cubit.updateEmail('user@example.com');
    cubit.updatePassword('abc123');
    await cubit.signIn();

    expect(cubit.state.navigation, isNotNull);
    expect(cubit.state.navigation?.destination, SignInDestination.onboardingBaseCurrency);
  });
}
