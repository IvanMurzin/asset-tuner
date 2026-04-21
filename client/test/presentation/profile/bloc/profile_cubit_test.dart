import 'dart:async';

import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/watch_session_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/ensure_profile_ready_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_base_currency_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/update_plan_usecase.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileCubit', () {
    late _FakeAuthRepository authRepository;
    late _FakeProfileRepository profileRepository;
    late ProfileCubit cubit;

    setUp(() {
      authRepository = _FakeAuthRepository();
      profileRepository = _FakeProfileRepository();
      cubit = ProfileCubit(
        WatchSessionUseCase(authRepository),
        EnsureProfileReadyUseCase(
          GetProfileUseCase(profileRepository),
          UpdateBaseCurrencyUseCase(profileRepository),
        ),
        UpdateBaseCurrencyUseCase(profileRepository),
        UpdatePlanUseCase(profileRepository),
      );
    });

    tearDown(() async {
      await cubit.close();
      await authRepository.dispose();
    });

    test('loads profile when session becomes authenticated', () async {
      cubit.bootstrap();
      await _flush();
      authRepository.emitSession(const AuthSessionEntity(userId: 'user-1', email: 'user@test.dev'));
      await _flush();

      expect(cubit.state.status, ProfileStatus.ready);
      expect(cubit.state.profile?.userId, 'user-1');
    });

    test('clears profile when session becomes unauthenticated', () async {
      cubit.bootstrap();
      await _flush();
      authRepository.emitSession(const AuthSessionEntity(userId: 'user-1', email: 'user@test.dev'));
      await _flush();

      authRepository.emitSession(null);
      await _flush();

      expect(cubit.state.status, ProfileStatus.initial);
      expect(cubit.state.profile, isNull);
    });

    test('updates base currency in ready state', () async {
      cubit.bootstrap();
      await _flush();
      authRepository.emitSession(const AuthSessionEntity(userId: 'user-1', email: 'user@test.dev'));
      await _flush();
      profileRepository.updateBaseCurrencyResult = Success(_profile(baseAssetId: 'eur-asset-id'));

      await cubit.updateBaseCurrency('EUR');

      expect(profileRepository.updatedBaseCurrency, 'EUR');
      expect(cubit.state.profile?.baseAssetId, 'eur-asset-id');
    });

    test('syncSubscription refreshes plan', () async {
      cubit.bootstrap();
      await _flush();
      authRepository.emitSession(const AuthSessionEntity(userId: 'user-1', email: 'user@test.dev'));
      await _flush();
      profileRepository.updatePlanResult = Success(
        _profile(baseAssetId: 'base-asset-id', plan: 'pro'),
      );

      await cubit.syncSubscription();

      expect(profileRepository.updatedPlan, 'pro');
      expect(cubit.state.profile?.plan, 'pro');
    });
  });
}

class _FakeAuthRepository implements IAuthRepository {
  final _sessionController = StreamController<AuthSessionEntity?>.broadcast();

  void emitSession(AuthSessionEntity? session) {
    _sessionController.add(session);
  }

  Future<void> dispose() => _sessionController.close();

  @override
  Stream<AuthSessionEntity?> watchSession() => _sessionController.stream;

  @override
  Future<Result<void>> deleteAccount() async => const Success(null);

  @override
  Future<List<AuthProvider>> getAvailableProviders() async => const [];

  @override
  Future<AuthSessionEntity?> getCachedSession() async => null;

  @override
  Future<Result<void>> resendSignUpOtp(String email) async => const Success(null);

  @override
  Future<Result<void>> signInWithPassword(String email, String password) async =>
      const Success(null);

  @override
  Future<Result<AuthSessionEntity>> signInWithOAuth(AuthProvider provider) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> signOut() async => const Success(null);

  @override
  Future<Result<OtpVerificationEntity>> signUpWithPassword(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthSessionEntity>> verifySignUpOtp(String email, String code) async {
    throw UnimplementedError();
  }
}

class _FakeProfileRepository implements IProfileRepository {
  Result<ProfileEntity> getProfileResult = Success(_profile(baseAssetId: 'base-asset-id'));
  Result<ProfileEntity> updateBaseCurrencyResult = Success(_profile(baseAssetId: 'base-asset-id'));
  Result<ProfileEntity> updatePlanResult = Success(
    _profile(baseAssetId: 'base-asset-id', plan: 'pro'),
  );
  String? updatedBaseCurrency;
  String? updatedPlan;

  @override
  Future<Result<ProfileEntity>> getProfile() async => getProfileResult;

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(String baseCurrency) async {
    updatedBaseCurrency = baseCurrency;
    return updateBaseCurrencyResult;
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String plan) async {
    updatedPlan = plan;
    return updatePlanResult;
  }

  @override
  Future<Result<void>> sendContactDeveloperMessage({
    required String name,
    required String email,
    required String description,
  }) async {
    return const Success(null);
  }
}

ProfileEntity _profile({required String? baseAssetId, String plan = 'free'}) {
  return ProfileEntity(
    userId: 'user-1',
    baseAssetId: baseAssetId,
    plan: plan,
    entitlements: const EntitlementsEntity(),
  );
}

Future<void> _flush() {
  return Future<void>.delayed(const Duration(milliseconds: 10));
}
