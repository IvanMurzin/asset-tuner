import 'dart:async';

import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_out_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/watch_session_usecase.dart';
import 'package:asset_tuner/presentation/session/bloc/session_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  group('SessionCubit', () {
    late _FakeAuthRepository repository;
    late _FakeRevenueCatService revenueCatService;
    late SessionCubit cubit;

    setUp(() {
      repository = _FakeAuthRepository();
      revenueCatService = _FakeRevenueCatService();
      cubit = SessionCubit(
        WatchSessionUseCase(repository),
        SignOutUseCase(repository),
        DeleteAccountUseCase(repository),
        revenueCatService,
      );
    });

    tearDown(() async {
      await cubit.close();
      await repository.dispose();
    });

    test('becomes authenticated and logs into RevenueCat once per user', () async {
      cubit.bootstrap();
      await _flush();
      repository.emitSession(const AuthSessionEntity(userId: 'user-1', email: 'a@test.dev'));
      await _flush();
      repository.emitSession(const AuthSessionEntity(userId: 'user-1', email: 'a@test.dev'));
      await _flush();

      expect(cubit.state.status, SessionStatus.authenticated);
      expect(cubit.state.session?.userId, 'user-1');
      expect(revenueCatService.loggedInUserIds, ['user-1']);
    });

    test('clears state and logs out from RevenueCat on signed out session', () async {
      cubit.bootstrap();
      await _flush();
      repository.emitSession(const AuthSessionEntity(userId: 'user-1', email: 'a@test.dev'));
      await _flush();

      repository.emitSession(null);
      await _flush();

      expect(cubit.state.status, SessionStatus.unauthenticated);
      expect(cubit.state.session, isNull);
      expect(revenueCatService.logOutCalls, 1);
    });

    test('signOut waits for auth stream before clearing state', () async {
      cubit.bootstrap();
      await _flush();
      repository.emitSession(const AuthSessionEntity(userId: 'user-1', email: 'a@test.dev'));
      await _flush();

      final completer = Completer<Result<void>>();
      repository.signOutResult = () => completer.future;
      unawaited(cubit.signOut());
      await _flush();

      expect(cubit.state.status, SessionStatus.authenticated);
      expect(cubit.state.isSigningOut, isTrue);
      completer.complete(const Success(null));
      await _flush();
      expect(cubit.state.status, SessionStatus.authenticated);

      repository.emitSession(null);
      await _flush();

      expect(cubit.state.status, SessionStatus.unauthenticated);
      expect(cubit.state.isSigningOut, isFalse);
      expect(repository.signOutCalls, 1);
    });

    test('signOut failure keeps authenticated session', () async {
      cubit.bootstrap();
      await _flush();
      repository.emitSession(const AuthSessionEntity(userId: 'user-1', email: 'a@test.dev'));
      await _flush();

      repository.signOutResult = () async =>
          const FailureResult(Failure(code: 'sign_out_failed', message: 'Unable to sign out'));

      await cubit.signOut();

      expect(cubit.state.status, SessionStatus.authenticated);
      expect(cubit.state.session?.userId, 'user-1');
      expect(cubit.state.isSigningOut, isFalse);
      expect(cubit.state.failureCode, 'sign_out_failed');
    });

    test('deleteAccount waits for auth stream before clearing state', () async {
      cubit.bootstrap();
      await _flush();
      repository.emitSession(const AuthSessionEntity(userId: 'user-1', email: 'a@test.dev'));
      await _flush();

      final completer = Completer<Result<void>>();
      repository.deleteAccountResult = () => completer.future;
      unawaited(cubit.deleteAccount());
      await _flush();

      expect(cubit.state.status, SessionStatus.authenticated);
      expect(cubit.state.isDeletingAccount, isTrue);
      completer.complete(const Success(null));
      await _flush();
      expect(cubit.state.status, SessionStatus.authenticated);

      repository.emitSession(null);
      await _flush();

      expect(cubit.state.status, SessionStatus.unauthenticated);
      expect(cubit.state.isDeletingAccount, isFalse);
      expect(repository.deleteAccountCalls, 1);
    });
  });
}

class _FakeAuthRepository implements IAuthRepository {
  final _sessionController = StreamController<AuthSessionEntity?>.broadcast();

  int signOutCalls = 0;
  int deleteAccountCalls = 0;
  Future<Result<void>> Function()? signOutResult;
  Future<Result<void>> Function()? deleteAccountResult;

  void emitSession(AuthSessionEntity? session) {
    _sessionController.add(session);
  }

  Future<void> dispose() => _sessionController.close();

  @override
  Stream<AuthSessionEntity?> watchSession() => _sessionController.stream;

  @override
  Future<Result<void>> deleteAccount() async {
    deleteAccountCalls += 1;
    if (deleteAccountResult != null) {
      return deleteAccountResult!();
    }
    return const Success(null);
  }

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
  Future<Result<void>> signOut() async {
    signOutCalls += 1;
    if (signOutResult != null) {
      return signOutResult!();
    }
    return const Success(null);
  }

  @override
  Future<Result<OtpVerificationEntity>> signUpWithPassword(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthSessionEntity>> verifySignUpOtp(String email, String code) async {
    throw UnimplementedError();
  }
}

class _FakeRevenueCatService extends RevenueCatService {
  final List<String> loggedInUserIds = [];
  int logOutCalls = 0;

  @override
  Future<LogInResult> logIn(String appUserId) async {
    loggedInUserIds.add(appUserId);
    return LogInResult(created: false, customerInfo: _customerInfo());
  }

  @override
  Future<CustomerInfo> logOut() async {
    logOutCalls += 1;
    return _customerInfo();
  }
}

CustomerInfo _customerInfo() {
  return const CustomerInfo(
    EntitlementInfos({}, {}),
    {},
    [],
    [],
    [],
    '2026-03-10T00:00:00Z',
    'app-user-id',
    {},
    '2026-03-10T00:00:00Z',
  );
}

Future<void> _flush() {
  return Future<void>.delayed(const Duration(milliseconds: 10));
}
