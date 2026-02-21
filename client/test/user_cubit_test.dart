import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_out_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_plan_usecase.dart';
import 'package:asset_tuner/presentation/user/bloc/user_cubit.dart';
import 'test_fixtures.dart';

void main() {
  test('bootstrap sets unauthenticated when session is missing', () async {
    final authRepository = _FakeAuthRepository();
    final profileRepository = _FakeProfileRepository(freeProfile());
    final cubit = UserCubit(
      GetCachedSessionUseCase(authRepository),
      BootstrapProfileUseCase(profileRepository),
      UpdateBaseCurrencyUseCase(profileRepository),
      UpdatePlanUseCase(profileRepository),
      DeleteAccountUseCase(authRepository),
      SignOutUseCase(authRepository),
    );

    await cubit.bootstrap();

    expect(cubit.state.status, UserStatus.unauthenticated);
    expect(cubit.state.profile, isNull);
  });

  test('bootstrap self-heals USD when profile.baseAssetId is null', () async {
    final authRepository = _FakeAuthRepository(
      cachedSession: const AuthSessionEntity(userId: 'u1', email: 'u1@example.com'),
    );
    final profileRepository = _FakeProfileRepository(
      freeProfile().copyWith(baseAsset: null, baseAssetId: null),
    );
    final cubit = UserCubit(
      GetCachedSessionUseCase(authRepository),
      BootstrapProfileUseCase(profileRepository),
      UpdateBaseCurrencyUseCase(profileRepository),
      UpdatePlanUseCase(profileRepository),
      DeleteAccountUseCase(authRepository),
      SignOutUseCase(authRepository),
    );

    await cubit.bootstrap();

    expect(cubit.state.status, UserStatus.authenticated);
    expect(cubit.state.profile?.baseCurrency, 'USD');
    expect(profileRepository.updatedBaseCurrencyCodes, ['USD']);
  });

  test('logoutOptimistic updates state immediately and calls signOut', () async {
    final authRepository = _FakeAuthRepository(
      cachedSession: const AuthSessionEntity(userId: 'u1', email: 'u1@example.com'),
    );
    final profileRepository = _FakeProfileRepository(freeProfile());
    final cubit = UserCubit(
      GetCachedSessionUseCase(authRepository),
      BootstrapProfileUseCase(profileRepository),
      UpdateBaseCurrencyUseCase(profileRepository),
      UpdatePlanUseCase(profileRepository),
      DeleteAccountUseCase(authRepository),
      SignOutUseCase(authRepository),
    );
    await cubit.bootstrap();

    await cubit.logoutOptimistic();

    expect(cubit.state.status, UserStatus.unauthenticated);
    expect(cubit.state.navigation?.destination, UserDestination.signIn);
    expect(authRepository.signOutCalled, isTrue);
  });
}

class _FakeAuthRepository implements IAuthRepository {
  _FakeAuthRepository({this.cachedSession});

  final AuthSessionEntity? cachedSession;
  bool signOutCalled = false;

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
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<AuthSessionEntity>> confirmEmailOtp(String email) async {
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
  Future<Result<AuthSessionEntity>> signInWithOAuth(AuthProvider provider) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<List<AuthProvider>> getAvailableProviders() async {
    return const [];
  }

  @override
  Future<Result<void>> signOut() async {
    signOutCalled = true;
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    return const Success(null);
  }
}

class _FakeProfileRepository implements IProfileRepository {
  _FakeProfileRepository(this.profile);

  ProfileEntity profile;
  final List<String> updatedBaseCurrencyCodes = [];

  @override
  Future<Result<ProfileBootstrapEntity>> ensureProfile() async {
    return Success(ProfileBootstrapEntity(profile: profile));
  }

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    return Success(profile);
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(String baseCurrency) async {
    updatedBaseCurrencyCodes.add(baseCurrency);
    profile = freeProfile(baseCurrency: baseCurrency).copyWith(baseAssetId: '${baseCurrency.toLowerCase()}-asset');
    return Success(profile);
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String plan) async {
    return Success(profile.copyWith(plan: plan));
  }
}
