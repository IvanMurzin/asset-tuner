import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/auth/data_source/supabase_auth_data_source.dart';
import 'package:asset_tuner/data/auth/mapper/auth_session_mapper.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  AuthRepository(this._dataSource);

  final SupabaseAuthDataSource _dataSource;
  AuthSessionEntity? _cachedSession;

  @override
  Future<Result<AuthSessionEntity?>> restoreSession() async {
    try {
      final dto = _dataSource.currentSession();
      final entity = dto == null ? null : AuthSessionMapper.toEntity(dto);
      _cachedSession = entity;
      logger.i('AuthRepository.restoreSession success: ${entity != null}');
      return Success(entity);
    } catch (error) {
      logger.e('AuthRepository.restoreSession failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to restore session'),
      );
    }
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

  @override
  Future<Result<void>> requestEmailOtp(String email) async {
    try {
      await _dataSource.signInWithOtp(email);
      logger.i('AuthRepository.requestEmailOtp success');
      return const Success(null);
    } catch (error) {
      logger.e('AuthRepository.requestEmailOtp failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to request OTP'),
      );
    }
  }

  @override
  Future<Result<AuthSessionEntity>> confirmEmailOtp(String email) async {
    try {
      final dto = _dataSource.currentSession();
      if (dto == null) {
        return const FailureResult(
          Failure(code: 'unauthorized', message: 'Session not established'),
        );
      }
      final entity = AuthSessionMapper.toEntity(dto);
      _cachedSession = entity;
      logger.i('AuthRepository.confirmEmailOtp success');
      return Success(entity);
    } catch (error) {
      logger.e('AuthRepository.confirmEmailOtp failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to confirm OTP'),
      );
    }
  }

  @override
  Future<Result<AuthSessionEntity>> signInWithOAuth(AuthProvider provider) async {
    try {
      if (provider == AuthProvider.email) {
        return const FailureResult(
          Failure(code: 'validation', message: 'Use email OTP or password sign-in'),
        );
      }
      await _dataSource.signInWithOAuth(provider);
      final dto = _dataSource.currentSession();
      if (dto == null) {
        return const FailureResult(
          Failure(code: 'unknown', message: 'OAuth session not established'),
        );
      }
      final entity = AuthSessionMapper.toEntity(dto);
      _cachedSession = entity;
      logger.i('AuthRepository.signInWithOAuth success: $provider');
      return Success(entity);
    } catch (error) {
      logger.e('AuthRepository.signInWithOAuth failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to sign in'),
      );
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
      final dto = _dataSource.currentSession();
      _cachedSession = dto == null ? null : AuthSessionMapper.toEntity(dto);
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
      final entity = AuthSessionMapper.toEntity(dto);
      _cachedSession = entity;
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
