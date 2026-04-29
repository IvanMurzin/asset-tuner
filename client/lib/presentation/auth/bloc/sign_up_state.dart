part of 'sign_up_cubit.dart';

enum SignUpStatus { idle, loading, otpSent }

enum SignUpFieldError { invalidEmail, weakPassword, mismatch }

enum SignUpBannerType { success, failure }

@freezed
abstract class SignUpState with _$SignUpState {
  const factory SignUpState({
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,
    SignUpFieldError? emailError,
    SignUpFieldError? passwordError,
    SignUpFieldError? confirmPasswordError,
    SignUpBannerType? bannerType,
    String? bannerFailureCode,
    String? bannerFailureMessage,
    String? bannerEmail,
    String? otpEmail,
    @Default([]) List<AuthProvider> availableProviders,
    @Default(SignUpStatus.idle) SignUpStatus status,
  }) = _SignUpState;
}
