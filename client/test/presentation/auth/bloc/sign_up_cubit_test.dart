import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/get_auth_providers_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/oauth_sign_in_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/sign_up_with_password_usecase.dart';
import 'package:asset_tuner/presentation/auth/bloc/sign_up_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignUpCubit.submit routing', () {
    late _FakeAuthRepository repository;
    late SignUpWithPasswordUseCase signUpUseCase;
    late OAuthSignInUseCase oAuthUseCase;
    late GetAuthProvidersUseCase providersUseCase;
    late AppAnalytics analytics;

    setUp(() {
      repository = _FakeAuthRepository();
      signUpUseCase = SignUpWithPasswordUseCase(repository);
      oAuthUseCase = OAuthSignInUseCase(repository);
      providersUseCase = GetAuthProvidersUseCase(repository);
      analytics = AppAnalytics();
    });

    test('emits OTP navigation when OTP is enabled', () async {
      final cubit = SignUpCubit.testing(
        signUpUseCase,
        oAuthUseCase,
        providersUseCase,
        analytics,
        isOtpEnabled: true,
      );
      cubit.updateEmail('user@example.com');
      cubit.updatePassword('Password123!');
      cubit.updateConfirmPassword('Password123!');

      await cubit.submit();

      expect(cubit.state.status, SignUpStatus.otpSent);
      expect(cubit.state.otpEmail, 'user@example.com');
      expect(cubit.state.bannerType, SignUpBannerType.success);
      await cubit.close();
    });

    test('skips OTP navigation when OTP is disabled', () async {
      final cubit = SignUpCubit.testing(
        signUpUseCase,
        oAuthUseCase,
        providersUseCase,
        analytics,
        isOtpEnabled: false,
      );
      cubit.updateEmail('user@example.com');
      cubit.updatePassword('Password123!');
      cubit.updateConfirmPassword('Password123!');

      await cubit.submit();

      expect(cubit.state.status, SignUpStatus.idle);
      expect(cubit.state.otpEmail, isNull);
      expect(cubit.state.bannerType, isNull);
      await cubit.close();
    });
  });
}

class _FakeAuthRepository implements IAuthRepository {
  @override
  Future<Result<OtpVerificationEntity>> signUpWithPassword(String email, String password) async {
    return Success(OtpVerificationEntity(email: email));
  }

  @override
  Stream<AuthSessionEntity?> watchSession() => const Stream.empty();

  @override
  Future<AuthSessionEntity?> getCachedSession() async => null;

  @override
  Future<Result<void>> resendSignUpOtp(String email) async => const Success(null);

  @override
  Future<Result<void>> signInWithPassword(String email, String password) async =>
      const Success(null);

  @override
  Future<Result<AuthSessionEntity>> verifySignUpOtp(String email, String code) async =>
      const FailureResult(Failure(code: 'not_implemented', message: 'not implemented'));

  @override
  Future<Result<AuthSessionEntity>> signInWithOAuth(AuthProvider provider) async =>
      const FailureResult(Failure(code: 'not_implemented', message: 'not implemented'));

  @override
  Future<List<AuthProvider>> getAvailableProviders() async => const [];

  @override
  Future<Result<void>> signOut() async => const Success(null);

  @override
  Future<Result<void>> deleteAccount() async => const Success(null);
}
