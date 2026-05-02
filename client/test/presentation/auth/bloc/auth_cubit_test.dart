import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/revenuecat/revenuecat_service.dart';
import 'package:asset_tuner/core/session/unauthorized_notifier.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_out_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/watch_session_usecase.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';

const _user1 = AuthSessionEntity(userId: 'user-1', email: 'a@test.dev');

void main() {
  group('AuthCubit', () {
    late _FakeAuthRepository repo;
    late _FakeRevenueCat rc;
    late UnauthorizedNotifier unauthorized;
    late AuthCubit cubit;

    setUp(() {
      repo = _FakeAuthRepository();
      rc = _FakeRevenueCat();
      unauthorized = UnauthorizedNotifier();
      cubit = AuthCubit(
        WatchSessionUseCase(repo),
        SignOutUseCase(repo),
        DeleteAccountUseCase(repo),
        rc,
        AppAnalytics(),
        unauthorized,
      );
    });

    tearDown(() async {
      await cubit.close();
      await unauthorized.dispose();
      await repo.dispose();
    });

    test('initial state is AuthStatus.initial', () {
      expect(cubit.state.status, AuthStatus.initial);
      expect(cubit.state.isResolved, isFalse);
      expect(cubit.state.isAuthenticated, isFalse);
    });

    test('bootstrap → session arrives → authenticated, RC logged in once', () async {
      cubit.bootstrap();
      await _flush();
      repo.emit(_user1);
      await _flush();
      // re-emitting the same session must not trigger RC login again
      repo.emit(_user1);
      await _flush();

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.session, _user1);
      expect(cubit.state.isResolved, isTrue);
      expect(rc.loginCalls, ['user-1']);
    });

    test('bootstrap → null session → unauthenticated, RC.logOut', () async {
      cubit.bootstrap();
      await _flush();
      repo.emit(_user1);
      await _flush();

      repo.emit(null);
      await _flush();

      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.session, isNull);
      expect(cubit.state.isResolved, isTrue);
      expect(rc.logoutCalls, 1);
    });

    test(
      'signOut: sets isSigningOut, waits for the supabase stream, does not emit unauth itself',
      () async {
        cubit.bootstrap();
        await _flush();
        repo.emit(_user1);
        await _flush();

        final completer = Completer<Result<void>>();
        repo.signOutResult = () => completer.future;

        unawaited(cubit.signOut());
        await _flush();
        expect(cubit.state.status, AuthStatus.authenticated);
        expect(cubit.state.isSigningOut, isTrue);

        completer.complete(const Success(null));
        await _flush();
        // sign-out usecase succeeded but the stream has not emitted null yet.
        expect(cubit.state.status, AuthStatus.authenticated);

        repo.emit(null);
        await _flush();
        expect(cubit.state.status, AuthStatus.unauthenticated);
        expect(cubit.state.isSigningOut, isFalse);
      },
    );

    test('signOut failure — stays authenticated with failureCode', () async {
      cubit.bootstrap();
      await _flush();
      repo.emit(_user1);
      await _flush();

      repo.signOutResult = () async => const FailureResult(Failure(code: 'E', message: 'oops'));

      await cubit.signOut();
      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.isSigningOut, isFalse);
      expect(cubit.state.failureCode, 'E');
      expect(cubit.state.failureMessage, 'oops');
    });

    test('signOut while unauthenticated — no-op', () async {
      cubit.bootstrap();
      await _flush();
      repo.emit(null);
      await _flush();

      await cubit.signOut();
      expect(repo.signOutCalls, 0);
    });

    test('deleteAccount: same flow — waits for the supabase stream', () async {
      cubit.bootstrap();
      await _flush();
      repo.emit(_user1);
      await _flush();

      final completer = Completer<Result<void>>();
      repo.deleteResult = () => completer.future;

      unawaited(cubit.deleteAccount());
      await _flush();
      expect(cubit.state.isDeletingAccount, isTrue);

      completer.complete(const Success(null));
      await _flush();
      expect(cubit.state.status, AuthStatus.authenticated);

      repo.emit(null);
      await _flush();
      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.isDeletingAccount, isFalse);
    });

    test(
      'forceLocalSignOut: authenticated → unauthenticated, RC.logOut, no supabase signOut',
      () async {
        cubit.bootstrap();
        await _flush();
        repo.emit(_user1);
        await _flush();

        await cubit.forceLocalSignOut();
        expect(cubit.state.status, AuthStatus.unauthenticated);
        expect(cubit.state.session, isNull);
        expect(cubit.state.failureCode, 'unauthorized');
        expect(rc.logoutCalls, 1);
        // key invariant — supabase signOut is NOT called
        expect(repo.signOutCalls, 0);
      },
    );

    test('forceLocalSignOut on initial — no-op', () async {
      cubit.bootstrap();
      await _flush();
      // session has not arrived yet — still initial
      await cubit.forceLocalSignOut();
      expect(cubit.state.status, AuthStatus.initial);
    });

    test('forceLocalSignOut on unauthenticated — no-op (repeated 401s do not duplicate)', () async {
      cubit.bootstrap();
      await _flush();
      repo.emit(null);
      await _flush();

      await cubit.forceLocalSignOut();
      await cubit.forceLocalSignOut();
      // no thrashing / repeated RC.logOut
      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(rc.logoutCalls, 0);
    });

    test('UnauthorizedNotifier emits → AuthCubit transitions to unauthenticated', () async {
      cubit.bootstrap();
      await _flush();
      repo.emit(_user1);
      await _flush();
      expect(cubit.state.status, AuthStatus.authenticated);

      unauthorized.notifyUnauthorized();
      await _flush();

      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.failureCode, 'unauthorized');
      // supabase signOut is NOT called — backend already rejected the token
      expect(repo.signOutCalls, 0);
    });

    test('switching to a different user — RC re-logs in', () async {
      cubit.bootstrap();
      await _flush();
      repo.emit(_user1);
      await _flush();
      repo.emit(const AuthSessionEntity(userId: 'user-2', email: 'b@b.dev'));
      await _flush();

      expect(cubit.state.session?.userId, 'user-2');
      expect(rc.loginCalls, ['user-1', 'user-2']);
    });

    test('isResolved correct for all branches', () {
      expect(const AuthState().isResolved, isFalse);
      expect(const AuthState(status: AuthStatus.authenticated, session: _user1).isResolved, isTrue);
      expect(const AuthState(status: AuthStatus.unauthenticated).isResolved, isTrue);
    });

    test('isAuthenticated requires both status AND session', () {
      expect(const AuthState(status: AuthStatus.authenticated).isAuthenticated, isFalse);
      expect(
        const AuthState(status: AuthStatus.authenticated, session: _user1).isAuthenticated,
        isTrue,
      );
    });
  });
}

