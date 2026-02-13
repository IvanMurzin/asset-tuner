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

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do that.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get errorNotFound;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Check your input and try again.'**
  String get errorValidation;

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

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

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

  /// No description provided for @mainTitle.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get mainTitle;

  /// No description provided for @mainAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get mainAddAccount;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get analyticsBreakdownTitle;

  /// No description provided for @analyticsUpdatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get analyticsUpdatesTitle;

  /// No description provided for @analyticsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No analytics yet'**
  String get analyticsEmptyTitle;

  /// No description provided for @analyticsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add accounts and balances to see breakdown and updates.'**
  String get analyticsEmptyBody;

  /// No description provided for @actionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsTitle;

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

  /// No description provided for @unpriced.
  ///
  /// In en, this message translates to:
  /// **'Unpriced'**
  String get unpriced;

  /// No description provided for @overviewEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Overview content will appear here once accounts are added.'**
  String get overviewEmptyBody;

  /// No description provided for @overviewEmptyNoAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first account'**
  String get overviewEmptyNoAccountsTitle;

  /// No description provided for @overviewEmptyNoAccountsBody.
  ///
  /// In en, this message translates to:
  /// **'Add an account to start tracking assets and totals.'**
  String get overviewEmptyNoAccountsBody;

  /// No description provided for @overviewEmptyNoAccountsCta.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get overviewEmptyNoAccountsCta;

  /// No description provided for @overviewEmptyNoAssetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first asset'**
  String get overviewEmptyNoAssetsTitle;

  /// No description provided for @overviewEmptyNoAssetsBody.
  ///
  /// In en, this message translates to:
  /// **'Add currencies or tokens you hold to an account.'**
  String get overviewEmptyNoAssetsBody;

  /// No description provided for @overviewEmptyNoAssetsCta.
  ///
  /// In en, this message translates to:
  /// **'Add asset'**
  String get overviewEmptyNoAssetsCta;

  /// No description provided for @overviewEmptyNoBalancesTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first balance'**
  String get overviewEmptyNoBalancesTitle;

  /// No description provided for @overviewEmptyNoBalancesBody.
  ///
  /// In en, this message translates to:
  /// **'Add a snapshot or change to start tracking totals.'**
  String get overviewEmptyNoBalancesBody;

  /// No description provided for @overviewEmptyNoBalancesCta.
  ///
  /// In en, this message translates to:
  /// **'Add balance'**
  String get overviewEmptyNoBalancesCta;

  /// No description provided for @overviewPricedTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Priced total'**
  String get overviewPricedTotalLabel;

  /// No description provided for @overviewMissingRatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Some holdings can’t be priced right now.'**
  String get overviewMissingRatesTitle;

  /// No description provided for @overviewMissingRatesBody.
  ///
  /// In en, this message translates to:
  /// **'Totals exclude unpriced holdings until rates are available.'**
  String get overviewMissingRatesBody;

  /// No description provided for @overviewUnpricedHoldingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unpriced holdings'**
  String get overviewUnpricedHoldingsTitle;

  /// No description provided for @overviewPartialHint.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get overviewPartialHint;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineTitle;

  /// Offline banner message with last cached timestamp.
  ///
  /// In en, this message translates to:
  /// **'Showing last saved totals from {time}.'**
  String offlineShowingLastSaved(String time);

  /// No description provided for @pullToRefreshHint.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefreshHint;

  /// Overview rates timestamp line.
  ///
  /// In en, this message translates to:
  /// **'Rates updated at {time}'**
  String overviewRatesUpdatedAt(String time);

  /// No description provided for @overviewRatesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Rates unavailable'**
  String get overviewRatesUnavailable;

  /// No description provided for @accountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsTitle;

  /// No description provided for @accountsAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get accountsAddAccount;

  /// No description provided for @accountsActiveSection.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsActiveSection;

  /// No description provided for @accountsArchivedSection.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get accountsArchivedSection;

  /// No description provided for @accountsOnlyArchivedHint.
  ///
  /// In en, this message translates to:
  /// **'Only archived accounts are shown.'**
  String get accountsOnlyArchivedHint;

  /// No description provided for @accountsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get accountsEmptyTitle;

  /// No description provided for @accountsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create an account to start tracking assets.'**
  String get accountsEmptyBody;

  /// No description provided for @accountsCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get accountsCreateAccount;

  /// No description provided for @accountsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New account'**
  String get accountsNewTitle;

  /// No description provided for @accountsEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get accountsEditTitle;

  /// No description provided for @accountsNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountsNameLabel;

  /// No description provided for @accountsNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Cash USD'**
  String get accountsNameHint;

  /// No description provided for @accountsNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get accountsNameRequired;

  /// No description provided for @accountsTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get accountsTypeLabel;

  /// No description provided for @accountsTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get accountsTypeBank;

  /// No description provided for @accountsTypeCryptoWallet.
  ///
  /// In en, this message translates to:
  /// **'Crypto wallet'**
  String get accountsTypeCryptoWallet;

  /// No description provided for @accountsTypeExchange.
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get accountsTypeExchange;

  /// No description provided for @accountsTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountsTypeCash;

  /// No description provided for @accountsTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountsTypeOther;

  /// No description provided for @accountsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get accountsEdit;

  /// No description provided for @accountsArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get accountsArchive;

  /// No description provided for @accountsUnarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get accountsUnarchive;

  /// No description provided for @accountsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get accountsDelete;

  /// No description provided for @accountsArchiveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive account?'**
  String get accountsArchiveConfirmTitle;

  /// No description provided for @accountsArchiveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This account will be hidden from totals.'**
  String get accountsArchiveConfirmBody;

  /// No description provided for @accountsUnarchiveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Unarchive account?'**
  String get accountsUnarchiveConfirmTitle;

  /// No description provided for @accountsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get accountsDeleteConfirmTitle;

  /// No description provided for @accountsDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete all assets and balance history in this account.'**
  String get accountsDeleteConfirmBody;

  /// No description provided for @accountDetailAssetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get accountDetailAssetsTitle;

  /// No description provided for @accountDetailEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No assets in this account'**
  String get accountDetailEmptyTitle;

  /// No description provided for @accountDetailEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the currencies or tokens you hold here.'**
  String get accountDetailEmptyBody;

  /// No description provided for @accountDetailArchivedHint.
  ///
  /// In en, this message translates to:
  /// **'Archived — hidden from totals by default.'**
  String get accountDetailArchivedHint;

  /// No description provided for @accountDetailTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get accountDetailTotalLabel;

  /// No description provided for @accountDetailMissingRatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Some assets can’t be priced right now.'**
  String get accountDetailMissingRatesTitle;

  /// No description provided for @accountDetailMissingRatesBody.
  ///
  /// In en, this message translates to:
  /// **'Unpriced assets are excluded from the priced total.'**
  String get accountDetailMissingRatesBody;

  /// No description provided for @assetAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add asset'**
  String get assetAddTitle;

  /// No description provided for @assetSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by code or name'**
  String get assetSearchHint;

  /// No description provided for @assetAddCta.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get assetAddCta;

  /// No description provided for @assetDuplicateError.
  ///
  /// In en, this message translates to:
  /// **'This asset is already in the account.'**
  String get assetDuplicateError;

  /// No description provided for @assetNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get assetNoMatchesTitle;

  /// No description provided for @assetNoMatchesBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different search.'**
  String get assetNoMatchesBody;

  /// No description provided for @assetPaywallHint.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to add more tracked assets.'**
  String get assetPaywallHint;

  /// No description provided for @assetAlreadyAddedLabel.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get assetAlreadyAddedLabel;

  /// No description provided for @assetKindFiat.
  ///
  /// In en, this message translates to:
  /// **'Fiat'**
  String get assetKindFiat;

  /// No description provided for @assetKindCrypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get assetKindCrypto;

  /// No description provided for @subaccountsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'subaccounts'**
  String get subaccountsCountLabel;

  /// No description provided for @subaccountCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Add subaccount'**
  String get subaccountCreateTitle;

  /// No description provided for @subaccountCreateCta.
  ///
  /// In en, this message translates to:
  /// **'Add subaccount'**
  String get subaccountCreateCta;

  /// No description provided for @subaccountCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get subaccountCurrencyLabel;

  /// No description provided for @subaccountNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., USDT (TRC20)'**
  String get subaccountNameHint;

  /// No description provided for @subaccountEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No subaccounts yet'**
  String get subaccountEmptyTitle;

  /// No description provided for @subaccountEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the holdings you have in this account.'**
  String get subaccountEmptyBody;

  /// No description provided for @subaccountListTitle.
  ///
  /// In en, this message translates to:
  /// **'Subaccounts'**
  String get subaccountListTitle;

  /// No description provided for @subaccountUpdateBalanceCta.
  ///
  /// In en, this message translates to:
  /// **'Update balance'**
  String get subaccountUpdateBalanceCta;

  /// No description provided for @subaccountRenameCta.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get subaccountRenameCta;

  /// No description provided for @subaccountRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename subaccount'**
  String get subaccountRenameTitle;

  /// No description provided for @subaccountDeleteCta.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get subaccountDeleteCta;

  /// No description provided for @subaccountDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete subaccount?'**
  String get subaccountDeleteConfirmTitle;

  /// No description provided for @subaccountDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete its balance history.'**
  String get subaccountDeleteConfirmBody;

  /// No description provided for @assetRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get assetRemove;

  /// No description provided for @assetRemoveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove asset?'**
  String get assetRemoveConfirmTitle;

  /// No description provided for @assetRemoveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove the asset and delete its balance history.'**
  String get assetRemoveConfirmBody;

  /// No description provided for @positionCurrentBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get positionCurrentBalanceLabel;

  /// No description provided for @positionConvertedValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get positionConvertedValueLabel;

  /// No description provided for @positionUnpricedHint.
  ///
  /// In en, this message translates to:
  /// **'Converted value isn’t available until rates are updated.'**
  String get positionUnpricedHint;

  /// No description provided for @positionAddBalance.
  ///
  /// In en, this message translates to:
  /// **'Add balance'**
  String get positionAddBalance;

  /// No description provided for @positionUpdateThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Update for this month'**
  String get positionUpdateThisMonth;

  /// No description provided for @positionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get positionHistoryTitle;

  /// No description provided for @positionHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No balance history yet'**
  String get positionHistoryEmptyTitle;

  /// No description provided for @positionHistoryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a snapshot or change to start tracking.'**
  String get positionHistoryEmptyBody;

  /// No description provided for @positionHistoryEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Add your first balance'**
  String get positionHistoryEmptyCta;

  /// No description provided for @positionLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get positionLoadMore;

  /// No description provided for @balanceEntrySnapshot.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get balanceEntrySnapshot;

  /// No description provided for @balanceEntryDelta.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get balanceEntryDelta;

  /// No description provided for @balanceEntryImpliedDeltaLabel.
  ///
  /// In en, this message translates to:
  /// **'Implied change'**
  String get balanceEntryImpliedDeltaLabel;

  /// No description provided for @addBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add balance'**
  String get addBalanceTitle;

  /// No description provided for @addBalanceEntryTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Entry type'**
  String get addBalanceEntryTypeLabel;

  /// No description provided for @addBalanceTypeSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get addBalanceTypeSnapshot;

  /// No description provided for @addBalanceTypeDelta.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get addBalanceTypeDelta;

  /// No description provided for @addBalanceDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get addBalanceDateLabel;

  /// No description provided for @addBalanceAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get addBalanceAmountLabel;

  /// No description provided for @addBalanceHelperSnapshot.
  ///
  /// In en, this message translates to:
  /// **'A snapshot is your balance on that date.'**
  String get addBalanceHelperSnapshot;

  /// No description provided for @addBalanceHelperDelta.
  ///
  /// In en, this message translates to:
  /// **'A change is how much it increased or decreased.'**
  String get addBalanceHelperDelta;

  /// No description provided for @addBalanceValidationAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get addBalanceValidationAmount;

  /// No description provided for @addBalanceValidationDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get addBalanceValidationDate;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get paywallTitle;

  /// No description provided for @paywallHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get paywallHeaderTitle;

  /// No description provided for @paywallReasonAccounts.
  ///
  /// In en, this message translates to:
  /// **'You’ve reached the free limit of 5 accounts.'**
  String get paywallReasonAccounts;

  /// No description provided for @paywallReasonSubaccounts.
  ///
  /// In en, this message translates to:
  /// **'You’ve reached the free limit of 20 subaccounts.'**
  String get paywallReasonSubaccounts;

  /// No description provided for @paywallReasonBaseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Unlock any base currency.'**
  String get paywallReasonBaseCurrency;

  /// No description provided for @paywallEntitlementsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t verify subscription; try again.'**
  String get paywallEntitlementsError;

  /// No description provided for @paywallDismiss.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get paywallDismiss;

  /// No description provided for @paywallIncludesTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s included'**
  String get paywallIncludesTitle;

  /// No description provided for @paywallFeatureAccounts.
  ///
  /// In en, this message translates to:
  /// **'More accounts'**
  String get paywallFeatureAccounts;

  /// No description provided for @paywallFeatureSubaccounts.
  ///
  /// In en, this message translates to:
  /// **'More subaccounts'**
  String get paywallFeatureSubaccounts;

  /// No description provided for @paywallFeatureCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Any base currency'**
  String get paywallFeatureCurrencies;

  /// No description provided for @paywallFeatureUpdates.
  ///
  /// In en, this message translates to:
  /// **'Subscription status updates'**
  String get paywallFeatureUpdates;

  /// No description provided for @paywallPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan'**
  String get paywallPlansTitle;

  /// No description provided for @paywallPlanMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallPlanMonthlyTitle;

  /// No description provided for @paywallPlanMonthlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get paywallPlanMonthlySubtitle;

  /// No description provided for @paywallPlanAnnualTitle.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get paywallPlanAnnualTitle;

  /// No description provided for @paywallPlanAnnualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get paywallPlanAnnualSubtitle;

  /// No description provided for @paywallPlanRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get paywallPlanRecommended;

  /// No description provided for @paywallUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get paywallUpgrade;

  /// No description provided for @paywallAlreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'You\'re already on the paid plan.'**
  String get paywallAlreadyPaid;

  /// No description provided for @dsPreviewTotalBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get dsPreviewTotalBalanceLabel;

  /// No description provided for @dsPreviewMonthlyReturnLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly return'**
  String get dsPreviewMonthlyReturnLabel;

  /// No description provided for @dsPreviewRiskScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk score'**
  String get dsPreviewRiskScoreLabel;

  /// No description provided for @dsPreviewRiskLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get dsPreviewRiskLow;

  /// No description provided for @dsPreviewSectionTypography.
  ///
  /// In en, this message translates to:
  /// **'Typography'**
  String get dsPreviewSectionTypography;

  /// No description provided for @dsPreviewTypographyH1.
  ///
  /// In en, this message translates to:
  /// **'Heading 1'**
  String get dsPreviewTypographyH1;

  /// No description provided for @dsPreviewTypographyH2.
  ///
  /// In en, this message translates to:
  /// **'Heading 2'**
  String get dsPreviewTypographyH2;

  /// No description provided for @dsPreviewTypographyH3.
  ///
  /// In en, this message translates to:
  /// **'Heading 3'**
  String get dsPreviewTypographyH3;

  /// No description provided for @dsPreviewTypographyBody.
  ///
  /// In en, this message translates to:
  /// **'Body text example'**
  String get dsPreviewTypographyBody;

  /// No description provided for @dsPreviewTypographyCaption.
  ///
  /// In en, this message translates to:
  /// **'Caption text'**
  String get dsPreviewTypographyCaption;

  /// No description provided for @dsPreviewSectionButtons.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get dsPreviewSectionButtons;

  /// No description provided for @dsPreviewButtonAddAsset.
  ///
  /// In en, this message translates to:
  /// **'Add asset'**
  String get dsPreviewButtonAddAsset;

  /// No description provided for @dsPreviewButtonSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get dsPreviewButtonSecondary;

  /// No description provided for @dsPreviewButtonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dsPreviewButtonDelete;

  /// No description provided for @dsPreviewButtonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get dsPreviewButtonLoading;

  /// No description provided for @dsPreviewSectionInputs.
  ///
  /// In en, this message translates to:
  /// **'Inputs'**
  String get dsPreviewSectionInputs;

  /// No description provided for @dsPreviewInputAccountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get dsPreviewInputAccountNameLabel;

  /// No description provided for @dsPreviewInputAccountNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Cash USD'**
  String get dsPreviewInputAccountNameHint;

  /// No description provided for @dsPreviewInputAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get dsPreviewInputAmountLabel;

  /// No description provided for @dsPreviewSectionCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get dsPreviewSectionCards;

  /// No description provided for @dsPreviewCardPortfolioTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio snapshot'**
  String get dsPreviewCardPortfolioTitle;

  /// No description provided for @dsPreviewCardPortfolioBody.
  ///
  /// In en, this message translates to:
  /// **'Diversified across 6 accounts and 19 assets.'**
  String get dsPreviewCardPortfolioBody;

  /// No description provided for @dsPreviewCardViewReport.
  ///
  /// In en, this message translates to:
  /// **'View report'**
  String get dsPreviewCardViewReport;

  /// No description provided for @dsPreviewCardRebalance.
  ///
  /// In en, this message translates to:
  /// **'Rebalance'**
  String get dsPreviewCardRebalance;

  /// No description provided for @dsPreviewSectionListItems.
  ///
  /// In en, this message translates to:
  /// **'List items'**
  String get dsPreviewSectionListItems;

  /// No description provided for @dsPreviewListCheckingTitle.
  ///
  /// In en, this message translates to:
  /// **'Checking account'**
  String get dsPreviewListCheckingTitle;

  /// No description provided for @dsPreviewListBankSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get dsPreviewListBankSubtitle;

  /// No description provided for @dsPreviewListBrokerageTitle.
  ///
  /// In en, this message translates to:
  /// **'Brokerage'**
  String get dsPreviewListBrokerageTitle;

  /// No description provided for @dsPreviewListInvestmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get dsPreviewListInvestmentSubtitle;

  /// No description provided for @dsPreviewListCashWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash wallet'**
  String get dsPreviewListCashWalletTitle;

  /// No description provided for @dsPreviewListCashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get dsPreviewListCashSubtitle;

  /// No description provided for @dsPreviewSectionDialogs.
  ///
  /// In en, this message translates to:
  /// **'Dialogs'**
  String get dsPreviewSectionDialogs;

  /// No description provided for @dsPreviewDialogShowButton.
  ///
  /// In en, this message translates to:
  /// **'Show dialog'**
  String get dsPreviewDialogShowButton;

  /// No description provided for @dsPreviewDialogDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get dsPreviewDialogDeleteAccountTitle;

  /// No description provided for @dsPreviewDialogDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get dsPreviewDialogDeleteAccountBody;

  /// No description provided for @dsPreviewDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dsPreviewDialogCancel;

  /// No description provided for @dsPreviewSectionLoaders.
  ///
  /// In en, this message translates to:
  /// **'Loaders'**
  String get dsPreviewSectionLoaders;

  /// No description provided for @dsPreviewSectionShimmers.
  ///
  /// In en, this message translates to:
  /// **'Shimmers'**
  String get dsPreviewSectionShimmers;

  /// No description provided for @dsPreviewSectionStates.
  ///
  /// In en, this message translates to:
  /// **'States'**
  String get dsPreviewSectionStates;

  /// No description provided for @dsPreviewStateEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No accounts'**
  String get dsPreviewStateEmptyTitle;

  /// No description provided for @dsPreviewStateEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create your first account to get started.'**
  String get dsPreviewStateEmptyBody;

  /// No description provided for @dsPreviewStateEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get dsPreviewStateEmptyAction;

  /// No description provided for @dsPreviewStateErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get dsPreviewStateErrorTitle;

  /// No description provided for @dsPreviewStateErrorBody.
  ///
  /// In en, this message translates to:
  /// **'We could not load your data. Try again.'**
  String get dsPreviewStateErrorBody;

  /// Monthly performance badge in design system preview.
  ///
  /// In en, this message translates to:
  /// **'{percent} this month'**
  String dsPreviewPercentThisMonth(String percent);

  /// Timestamp label in design system preview.
  ///
  /// In en, this message translates to:
  /// **'Updated at {timestamp}'**
  String dsPreviewUpdatedAt(String timestamp);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsSectionPreferences;

  /// No description provided for @settingsBaseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Base currency'**
  String get settingsBaseCurrency;

  /// No description provided for @settingsSectionSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingsSectionSubscription;

  /// No description provided for @settingsPlanStatus.
  ///
  /// In en, this message translates to:
  /// **'Plan status'**
  String get settingsPlanStatus;

  /// No description provided for @settingsPlanFree.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get settingsPlanFree;

  /// No description provided for @settingsPlanPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid plan'**
  String get settingsPlanPaid;

  /// No description provided for @settingsManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get settingsManageSubscription;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsEntitlementsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t verify subscription status.'**
  String get settingsEntitlementsError;

  /// No description provided for @baseCurrencySettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Base currency'**
  String get baseCurrencySettingsTitle;

  /// No description provided for @baseCurrencySettingsCurrentTitle.
  ///
  /// In en, this message translates to:
  /// **'Current selection'**
  String get baseCurrencySettingsCurrentTitle;

  /// No description provided for @baseCurrencySettingsCurrentBody.
  ///
  /// In en, this message translates to:
  /// **'Totals will be converted to this currency.'**
  String get baseCurrencySettingsCurrentBody;

  /// No description provided for @baseCurrencySettingsPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose currency'**
  String get baseCurrencySettingsPickerTitle;

  /// No description provided for @baseCurrencySettingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get baseCurrencySettingsSave;

  /// No description provided for @baseCurrencySettingsLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load currencies.'**
  String get baseCurrencySettingsLoadErrorTitle;

  /// No description provided for @baseCurrencySettingsPaywallHint.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock more base currencies.'**
  String get baseCurrencySettingsPaywallHint;

  /// No description provided for @baseCurrencySettingsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search currency'**
  String get baseCurrencySettingsSearchHint;

  /// No description provided for @baseCurrencySettingsBrowseAll.
  ///
  /// In en, this message translates to:
  /// **'Browse all currencies'**
  String get baseCurrencySettingsBrowseAll;

  /// No description provided for @baseCurrencySettingsSearchTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: type at least 2 characters to search. Popular currencies are shown by default.'**
  String get baseCurrencySettingsSearchTip;

  /// No description provided for @baseCurrencySettingsResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Showing a limited set of results. Refine your search to find more.'**
  String get baseCurrencySettingsResultsHint;

  /// No description provided for @currencyPickerRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get currencyPickerRecentTitle;

  /// No description provided for @currencyPickerSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get currencyPickerSelectedTitle;

  /// No description provided for @currencyPickerChangeAction.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get currencyPickerChangeAction;

  /// No description provided for @currencyPickerNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No currencies found'**
  String get currencyPickerNoResultsTitle;

  /// No description provided for @currencyPickerNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try another code or name.'**
  String get currencyPickerNoResultsBody;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get subscriptionStatusTitle;

  /// No description provided for @subscriptionManage.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get subscriptionManage;

  /// No description provided for @subscriptionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get subscriptionRestore;

  /// No description provided for @subscriptionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription'**
  String get subscriptionCancel;

  /// No description provided for @subscriptionUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to paid'**
  String get subscriptionUpgrade;

  /// No description provided for @subscriptionFreeBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the free plan. Upgrade to unlock all base currencies.'**
  String get subscriptionFreeBody;

  /// No description provided for @subscriptionPaidBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the paid plan. Thanks for supporting Asset Tuner.'**
  String get subscriptionPaidBody;

  /// No description provided for @subscriptionPlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Subscription management will be available in a future update.'**
  String get subscriptionPlaceholderBody;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileSectionPreferences;

  /// No description provided for @profileSectionPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get profileSectionPortfolio;

  /// No description provided for @profileAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get profileAccounts;

  /// No description provided for @settingsArchivedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Archived accounts'**
  String get settingsArchivedAccounts;

  /// No description provided for @archivedAccountsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No archived accounts'**
  String get archivedAccountsEmptyTitle;

  /// No description provided for @archivedAccountsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Accounts you archive will appear here.'**
  String get archivedAccountsEmptyBody;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileLanguageSystem;

  /// No description provided for @profileLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEnglish;

  /// No description provided for @profileLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get profileLanguageRussian;

  /// No description provided for @profileTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profileTheme;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// No description provided for @profileAccountActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account actions'**
  String get profileAccountActionsTitle;

  /// No description provided for @profileAccountActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out or delete account'**
  String get profileAccountActionsSubtitle;

  /// No description provided for @profileDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccountTitle;

  /// No description provided for @profileDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove your local data and sign you out.'**
  String get profileDeleteAccountBody;

  /// No description provided for @profileDeleteAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccountCta;

  /// No description provided for @profileDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get profileDeleteConfirmTitle;

  /// No description provided for @profileDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get profileDeleteConfirmBody;

  /// No description provided for @profileDeleteConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDeleteConfirmCta;

  /// No description provided for @profileDeleteConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileDeleteConfirmCancel;

  /// Profile header subtitle showing plan and base currency.
  ///
  /// In en, this message translates to:
  /// **'{plan} · Base currency: {currency}'**
  String profileHeaderSubtitle(String plan, String currency);

  /// No description provided for @subscriptionManageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription status updated.'**
  String get subscriptionManageSuccess;

  /// No description provided for @subscriptionRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored.'**
  String get subscriptionRestoreSuccess;

  /// No description provided for @subscriptionCancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription canceled.'**
  String get subscriptionCancelSuccess;
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
