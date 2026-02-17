import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';

abstract interface class IAuthRepository {
  Future<Result<AuthSessionEntity?>> restoreSession();
  Future<AuthSessionEntity?> getCachedSession();
  Future<Result<void>> requestEmailOtp(String email);
  Future<Result<AuthSessionEntity>> confirmEmailOtp(String email);
  Future<Result<void>> signInWithPassword(String email, String password);
  Future<Result<OtpVerificationEntity>> signUpWithPassword(String email, String password);
  Future<Result<AuthSessionEntity>> verifySignUpOtp(String email, String code);
  Future<Result<AuthSessionEntity>> signInWithOAuth(AuthProvider provider);
  Future<List<AuthProvider>> getAvailableProviders();
  Future<Result<void>> signOut();
  Future<Result<void>> deleteAccount();
}
