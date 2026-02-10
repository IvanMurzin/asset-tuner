part of 'sign_in_cubit.dart';

enum SignInStatus { idle, loading }

enum SignInFieldError { invalidEmail, weakPassword }

enum SignInDestination { onboardingBaseCurrency, overview }

@freezed
abstract class SignInNavigation with _$SignInNavigation {
  const factory SignInNavigation({required SignInDestination destination}) =
      _SignInNavigation;
}

@freezed
abstract class SignInState with _$SignInState {
  const factory SignInState({
    @Default('') String email,
    @Default('') String password,
    SignInFieldError? emailError,
    SignInFieldError? passwordError,
    String? bannerFailureCode,
    @Default([]) List<AuthProvider> availableProviders,
    @Default(SignInStatus.idle) SignInStatus status,
    SignInNavigation? navigation,
  }) = _SignInState;
}
