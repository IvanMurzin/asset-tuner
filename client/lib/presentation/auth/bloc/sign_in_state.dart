part of 'sign_in_cubit.dart';

enum SignInStatus { idle, loading }

enum SignInFieldError { invalidEmail, weakPassword }

@freezed
abstract class SignInState with _$SignInState {
  const factory SignInState({
    @Default('') String email,
    @Default('') String password,
    SignInFieldError? emailError,
    SignInFieldError? passwordError,
    String? bannerFailureCode,
    String? bannerFailureMessage,
    @Default([]) List<AuthProvider> availableProviders,
    @Default(SignInStatus.idle) SignInStatus status,
  }) = _SignInState;
}
