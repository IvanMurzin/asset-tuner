import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/sign_up_result_entity.dart';
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

    test('emits OTP navigation when the sign-up needs a code', () async {
      repository.signUpResult = (email) => SignUpResultEntity.otpRequired(email: email);
      final cubit = SignUpCubit(signUpUseCase, oAuthUseCase, providersUseCase, analytics);
      cubit.updateEmail('user@example.com');
      cubit.updatePassword('Password123!');
      cubit.updateConfirmPassword('Password123!');

      await cubit.submit();

      expect(cubit.state.status, SignUpStatus.otpSent);
      expect(cubit.state.otpEmail, 'user@example.com');
      expect(cubit.state.bannerType, SignUpBannerType.success);
      await cubit.close();
    });

    test('skips OTP navigation when the user is signed in right away', () async {
      repository.signUpResult = (_) => const SignUpResultEntity.signedIn();
      final cubit = SignUpCubit(signUpUseCase, oAuthUseCase, providersUseCase, analytics);
      cubit.updateEmail('user@example.com');
      cubit.updatePassword('Password123!');
      cubit.updateConfirmPassword('Password123!');

      await cubit.submit();

      expect(cubit.state.status, SignUpStatus.idle);
      expect(cubit.state.otpEmail, isNull);
      expect(cubit.state.bannerType, isNull);
      await cubit.close();
    });

    test('empty submit flags every field, confirm password included (QA-033)', () async {
      final cubit = SignUpCubit(signUpUseCase, oAuthUseCase, providersUseCase, analytics);

      await cubit.submit();

      expect(cubit.state.emailError, SignUpFieldError.invalidEmail);
      expect(cubit.state.passwordError, SignUpFieldError.weakPassword);
      expect(cubit.state.confirmPasswordError, SignUpFieldError.confirmRequired);
      await cubit.close();
    });

    test('a different confirmation is a mismatch', () async {
      final cubit = SignUpCubit(signUpUseCase, oAuthUseCase, providersUseCase, analytics);
      cubit.updatePassword('Password123!');
      cubit.updateConfirmPassword('Password124!');

      await cubit.submit();

      expect(cubit.state.confirmPasswordError, SignUpFieldError.mismatch);
      await cubit.close();
    });

    test('a cancelled OAuth sign-up returns to idle without a banner (QA-008)', () async {
      repository.oAuthFailureCode = oAuthCancelledCode;
      final cubit = SignUpCubit(signUpUseCase, oAuthUseCase, providersUseCase, analytics);

      await cubit.signUpWithProvider(AuthProvider.google);

      expect(cubit.state.status, SignUpStatus.idle);
      expect(cubit.state.bannerFailureCode, isNull);
      await cubit.close();
    });
  });
}

class _FakeAuthRepository implements IAuthRepository {
  SignUpResultEntity Function(String email) signUpResult = (email) =>
      SignUpResultEntity.otpRequired(email: email);
  String oAuthFailureCode = 'not_implemented';

  @override
  Future<Result<SignUpResultEntity>> signUpWithPassword(String email, String password) async {
    return Success(signUpResult(email));
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
      FailureResult(Failure(code: oAuthFailureCode, message: 'oauth failed'));

  @override
  Future<List<AuthProvider>> getAvailableProviders() async => const [];

  @override
  Future<Result<void>> signOut() async => const Success(null);

  @override
  Future<Result<void>> deleteAccount() async => const Success(null);
}
