import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/auth/data_source/auth_mock_data_source.dart';
import 'package:asset_tuner/data/auth/mapper/auth_session_mapper.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  AuthRepository(this._dataSource);

  final AuthMockDataSource _dataSource;
  AuthSessionEntity? _cachedSession;

  @override
  Future<Result<AuthSessionEntity?>> restoreSession() async {
    try {
      final dto = await _dataSource.restoreSession();
      final session = dto == null ? null : AuthSessionMapper.toEntity(dto);
      _cachedSession = session;
      logger.i('AuthRepository.restoreSession success: ${session != null}');
      return Success(session);
    } catch (error) {
      logger.e('AuthRepository.restoreSession failed', error: error);
      return FailureResult(_mapFailure(error));
    }
  }

  @override
  Future<AuthSessionEntity?> getCachedSession() async {
    if (_cachedSession != null) {
      return _cachedSession;
    }
    final dto = await _dataSource.getCachedSession();
    final session = dto == null ? null : AuthSessionMapper.toEntity(dto);
    _cachedSession = session;
    return session;
  }

  @override
  Future<Result<void>> requestEmailOtp(String email) async {
    try {
      await _dataSource.requestEmailOtp(email);
      logger.i('AuthRepository.requestEmailOtp success');
      return const Success(null);
    } catch (error) {
      logger.e('AuthRepository.requestEmailOtp failed', error: error);
      return FailureResult(_mapFailure(error));
    }
  }

  @override
  Future<Result<AuthSessionEntity>> confirmEmailOtp(String email) async {
    try {
      final dto = await _dataSource.confirmEmailOtp(email);
      final session = AuthSessionMapper.toEntity(dto);
      _cachedSession = session;
      logger.i('AuthRepository.confirmEmailOtp success');
      return Success(session);
    } catch (error) {
      logger.e('AuthRepository.confirmEmailOtp failed', error: error);
      return FailureResult(_mapFailure(error));
    }
  }

  @override
  Future<Result<AuthSessionEntity>> signInWithOAuth(AuthProvider provider) async {
    try {
      final dto = await _dataSource.signInWithOAuth(provider);
      final session = AuthSessionMapper.toEntity(dto);
      _cachedSession = session;
      logger.i('AuthRepository.signInWithOAuth success: $provider');
      return Success(session);
    } catch (error) {
      logger.e('AuthRepository.signInWithOAuth failed', error: error);
      return FailureResult(_mapFailure(error));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _dataSource.clearSession();
      _cachedSession = null;
      logger.i('AuthRepository.signOut success');
      return const Success(null);
    } catch (error) {
      logger.e('AuthRepository.signOut failed', error: error);
      return FailureResult(_mapFailure(error));
    }
  }

  @override
  Future<Result<void>> signInWithPassword(String email, String password) async {
    try {
      await _dataSource.signInWithPassword(email, password);
      final session = await _dataSource.getCachedSession();
      _cachedSession = session == null ? null : AuthSessionMapper.toEntity(session);
      logger.i('AuthRepository.signInWithPassword success');
      return const Success(null);
    } catch (error) {
      logger.e('AuthRepository.signInWithPassword failed', error: error);
      return FailureResult(_mapFailure(error));
    }
  }

  @override
  Future<Result<OtpVerificationEntity>> signUpWithPassword(String email, String password) async {
    try {
      final challenge = await _dataSource.signUpWithPassword(email, password);
      logger.i('AuthRepository.signUpWithPassword success');
      return Success(OtpVerificationEntity(userId: '', email: challenge.email));
    } catch (error) {
      logger.e('AuthRepository.signUpWithPassword failed', error: error);
      return FailureResult(_mapFailure(error));
    }
  }

  @override
  Future<Result<AuthSessionEntity>> verifySignUpOtp(String email, String code) async {
    try {
      final dto = await _dataSource.verifySignUpOtp(email, code);
      final session = AuthSessionMapper.toEntity(dto);
      _cachedSession = session;
      logger.i('AuthRepository.verifySignUpOtp success');
      return Success(session);
    } catch (error) {
      logger.e('AuthRepository.verifySignUpOtp failed', error: error);
      return FailureResult(_mapFailure(error));
    }
  }

  @override
  Future<List<AuthProvider>> getAvailableProviders() {
    return _dataSource.getAvailableProviders();
  }

  Failure _mapFailure(Object error) {
    if (error is MockAuthException) {
      final code = switch (error.code) {
        MockAuthErrorCode.network => 'network',
        MockAuthErrorCode.unauthorized => 'unauthorized',
        MockAuthErrorCode.rateLimited => 'rate_limited',
        MockAuthErrorCode.validation => 'validation',
        MockAuthErrorCode.conflict => 'conflict',
        MockAuthErrorCode.unknown => 'unknown',
      };
      return Failure(code: code, message: error.message);
    }
    return const Failure(code: 'unknown', message: 'Unknown error');
  }
}
