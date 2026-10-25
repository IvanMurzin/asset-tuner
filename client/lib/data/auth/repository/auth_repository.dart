import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';
import 'package:asset_tuner/core/utils/app_lifecycle_signal.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/auth/data_source/i_auth_data_source.dart';
import 'package:asset_tuner/data/auth/dto/auth_session_dto.dart';
import 'package:asset_tuner/data/auth/mapper/auth_session_mapper.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/sign_up_result_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  AuthRepository(
    this._dataSource, {
    @Named('oauthSignInTimeout') Duration oAuthSignInTimeout = const Duration(seconds: 90),
    @Named('oauthResumeGrace') Duration oAuthResumeGrace = const Duration(seconds: 3),
    AppLifecycleSignal? lifecycleSignal,
  }) : _oAuthSignInTimeout = oAuthSignInTimeout,
       _oAuthResumeGrace = oAuthResumeGrace,
       _lifecycleSignal = lifecycleSignal;

  final IAuthDataSource _dataSource;
  final Duration _oAuthSignInTimeout;

  /// How long to wait for the OAuth callback after the app comes back from the browser. Without
  /// a session by then the user cancelled (QA-008); a late callback still signs in through
  /// [watchSession].
  final Duration _oAuthResumeGrace;
  final AppLifecycleSignal? _lifecycleSignal;
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
  Future<Result<void>> requestPasswordReset(String email) async {
    try {
      await _dataSource.requestPasswordReset(email);
      logger.i('AuthRepository.requestPasswordReset success');
      return const Success(null);
    } catch (error) {
      logger.e('AuthRepository.requestPasswordReset failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to send the code'),
      );
    }
  }

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _dataSource.resetPasswordWithCode(email: email, token: code, newPassword: newPassword);
      logger.i('AuthRepository.resetPassword success');
      return const Success(null);
    } catch (error) {
      logger.e('AuthRepository.resetPassword failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to reset the password'),
      );
    }
  }

  @override
  Future<Result<AuthSessionEntity>> signInWithOAuth(AuthProvider provider) async {
    StreamSubscription<AuthState>? authSubscription;
    StreamSubscription<AppLifecycleState>? lifecycleSubscription;
    Timer? timeoutTimer;
    Timer? resumeGraceTimer;
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
      lifecycleSubscription = _lifecycleSignal?.changes.listen((state) {
        resumeGraceTimer?.cancel();
        if (state != AppLifecycleState.resumed) {
          return;
        }
        resumeGraceTimer = Timer(_oAuthResumeGrace, () {
          if (!signedInCompleter.isCompleted) {
            signedInCompleter.completeError(const _OAuthCancelled());
          }
        });
      });
      final entity = await signedInCompleter.future;
      logger.i('AuthRepository.signInWithOAuth success: $provider');
      return Success(entity);
    } on _OAuthCancelled {
      logger.i('AuthRepository.signInWithOAuth cancelled: $provider');
      return const FailureResult(Failure(code: oAuthCancelledCode, message: 'OAuth cancelled'));
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
      resumeGraceTimer?.cancel();
      await lifecycleSubscription?.cancel();
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
  Future<Result<SignUpResultEntity>> signUpWithPassword(String email, String password) async {
    try {
      await _dataSource.signUpWithPassword(email, password);
      logger.i('AuthRepository.signUpWithPassword success');
      if (AppConfig.instance.isOtpEnabled) {
        return Success(SignUpResultEntity.otpRequired(email: email));
      }
      if (_dataSource.currentSession() == null) {
        await _dataSource.signInWithPassword(email, password);
      }
      _syncCachedSession(_dataSource.currentSession());
      return const Success(SignUpResultEntity.signedIn());
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
    // Apple sign-in on Android is a web flow nobody configured or tested; offer it on iOS only
    // (QA-012).
    return Future.value([
      AuthProvider.email,
      AuthProvider.google,
      if (defaultTargetPlatform == TargetPlatform.iOS) AuthProvider.apple,
    ]);
  }
}

class _OAuthCancelled implements Exception {
  const _OAuthCancelled();
}
