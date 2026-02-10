import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/local_storage/auth_session_storage.dart';
import 'package:asset_tuner/data/auth/dto/auth_session_dto.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';

enum MockAuthErrorCode { network, unauthorized, rateLimited, validation, conflict, unknown }

class MockAuthException implements Exception {
  MockAuthException(this.code, this.message);

  final MockAuthErrorCode code;
  final String message;

  @override
  String toString() {
    return 'MockAuthException(code: $code, message: $message)';
  }
}

@lazySingleton
class AuthMockDataSource {
  AuthMockDataSource(this._storage);

  final AuthSessionStorage _storage;
  final Map<String, String> _passwordsByEmail = {'demo@asset.tuner': 'demo123'};
  final Map<String, String> _pendingOtpByEmail = {};

  Future<AuthSessionDto?> restoreSession() async {
    final stored = await _storage.readSession();
    if (stored == null) {
      return null;
    }
    return AuthSessionDto(userId: stored.userId, email: stored.email);
  }

  Future<AuthSessionDto?> getCachedSession() async {
    return restoreSession();
  }

  Future<void> requestEmailOtp(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (email.contains('rate')) {
      throw MockAuthException(
        MockAuthErrorCode.rateLimited,
        'Too many attempts. Please wait and try again.',
      );
    }
    if (!email.contains('@')) {
      throw MockAuthException(MockAuthErrorCode.validation, 'Invalid email address.');
    }
    if (email.contains('offline')) {
      throw MockAuthException(MockAuthErrorCode.network, 'Network unavailable.');
    }
  }

  Future<AuthSessionDto> confirmEmailOtp(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (email.contains('expired')) {
      throw MockAuthException(MockAuthErrorCode.unauthorized, 'OTP expired or invalid.');
    }
    final session = _createSession(email);
    await _storage.writeSession(StoredAuthSession(userId: session.userId, email: session.email));
    return session;
  }

  Future<AuthSessionDto> signInWithOAuth(AuthProvider provider) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final email = _oauthEmail(provider);
    final session = _createSession(email);
    await _storage.writeSession(StoredAuthSession(userId: session.userId, email: session.email));
    return session;
  }

  Future<List<AuthProvider>> getAvailableProviders() async {
    return const [AuthProvider.google, AuthProvider.apple];
  }

  Future<void> signInWithPassword(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    _validateEmail(email);
    _validatePassword(password);
    final stored = _passwordsByEmail[email];
    if (stored == null || stored != password) {
      throw MockAuthException(MockAuthErrorCode.unauthorized, 'Invalid email or password.');
    }
    final session = _createSession(email);
    await _storage.writeSession(StoredAuthSession(userId: session.userId, email: session.email));
  }

  Future<OtpChallengeDto> signUpWithPassword(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    _validateEmail(email);
    _validatePassword(password);
    if (_passwordsByEmail.containsKey(email)) {
      throw MockAuthException(MockAuthErrorCode.conflict, 'Email already in use.');
    }
    _passwordsByEmail[email] = password;
    final otp = _generateOtp();
    _pendingOtpByEmail[email] = otp;
    return OtpChallengeDto(email: email, otp: otp);
  }

  Future<AuthSessionDto> verifySignUpOtp(String email, String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final pending = _pendingOtpByEmail[email];
    if (pending == null || pending != code) {
      throw MockAuthException(MockAuthErrorCode.unauthorized, 'Invalid verification code.');
    }
    _pendingOtpByEmail.remove(email);
    final session = _createSession(email);
    await _storage.writeSession(StoredAuthSession(userId: session.userId, email: session.email));
    return session;
  }

  Future<void> clearSession() async {
    await _storage.clear();
  }

  AuthSessionDto _createSession(String email) {
    final randomSuffix = Random().nextInt(999999).toString().padLeft(6, '0');
    return AuthSessionDto(userId: 'user_$randomSuffix', email: email);
  }

  String _oauthEmail(AuthProvider provider) {
    return switch (provider) {
      AuthProvider.google => 'user.google@example.com',
      AuthProvider.apple => 'user.apple@example.com',
      AuthProvider.email => 'user@example.com',
    };
  }

  void _validateEmail(String email) {
    if (!email.contains('@')) {
      throw MockAuthException(MockAuthErrorCode.validation, 'Invalid email address.');
    }
  }

  void _validatePassword(String password) {
    final hasLetters = password.contains(RegExp(r'[A-Za-z]'));
    final hasNumbers = password.contains(RegExp(r'\d'));
    if (password.length < 6 || !hasLetters || !hasNumbers) {
      throw MockAuthException(
        MockAuthErrorCode.validation,
        'Password must be at least 6 characters with letters and numbers.',
      );
    }
  }

  String _generateOtp() {
    return '123456';
  }
}

class OtpChallengeDto {
  const OtpChallengeDto({required this.email, required this.otp});

  final String email;
  final String otp;
}
