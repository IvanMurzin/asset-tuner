part of 'sign_up_cubit.dart';

enum SignUpStatus { idle, loading, otpSent }

enum SignUpFieldError { invalidEmail, weakPassword, mismatch }

enum SignUpBannerType { success, failure }

@freezed
abstract class SignUpNavigation with _$SignUpNavigation {
  const factory SignUpNavigation({required String email}) = _SignUpNavigation;
}

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
    String? bannerEmail,
    @Default(SignUpStatus.idle) SignUpStatus status,
    SignUpNavigation? navigation,
  }) = _SignUpState;
}
