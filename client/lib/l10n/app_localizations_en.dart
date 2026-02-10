// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Asset Tuner';

  @override
  String get homeTitle => 'Home';

  @override
  String get designSystemPreview => 'Design system preview';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInBody => 'Track your assets across devices.';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get signUpBody => 'Join Asset Tuner to sync your portfolio.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'At least 6 characters';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Re-enter password';

  @override
  String get otpTitle => 'Verify your email';

  @override
  String otpBodyWithEmail(String email) {
    return 'Enter the 6-digit code we sent to $email.';
  }

  @override
  String get otpCodeLabel => 'Verification code';

  @override
  String get otpCodeHint => '123456';

  @override
  String get signInPrimary => 'Sign in';

  @override
  String get signUpPrimary => 'Create account';

  @override
  String get sendOtp => 'Send code';

  @override
  String get verifyOtp => 'Verify';

  @override
  String get resendOtp => 'Resend';

  @override
  String get changeEmail => 'Change email';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signInWith => 'Or continue with';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get switchToSignUp => 'New here? Create account';

  @override
  String get switchToSignIn => 'Already have an account? Sign in';

  @override
  String get validationInvalidEmail => 'Enter a valid email.';

  @override
  String get validationPasswordRule =>
      'Use at least 6 characters with letters and numbers.';

  @override
  String get validationPasswordMismatch => 'Passwords do not match.';

  @override
  String get validationOtpLength => 'Enter the 6-digit code.';

  @override
  String get bannerSignInError => 'Couldn\'t sign in.';

  @override
  String get bannerSignUpError => 'Couldn\'t create account.';

  @override
  String get bannerOtpError => 'Couldn\'t verify the code.';

  @override
  String get bannerOtpSuccessTitle => 'Check your email';

  @override
  String bannerOtpSuccessBodyWithEmail(String email) {
    return 'We sent a verification code to $email.';
  }

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get errorNetwork => 'Network unavailable. Try again.';

  @override
  String get errorUnauthorized => 'Session expired. Please sign in again.';

  @override
  String get errorConflict => 'This email is already in use.';

  @override
  String get errorRateLimited =>
      'Too many attempts. Please wait and try again.';

  @override
  String get splashRestoring => 'Restoring session...';

  @override
  String get splashPreparingProfile => 'Preparing your profile...';

  @override
  String get splashErrorTitle => 'Something went wrong.';

  @override
  String get splashRetry => 'Try again';

  @override
  String get onboardingBaseCurrencyTitle => 'Choose your base currency';

  @override
  String get onboardingBaseCurrencyBody =>
      'Totals will be converted to this currency.';

  @override
  String get onboardingSearchHint => 'Search currency';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingUseUsd => 'Use USD for now';

  @override
  String get onboardingLoadError => 'Couldn\'t load currencies.';

  @override
  String get onboardingSelectCurrency => 'Select a currency to continue.';

  @override
  String get onboardingUpgradeRequired =>
      'Upgrade required to select this currency.';

  @override
  String get overviewTitle => 'Overview';

  @override
  String get overviewTotalLabel => 'Total';

  @override
  String get notAvailable => 'N/A';

  @override
  String get overviewEmptyBody =>
      'Overview content will appear here once accounts are added.';

  @override
  String get paywallTitle => 'Upgrade';

  @override
  String get paywallHeader => 'Unlock all currencies';

  @override
  String get paywallBody => 'Upgrade to choose any base currency.';

  @override
  String get paywallDismiss => 'Not now';
}
