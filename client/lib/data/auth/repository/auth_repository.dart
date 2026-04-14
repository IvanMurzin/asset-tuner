import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/auth/data_source/i_auth_data_source.dart';
import 'package:asset_tuner/data/auth/dto/auth_session_dto.dart';
import 'package:asset_tuner/data/auth/mapper/auth_session_mapper.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  AuthRepository(
    this._dataSource, {
    @Named('oauthSignInTimeout') Duration oAuthSignInTimeout = const Duration(seconds: 90),
  }) : _oAuthSignInTimeout = oAuthSignInTimeout;

  final IAuthDataSource _dataSource;
  final Duration _oAuthSignInTimeout;
  AuthSessionEntity? _cachedSession;

  @override
  Stream<AuthSessionEntity?> watchSession() async* {
    yield _syncCachedSession(_dataSource.currentSession());

    yield* _dataSource.onAuthStateChange().map((authState) {
      final session = authState.event == AuthChangeEvent.signedOut
          ? null
          : _dataSource.currentSession();
      return _syncCachedSession(session);
    }).distinct();
  }

  @override
  Future<AuthSessionEntity?> getCachedSession() async {
    if (_cachedSession != null) {
      return _cachedSession;
    }
    final dto = _dataSource.currentSession();
    if (dto == null) {
      return null;
    }
    final entity = AuthSessionMapper.toEntity(dto);
    _cachedSession = entity;
    return entity;
  }

  AuthSessionEntity? _syncCachedSession(AuthSessionDto? dto) {
    final entity = dto == null ? null : AuthSessionMapper.toEntity(dto);
    _cachedSession = entity;
    return entity;
  }

  @override
  Future<Result<void>> resendSignUpOtp(String email) async {
    try {
      await _dataSource.resendSignUpOtp(email);
      logger.i('AuthRepository.resendSignUpOtp success');
      return const Success(null);
    } catch (error) {
      logger.e('AuthRepository.resendSignUpOtp failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to resend OTP'),
      );
    }
  }

  @override
  Future<Result<AuthSessionEntity>> signInWithOAuth(AuthProvider provider) async {
    StreamSubscription<AuthState>? authSubscription;
    Timer? timeoutTimer;
    final signedInCompleter = Completer<AuthSessionEntity>();
    try {
      if (provider == AuthProvider.email) {
        return const FailureResult(
          Failure(code: 'validation', message: 'Use email OTP or password sign-in'),
        );
      }
      authSubscription = _dataSource.onAuthStateChange().listen(
        (state) {
          if (state.event != AuthChangeEvent.signedIn || signedInCompleter.isCompleted) {
            return;
          }
          final session = state.session;
          if (session == null) {
            return;
          }
          final email = session.user.email ?? '';
          signedInCompleter.complete(
            _syncCachedSession(AuthSessionDto(userId: session.user.id, email: email))!,
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!signedInCompleter.isCompleted) {
            signedInCompleter.completeError(error, stackTrace);
          }
        },
      );
      timeoutTimer = Timer(_oAuthSignInTimeout, () {
        if (!signedInCompleter.isCompleted) {
          signedInCompleter.completeError(
            TimeoutException('OAuth sign-in timed out', _oAuthSignInTimeout),
          );
        }
      });
      await _dataSource.signInWithOAuth(provider);
      final entity = await signedInCompleter.future;
      logger.i('AuthRepository.signInWithOAuth success: $provider');
      return Success(entity);
    } on TimeoutException catch (error) {
      logger.e('AuthRepository.signInWithOAuth timed out', error: error);
      return const FailureResult(Failure(code: 'timeout', message: 'OAuth sign-in timed out'));
    } catch (error) {
      logger.e('AuthRepository.signInWithOAuth failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to sign in'),
      );
    } finally {
      timeoutTimer?.cancel();
      await authSubscription?.cancel();
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _dataSource.signOut();
      _cachedSession = null;
      logger.i('AuthRepository.signOut success');
      return const Success(null);
    } catch (error) {
      logger.e('AuthRepository.signOut failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to sign out'),
      );
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _dataSource.deleteMyAccount();
      await _dataSource.signOut();
      _cachedSession = null;
      logger.i('AuthRepository.deleteAccount success');
      return const Success(null);
    } catch (error) {
      logger.e('AuthRepository.deleteAccount failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to delete account'),
      );
    }
  }

  @override
  Future<Result<void>> signInWithPassword(String email, String password) async {
    try {
      await _dataSource.signInWithPassword(email, password);
      _syncCachedSession(_dataSource.currentSession());
      logger.i('AuthRepository.signInWithPassword success');
      return const Success(null);
    } catch (error) {
      logger.e('AuthRepository.signInWithPassword failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to sign in'),
      );
    }
  }

  @override
  Future<Result<OtpVerificationEntity>> signUpWithPassword(String email, String password) async {
    try {
      await _dataSource.signUpWithPassword(email, password);
      if (!AppConfig.instance.isOtpEnabled) {
        final hasSession = _dataSource.currentSession() != null;
        if (!hasSession) {
          await _dataSource.signInWithPassword(email, password);
        }
        _syncCachedSession(_dataSource.currentSession());
      }
      logger.i('AuthRepository.signUpWithPassword success');
      return Success(OtpVerificationEntity(email: email));
    } catch (error) {
      logger.e('AuthRepository.signUpWithPassword failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to sign up'),
      );
    }
  }

  @override
  Future<Result<AuthSessionEntity>> verifySignUpOtp(String email, String code) async {
    try {
      final dto = await _dataSource.verifySignUpOtp(email: email, token: code);
      if (dto == null) {
        return const FailureResult(
          Failure(code: 'unauthorized', message: 'OTP verification failed'),
        );
      }
      final entity = _syncCachedSession(dto)!;
      logger.i('AuthRepository.verifySignUpOtp success');
      return Success(entity);
    } catch (error) {
      logger.e('AuthRepository.verifySignUpOtp failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to verify OTP'),
      );
    }
  }

  @override
  Future<List<AuthProvider>> getAvailableProviders() {
    return Future.value(const [AuthProvider.email, AuthProvider.google, AuthProvider.apple]);
  }
}
