import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Asset Tuner'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @designSystemPreview.
  ///
  /// In en, this message translates to:
  /// **'Design system preview'**
  String get designSystemPreview;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signInBody.
  ///
  /// In en, this message translates to:
  /// **'Track your assets across devices.'**
  String get signInBody;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpTitle;

  /// No description provided for @signUpBody.
  ///
  /// In en, this message translates to:
  /// **'Join Asset Tuner to sync your portfolio.'**
  String get signUpBody;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get confirmPasswordHint;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get otpTitle;

  /// OTP instruction with email.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to {email}.'**
  String otpBodyWithEmail(String email);

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpCodeLabel;

  /// No description provided for @otpCodeHint.
  ///
  /// In en, this message translates to:
  /// **'123456'**
  String get otpCodeHint;

  /// No description provided for @signInPrimary.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInPrimary;

  /// No description provided for @signUpPrimary.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpPrimary;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendOtp;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signInWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get signInWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @switchToSignUp.
  ///
  /// In en, this message translates to:
  /// **'New here? Create account'**
  String get switchToSignUp;

  /// No description provided for @switchToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get switchToSignIn;

  /// No description provided for @validationInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get validationInvalidEmail;

  /// No description provided for @validationPasswordRule.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters with letters and numbers.'**
  String get validationPasswordRule;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get validationPasswordMismatch;

  /// No description provided for @validationOtpLength.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code.'**
  String get validationOtpLength;

  /// No description provided for @bannerSignInError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in.'**
  String get bannerSignInError;

  /// No description provided for @bannerSignUpError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create account.'**
  String get bannerSignUpError;

  /// No description provided for @bannerOtpError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t verify the code.'**
  String get bannerOtpError;

  /// No description provided for @bannerOtpSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get bannerOtpSuccessTitle;

  /// OTP success message with email.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to {email}.'**
  String bannerOtpSuccessBodyWithEmail(String email);

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network unavailable. Try again.'**
  String get errorNetwork;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorConflict.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get errorConflict;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait and try again.'**
  String get errorRateLimited;

  /// No description provided for @splashRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring session...'**
  String get splashRestoring;

  /// No description provided for @splashPreparingProfile.
  ///
  /// In en, this message translates to:
  /// **'Preparing your profile...'**
  String get splashPreparingProfile;

  /// No description provided for @splashErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get splashErrorTitle;

  /// No description provided for @splashRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get splashRetry;

  /// No description provided for @onboardingBaseCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your base currency'**
  String get onboardingBaseCurrencyTitle;

  /// No description provided for @onboardingBaseCurrencyBody.
  ///
  /// In en, this message translates to:
  /// **'Totals will be converted to this currency.'**
  String get onboardingBaseCurrencyBody;

  /// No description provided for @onboardingSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search currency'**
  String get onboardingSearchHint;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingUseUsd.
  ///
  /// In en, this message translates to:
  /// **'Use USD for now'**
  String get onboardingUseUsd;

  /// No description provided for @onboardingLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load currencies.'**
  String get onboardingLoadError;

  /// No description provided for @onboardingSelectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select a currency to continue.'**
  String get onboardingSelectCurrency;

  /// No description provided for @onboardingUpgradeRequired.
  ///
  /// In en, this message translates to:
  /// **'Upgrade required to select this currency.'**
  String get onboardingUpgradeRequired;

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTitle;

  /// No description provided for @overviewTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get overviewTotalLabel;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @overviewEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Overview content will appear here once accounts are added.'**
  String get overviewEmptyBody;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get paywallTitle;

  /// No description provided for @paywallHeader.
  ///
  /// In en, this message translates to:
  /// **'Unlock all currencies'**
  String get paywallHeader;

  /// No description provided for @paywallBody.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to choose any base currency.'**
  String get paywallBody;

  /// No description provided for @paywallDismiss.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get paywallDismiss;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
