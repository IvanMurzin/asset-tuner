import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_plan_usecase.dart';
import 'package:asset_tuner/domain/subscription/entity/subscription_info_entity.dart';
import 'package:asset_tuner/domain/subscription/repository/i_subscription_repository.dart';
import 'package:asset_tuner/domain/subscription/usecase/get_is_pro_usecase.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_cubit.dart';
import 'package:asset_tuner/presentation/paywall/entity/paywall_args.dart';
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
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
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
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<List<AuthProvider>> getAvailableProviders() async {
    return const [];
  }

  @override
  Future<Result<void>> deleteAccount() async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }
}

class FakeProfileRepository implements IProfileRepository {
  FakeProfileRepository({
    required this.getResult,
    required this.ensureResult,
    required this.updatePlanResult,
  });

  final Result<ProfileEntity> getResult;
  final Result<ProfileBootstrapEntity> ensureResult;
  final Result<ProfileEntity> updatePlanResult;

  @override
  Future<Result<ProfileBootstrapEntity>> ensureProfile() async {
    return ensureResult;
  }

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    return getResult;
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(String baseCurrency) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String plan) async {
    return updatePlanResult;
  }
}

class FakeSubscriptionRepository implements ISubscriptionRepository {
  FakeSubscriptionRepository({this.isPro = false});

  final bool isPro;

  @override
  Future<Result<SubscriptionInfoEntity>> getCustomerInfo() async {
    return Success(SubscriptionInfoEntity(isPro: isPro, activeProductIds: const []));
  }

  @override
  Future<bool> hasProEntitlement() async => isPro;

  @override
  Future<Result<SubscriptionInfoEntity>> restorePurchases() async {
    return Success(SubscriptionInfoEntity(isPro: isPro, activeProductIds: const []));
  }
}

void main() {
  test('load uses free plan and shows entitlementsUnverified on network', () async {
    final repo = FakeProfileRepository(
      getResult: const FailureResult(Failure(code: 'network', message: 'Offline')),
      ensureResult: Success(
        ProfileBootstrapEntity(
          profile: freeProfile(),
        ),
      ),
      updatePlanResult: const FailureResult(Failure(code: 'validation', message: 'Not used')),
    );

    final subscriptionRepo = FakeSubscriptionRepository(isPro: false);
    final cubit = PaywallCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(userId: 'user_1', email: 'user@example.com'),
        ),
      ),
      GetProfileUseCase(repo),
      BootstrapProfileUseCase(repo),
      UpdatePlanUseCase(repo),
      GetIsProUseCase(subscriptionRepo),
    );
    addTearDown(cubit.close);

    await cubit.load(reason: PaywallReason.subaccountsLimit);

    expect(cubit.state.status, PaywallStatus.ready);
    expect(cubit.state.plan, 'free');
    expect(cubit.state.entitlementsUnverified, isTrue);
    expect(cubit.state.loadFailureCode, 'network');
  });

  test('selectPlan updates selectedPlan', () async {
    final repo = FakeProfileRepository(
      getResult: Success(freeProfile()),
      ensureResult: const FailureResult(Failure(code: 'validation', message: 'Not used')),
      updatePlanResult: const FailureResult(Failure(code: 'validation', message: 'Not used')),
    );

    final subscriptionRepo = FakeSubscriptionRepository(isPro: false);
    final cubit = PaywallCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(userId: 'user_1', email: 'user@example.com'),
        ),
      ),
      GetProfileUseCase(repo),
      BootstrapProfileUseCase(repo),
      UpdatePlanUseCase(repo),
      GetIsProUseCase(subscriptionRepo),
    );
    addTearDown(cubit.close);

    await cubit.load(reason: PaywallReason.accountsLimit);
    cubit.selectPlan(PaywallPlanOption.monthly);

    expect(cubit.state.selectedPlan, PaywallPlanOption.monthly);
  });
}
