import 'dart:async';

import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/auth/data_source/i_auth_data_source.dart';
import 'package:asset_tuner/data/auth/dto/auth_session_dto.dart';
import 'package:asset_tuner/data/auth/repository/auth_repository.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthRepository.watchSession', () {
    late _FakeAuthDataSource dataSource;
    late AuthRepository repository;

    setUp(() {
      dataSource = _FakeAuthDataSource();
      repository = AuthRepository(dataSource);
    });

    tearDown(() async {
      await dataSource.dispose();
    });

    test('emits current session immediately', () async {
      dataSource.currentSessionValue = const AuthSessionDto(
        userId: 'user-1',
        email: 'user@example.com',
      );

      await expectLater(
        repository.watchSession().take(1),
        emits(const AuthSessionEntity(userId: 'user-1', email: 'user@example.com')),
      );
    });

    test('updates cache and emits null on sign out', () async {
      dataSource.currentSessionValue = const AuthSessionDto(
        userId: 'user-1',
        email: 'user@example.com',
      );

      Future<void>.delayed(Duration.zero, () {
        dataSource.currentSessionValue = null;
        dataSource.authStateController.add(const AuthState(AuthChangeEvent.signedOut, null));
      });

      await expectLater(
        repository.watchSession().take(2),
        emitsInOrder([
          const AuthSessionEntity(userId: 'user-1', email: 'user@example.com'),
          isNull,
        ]),
      );
      expect(await repository.getCachedSession(), isNull);
    });
  });

  group('AuthRepository.resendSignUpOtp', () {
    late _FakeAuthDataSource dataSource;
    late AuthRepository repository;

    setUp(() {
      dataSource = _FakeAuthDataSource();
      repository = AuthRepository(dataSource);
    });

    tearDown(() async {
      await dataSource.dispose();
    });

    test('uses signup resend data source method', () async {
      final result = await repository.resendSignUpOtp('user@example.com');

      expect(result, const Success<void>(null));
      expect(dataSource.lastResendEmail, 'user@example.com');
      expect(dataSource.resendSignUpOtpCalls, 1);
    });
  });

  group('AuthRepository.signInWithOAuth', () {
    late _FakeAuthDataSource dataSource;

    setUp(() {
      dataSource = _FakeAuthDataSource();
    });

    tearDown(() async {
      await dataSource.dispose();
    });

    test('returns signed-in session and updates cache', () async {
      final repository = AuthRepository(dataSource);
      final dto = const AuthSessionDto(userId: 'oauth-user', email: 'oauth@example.com');

      Future<void>.delayed(Duration.zero, () {
        dataSource.authStateController.add(
          AuthState(AuthChangeEvent.signedIn, _session(userId: dto.userId, email: dto.email)),
        );
      });

      final result = await repository.signInWithOAuth(AuthProvider.google);

      expect(result, isA<Success<AuthSessionEntity>>());
      expect(
        (result as Success<AuthSessionEntity>).value,
        const AuthSessionEntity(userId: 'oauth-user', email: 'oauth@example.com'),
      );
      expect(await repository.getCachedSession(), result.value);
      expect(dataSource.lastOAuthProvider, AuthProvider.google);
    });

    test('times out when auth stream does not confirm OAuth session', () async {
      final repository = AuthRepository(
        dataSource,
        oAuthSignInTimeout: const Duration(milliseconds: 10),
      );

      final result = await repository.signInWithOAuth(AuthProvider.google);

      expect(result, isA<FailureResult<AuthSessionEntity>>());
      expect((result as FailureResult<AuthSessionEntity>).failure.code, 'timeout');
    });
  });
}

class _FakeAuthDataSource implements IAuthDataSource {
  final authStateController = StreamController<AuthState>.broadcast();

  AuthSessionDto? currentSessionValue;
  AuthProvider? lastOAuthProvider;
  String? lastResendEmail;
  String? lastSignInEmail;
  int resendSignUpOtpCalls = 0;
  int signInWithPasswordCalls = 0;

  @override
  AuthSessionDto? currentSession() => currentSessionValue;

  @override
  Stream<AuthState> onAuthStateChange() => authStateController.stream;

  @override
  Future<void> deleteMyAccount() async {}

  @override
  Future<void> signInWithOAuth(AuthProvider provider) async {
    lastOAuthProvider = provider;
  }

  @override
  Future<void> resendSignUpOtp(String email) async {
    resendSignUpOtpCalls += 1;
    lastResendEmail = email;
  }

  @override
  Future<void> signInWithPassword(String email, String password) async {
    signInWithPasswordCalls += 1;
    lastSignInEmail = email;
    currentSessionValue = AuthSessionDto(userId: 'signed-in-user', email: email);
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUpWithPassword(String email, String password) async {}

  @override
  Future<AuthSessionDto?> verifySignUpOtp({required String email, required String token}) async {
    return null;
  }

  Future<void> dispose() => authStateController.close();
}

Session _session({required String userId, required String email}) {
  return Session(
    accessToken: 'eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjQ3NjEzNjAwMDB9.signature',
    tokenType: 'bearer',
    user: User(
      id: userId,
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      email: email,
      createdAt: '2026-03-10T00:00:00Z',
    ),
  );
}
