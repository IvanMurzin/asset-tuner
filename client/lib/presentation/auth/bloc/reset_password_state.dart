part of 'reset_password_cubit.dart';

/// [email]: enter the address. [code]: enter the emailed code and the new password.
/// [done]: the password is changed and the user is signed in.
enum ResetPasswordStep { email, code, done }

enum ResetPasswordStatus { idle, loading }

enum ResetPasswordFieldError { invalidEmail, invalidCode, weakPassword, confirmRequired, mismatch }

@freezed
abstract class ResetPasswordState with _$ResetPasswordState {
  const factory ResetPasswordState({
    @Default(ResetPasswordStep.email) ResetPasswordStep step,
    @Default(ResetPasswordStatus.idle) ResetPasswordStatus status,
    @Default('') String email,
    @Default('') String code,
    @Default('') String password,
    @Default('') String confirmPassword,
    ResetPasswordFieldError? emailError,
    ResetPasswordFieldError? codeError,
    ResetPasswordFieldError? passwordError,
    ResetPasswordFieldError? confirmPasswordError,
    String? bannerFailureCode,
    String? bannerFailureMessage,
    @Default(false) bool isResendInProgress,
    DateTime? resendCooldownUntil,
    @Default(false) bool resendSuccess,
  }) = _ResetPasswordState;
}
