import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/sign_up_result_entity.dart';

/// Failure code for an OAuth sign-in the user abandoned in the browser; not an error to show.
const oAuthCancelledCode = 'oauth_cancelled';

abstract interface class IAuthRepository {
  Stream<AuthSessionEntity?> watchSession();
  Future<AuthSessionEntity?> getCachedSession();
  Future<Result<void>> resendSignUpOtp(String email);
  Future<Result<void>> signInWithPassword(String email, String password);
  Future<Result<SignUpResultEntity>> signUpWithPassword(String email, String password);
  Future<Result<AuthSessionEntity>> verifySignUpOtp(String email, String code);
  Future<Result<void>> requestPasswordReset(String email);
  Future<Result<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<Result<AuthSessionEntity>> signInWithOAuth(AuthProvider provider);
  Future<List<AuthProvider>> getAvailableProviders();
  Future<Result<void>> signOut();
  Future<Result<void>> deleteAccount();
}