Future<void> _flush() => Future<void>.delayed(const Duration(milliseconds: 10));

class _FakeAuthRepository implements IAuthRepository {
  final _controller = StreamController<AuthSessionEntity?>.broadcast();
  AuthSessionEntity? _cached;

  int signOutCalls = 0;
  int deleteCalls = 0;
  Future<Result<void>> Function()? signOutResult;
  Future<Result<void>> Function()? deleteResult;

  void emit(AuthSessionEntity? s) {
    _cached = s;
    _controller.add(s);
  }

  Future<void> dispose() => _controller.close();

  @override
  Stream<AuthSessionEntity?> watchSession() => _controller.stream;

  @override
  Future<AuthSessionEntity?> getCachedSession() async => _cached;

  @override
  Future<Result<void>> signOut() async {
    signOutCalls += 1;
    return signOutResult?.call() ?? const Success(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    deleteCalls += 1;
    return deleteResult?.call() ?? const Success(null);
  }

  @override
  Future<List<AuthProvider>> getAvailableProviders() async => const [];

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
  Future<Result<OtpVerificationEntity>> signUpWithPassword(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthSessionEntity>> verifySignUpOtp(String email, String code) async {
    throw UnimplementedError();
  }
}

class _FakeRevenueCat extends RevenueCatService {
  final List<String> loginCalls = [];
  int logoutCalls = 0;

  @override
  Future<LogInResult> logIn(String appUserId) async {
    loginCalls.add(appUserId);
    return LogInResult(created: false, customerInfo: _info());
  }

  @override
  Future<CustomerInfo> logOut() async {
    logoutCalls += 1;
    return _info();
  }
}

CustomerInfo _info() => const CustomerInfo(
  EntitlementInfos({}, {}),
  {},
  [],
  [],
  [],
  '2026-04-01T00:00:00Z',
  'app-id',
  {},
  '2026-04-01T00:00:00Z',
);
