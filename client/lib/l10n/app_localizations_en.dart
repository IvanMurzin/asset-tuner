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
  String get otpResendSuccess => 'Code sent';

  @override
  String otpResendCooldown(int seconds) {
    return 'Resend in ${seconds}s';
  }

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
  String get validationPasswordRule => 'Use at least 6 characters with letters and numbers.';

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
  String get errorForbidden => 'You don\'t have permission to do that.';

  @override
  String get errorNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get errorValidation => 'Check your input and try again.';

  @override
  String get errorConflict => 'This email is already in use.';

  @override
  String get errorRateLimited => 'Too many attempts. Please wait and try again.';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

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
  String get onboardingBaseCurrencyBody => 'Totals will be converted to this currency.';

  @override
  String get baseCurrencyConversionCaption => 'Your savings will be converted to this currency.';

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
  String get onboardingUpgradeRequired => 'Upgrade required to select this currency.';

  @override
  String get onboardingCarouselTitle1 => 'See your total wealth in one currency';

  @override
  String get onboardingCarouselBody1 =>
      'Track bank accounts, cash, and crypto wallets — and always get a single global total in your base currency.';

  @override
  String get onboardingCarouselTitle2 => 'Model your real setup';

  @override
  String get onboardingCarouselBody2 =>
      'Create accounts like Bank, Wallet, Exchange, or Cash. Add multiple assets inside one account (BTC, ETH, USDT, EUR) — just like in real life.';

  @override
  String get onboardingCarouselTitle3 => 'Update balances in seconds';

  @override
  String get onboardingCarouselBody3 =>
      'Enter a quick snapshot of your balance. We highlight what changed since last time and keep totals consistent with regularly updated rates.';

  @override
  String get onboardingCarouselBody3Footnote => 'Next: sign in to sync across devices.';

  @override
  String get onboardingCarouselQuickUpdatesCaption => 'Quick balance updates';

  @override
  String get onboardingCarouselSignInCta => 'I already have an account';

  @override
  String get onboardingCarouselNext => 'Continue';

  @override
  String get onboardingCarouselGetStarted => 'Get started';

  @override
  String get onboardingCarouselSkip => 'Skip';

  @override
  String get onboardingCarouselBack => 'Back';

  @override
  String get onboardingCarouselChip1First => 'One total';

  @override
  String get onboardingCarouselChip1Second => 'Fast';

  @override
  String get onboardingCarouselChip2First => 'Any currency';

  @override
  String get onboardingCarouselChip2Second => 'Accurate rates';

  @override
  String get onboardingCarouselChip3First => 'Track changes';

  @override
  String get onboardingCarouselChip3Second => 'Simple flow';

  @override
  String get overviewTitle => 'Overview';

  @override
  String get mainTitle => 'Main';

  @override
  String get mainAddAccount => 'Add account';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get analyticsBreakdownTitle => 'Breakdown';

  @override
  String get analyticsUpdatesTitle => 'Updates';

  @override
  String get analyticsEmptyTitle => 'No analytics yet';

  @override
  String get analyticsEmptyBody => 'Add accounts and balances to see breakdown and updates.';

  @override
  String get actionsTitle => 'Actions';

  @override
  String get overviewTotalLabel => 'Total';

  @override
  String get notAvailable => 'N/A';

  @override
  String get unpriced => 'Unpriced';

  @override
  String get overviewEmptyBody => 'Overview content will appear here once accounts are added.';

  @override
  String get overviewEmptyNoAccountsTitle => 'Create your first account';

  @override
  String get overviewEmptyNoAccountsBody => 'Add an account to start tracking assets and totals.';

  @override
  String get overviewEmptyNoAccountsCta => 'Create account';

  @override
  String get overviewEmptyNoAssetsTitle => 'Add your first asset';

  @override
  String get overviewEmptyNoAssetsBody => 'Add currencies or tokens you hold to an account.';

  @override
  String get overviewEmptyNoAssetsCta => 'Add asset';

  @override
  String get overviewEmptyNoBalancesTitle => 'Add your first balance';

  @override
  String get overviewEmptyNoBalancesBody => 'Add a snapshot or change to start tracking totals.';

  @override
  String get overviewEmptyNoBalancesCta => 'Add balance';

  @override
  String get overviewPricedTotalLabel => 'Priced total';

  @override
  String get overviewMissingRatesTitle => 'Some holdings can’t be priced right now.';

  @override
  String get overviewMissingRatesBody =>
      'Totals exclude unpriced holdings until rates are available.';

  @override
  String get overviewUnpricedHoldingsTitle => 'Unpriced holdings';

  @override
  String get overviewPartialHint => 'Partial';

  @override
  String get offlineTitle => 'Offline';

  @override
  String offlineShowingLastSaved(String time) {
    return 'Showing last saved totals from $time.';
  }

  @override
  String get pullToRefreshHint => 'Pull to refresh';

  @override
  String overviewRatesUpdatedAt(String time) {
    return 'Rates updated at $time';
  }

  @override
  String get overviewRatesUnavailable => 'Rates unavailable';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get accountsAddAccount => 'Add account';

  @override
  String get accountsActiveSection => 'Accounts';

  @override
  String get accountsArchivedSection => 'Archived';

  @override
  String get accountsOnlyArchivedHint => 'Only archived accounts are shown.';

  @override
  String get accountsEmptyTitle => 'No accounts yet';

  @override
  String get accountsEmptyBody => 'Create an account to start tracking assets.';

  @override
  String get accountsCreateAccount => 'Create account';

  @override
  String get accountsNewTitle => 'New account';

  @override
  String get accountsNewBody =>
      'Give your account a name and choose the type that best fits — bank, wallet, exchange, cash, or other.';

  @override
  String get accountsEditTitle => 'Edit account';

  @override
  String get accountsNameLabel => 'Account name';

  @override
  String get accountsNameHint => 'e.g., Cash USD';

  @override
  String get accountsNameRequired => 'Name is required';

  @override
  String get accountsTypeLabel => 'Type';

  @override
  String get accountsTypeBank => 'Bank';

  @override
  String get accountsTypeCryptoWallet => 'Crypto wallet';

  @override
  String get accountsTypeExchange => 'Exchange';

  @override
  String get accountsTypeCash => 'Cash';

  @override
  String get accountsTypeOther => 'Other';

  @override
  String get accountsTypeBankDescription => 'Bank account or savings';

  @override
  String get accountsTypeCryptoWalletDescription => 'Crypto wallet or self-custody';

  @override
  String get accountsTypeExchangeDescription => 'Trading or exchange account';

  @override
  String get accountsTypeCashDescription => 'Cash on hand';

  @override
  String get accountsTypeOtherDescription => 'Other assets or custom';

  @override
  String get accountsEdit => 'Edit';

  @override
  String get accountsArchive => 'Archive';

  @override
  String get accountsUnarchive => 'Unarchive';

  @override
  String get accountsDelete => 'Delete';

  @override
  String get accountsArchiveConfirmTitle => 'Archive account?';

  @override
  String get accountsArchiveConfirmBody => 'This account will be hidden from totals.';

  @override
  String get accountsUnarchiveConfirmTitle => 'Unarchive account?';

  @override
  String get accountsDeleteConfirmTitle => 'Delete account?';

  @override
  String get accountsDeleteConfirmBody =>
      'This will delete all assets and balance history in this account.';

  @override
  String get accountDetailAssetsTitle => 'Assets';

  @override
  String get accountDetailEmptyTitle => 'No assets in this account';

  @override
  String get accountDetailEmptyBody => 'Add the currencies or tokens you hold here.';

  @override
  String get accountDetailArchivedHint => 'Archived — hidden from totals by default.';

  @override
  String get accountDetailTotalLabel => 'Total';

  @override
  String get accountDetailMissingRatesTitle => 'Some assets can’t be priced right now.';

  @override
  String get accountDetailMissingRatesBody => 'Unpriced assets are excluded from the priced total.';

  @override
  String get assetAddTitle => 'Add asset';

  @override
  String get assetSearchHint => 'Search by code or name';

  @override
  String get assetAddCta => 'Add';

  @override
  String get assetDuplicateError => 'This asset is already in the account.';

  @override
  String get assetNoMatchesTitle => 'No matches';

  @override
  String get assetNoMatchesBody => 'Try a different search.';

  @override
  String get assetPaywallHint => 'Upgrade to add more tracked assets.';

  @override
  String get assetAlreadyAddedLabel => 'Added';

  @override
  String get assetKindFiat => 'Fiat';

  @override
  String get assetKindCrypto => 'Crypto';

  @override
  String get subaccountsCountLabel => 'subaccounts';

  @override
  String get subaccountCreateTitle => 'Add subaccount';

  @override
  String get subaccountCreateCta => 'Add subaccount';

  @override
  String get subaccountCurrencyLabel => 'Currency';

  @override
  String get subaccountCurrencyRequired => 'Select a currency';

  @override
  String get subaccountNameHint => 'e.g., USDT (TRC20)';

  @override
  String get subaccountNameHintBank => 'e.g., Savings USD';

  @override
  String get subaccountNameHintWalletExchange => 'e.g., BTC spot wallet';

  @override
  String get subaccountNameHintCash => 'e.g., Cash at home';

  @override
  String get subaccountNameHintOther => 'e.g., Emergency reserve';

  @override
  String get subaccountNameHelperBank =>
      'Use the bank product or card name so this subaccount is easy to recognize.';

  @override
  String get subaccountNameHelperWalletExchange =>
      'Include network or venue in the name to separate similar crypto holdings.';

  @override
  String get subaccountNameHelperCash =>
      'Use location or purpose, for example wallet, safe, or travel cash.';

  @override
  String get subaccountNameHelperOther =>
      'Use any label that helps you quickly identify this subaccount.';

  @override
  String get subaccountAmountHelperBank =>
      'Enter the current balance for this subaccount. Value 0 is allowed.';

  @override
  String get subaccountAmountHelperWalletExchange =>
      'Enter the current amount of this asset. Value 0 is allowed.';

  @override
  String get subaccountAmountHelperCash => 'Enter cash currently on hand. Value 0 is allowed.';

  @override
  String get subaccountAmountHelperOther =>
      'Enter the current amount tracked in this subaccount. Value 0 is allowed.';

  @override
  String get subaccountEmptyTitle => 'No subaccounts yet';

  @override
  String get subaccountEmptyBody => 'Add the holdings you have in this account.';

  @override
  String get subaccountListTitle => 'Subaccounts';

  @override
  String get subaccountListCaption =>
      'Use separate subaccounts for each currency or token inside this account.';

  @override
  String get subaccountUpdateBalanceCta => 'Set balance';

  @override
  String get subaccountRenameCta => 'Rename';

  @override
  String get subaccountRenameTitle => 'Rename subaccount';

  @override
  String get subaccountDeleteCta => 'Delete';

  @override
  String get subaccountDeleteConfirmTitle => 'Delete subaccount?';

  @override
  String get subaccountDeleteConfirmBody => 'This will delete its balance history.';

  @override
  String get assetRemove => 'Remove';

  @override
  String get assetRemoveConfirmTitle => 'Remove asset?';

  @override
  String get assetRemoveConfirmBody => 'This will remove the asset and delete its balance history.';

  @override
  String get positionCurrentBalanceLabel => 'Current balance';

  @override
  String get positionConvertedValueLabel => 'Value';

  @override
  String get positionUnpricedHint => 'Converted value isn’t available until rates are updated.';

  @override
  String get positionAddBalance => 'Add balance';

  @override
  String get positionUpdateThisMonth => 'Update for this month';

  @override
  String get positionHistoryTitle => 'Your balance history';

  @override
  String get positionHistoryDescription =>
      'See how this subaccount balance changed with each snapshot update.';

  @override
  String get positionHistoryEmptyTitle => 'No balance history yet';

  @override
  String get positionHistoryEmptyBody => 'Add a snapshot or change to start tracking.';

  @override
  String get positionHistoryEmptyCta => 'Add your first balance';

  @override
  String get positionLoadMore => 'Load more';

  @override
  String get balanceEntrySnapshot => 'Snapshot';

  @override
  String get balanceEntryDelta => 'Change';

  @override
  String get balanceEntryImpliedDeltaLabel => 'Implied change';

  @override
  String get addBalanceTitle => 'Add balance';

  @override
  String get addBalanceEntryTypeLabel => 'Entry type';

  @override
  String get addBalanceTypeSnapshot => 'Snapshot';

  @override
  String get addBalanceTypeDelta => 'Change';

  @override
  String get addBalanceDateLabel => 'Date';

  @override
  String get addBalanceAmountLabel => 'Amount';

  @override
  String get addBalanceHelperSnapshot => 'Set the new current balance value for this subaccount.';

  @override
  String get addBalanceHelperDelta => 'A change is how much it increased or decreased.';

  @override
  String get addBalanceValidationAmount => 'Enter an amount';

  @override
  String get addBalanceValidationDate => 'Choose a date';

  @override
  String get paywallTitle => 'Unlock Pro';

  @override
  String get paywallHeaderTitle => 'Unlock Pro';

  @override
  String get paywallReasonAccounts => 'You’ve reached the free limit of 5 accounts.';

  @override
  String get paywallReasonSubaccounts => 'You’ve reached the free limit of 20 subaccounts.';

  @override
  String get paywallReasonBaseCurrency => 'Unlock any base currency.';

  @override
  String get paywallEntitlementsError => 'Couldn\'t verify subscription; try again.';

  @override
  String get paywallRestore => 'Restore';

  @override
  String get paywallUnlockTitle => 'Unlock Pro';

  @override
  String get paywallSubtitle => 'Go unlimited with accounts, assets, and currencies.';

  @override
  String get paywallLoadingOfferings => 'Loading subscription options...';

  @override
  String get paywallNoOfferings => 'No subscription options are available right now.';

  @override
  String get paywallDismiss => 'Not now';

  @override
  String get paywallContinue => 'Continue';

  @override
  String get paywallMostPopular => 'Most Popular';

  @override
  String get paywallFreeTitle => 'Free';

  @override
  String get paywallProTitle => 'Pro';

  @override
  String get paywallFreeFeatureAccounts => 'Up to 5 accounts';

  @override
  String get paywallFreeFeatureSubaccounts => 'Up to 15 subaccounts';

  @override
  String get paywallFreeFeatureFiat => '5 top fiat currencies';

  @override
  String get paywallFreeFeatureCrypto => '5 top crypto currencies';

  @override
  String get paywallProFeatureAccounts => 'Unlimited accounts';

  @override
  String get paywallProFeatureSubaccounts => 'Unlimited subaccounts';

  @override
  String get paywallProFeatureFiat => '100+ fiat currencies';

  @override
  String get paywallProFeatureCrypto => '100+ crypto currencies';

  @override
  String get paywallLegalPrefix => 'Cancel anytime. Payment will be charged to your store account.';

  @override
  String get paywallLegalTerms => 'Terms';

  @override
  String get paywallLegalPrivacy => 'Privacy';

  @override
  String paywallMonthlyPrice(String price) {
    return 'Monthly: $price / month';
  }

  @override
  String paywallYearlyPrice(String price) {
    return 'Yearly: $price / year';
  }

  @override
  String get paywallIncludesTitle => 'What\'s included';

  @override
  String get paywallFeatureAccounts => 'More accounts';

  @override
  String get paywallFeatureSubaccounts => 'More subaccounts';

  @override
  String get paywallFeatureCurrencies => 'Any base currency';

  @override
  String get paywallFeatureUpdates => 'Subscription status updates';

  @override
  String get paywallPlansTitle => 'Choose a plan';

  @override
  String get paywallPlanMonthlyTitle => 'Monthly';

  @override
  String get paywallPlanMonthlySubtitle => 'Cancel anytime';

  @override
  String get paywallPlanAnnualTitle => 'Annual';

  @override
  String get paywallPlanAnnualSubtitle => 'Best value';

  @override
  String get paywallPlanRecommended => 'Recommended';

  @override
  String get paywallUpgrade => 'Upgrade';

  @override
  String get paywallAlreadyPaid => 'You\'re already on the pro plan.';

  @override
  String get dsPreviewTotalBalanceLabel => 'Total balance';

  @override
  String get dsPreviewMonthlyReturnLabel => 'Monthly return';

  @override
  String get dsPreviewRiskScoreLabel => 'Risk score';

  @override
  String get dsPreviewRiskLow => 'Low';

  @override
  String get dsPreviewSectionTypography => 'Typography';

  @override
  String get dsPreviewTypographyH1 => 'Heading 1';

  @override
  String get dsPreviewTypographyH2 => 'Heading 2';

  @override
  String get dsPreviewTypographyH3 => 'Heading 3';

  @override
  String get dsPreviewTypographyBody => 'Body text example';

  @override
  String get dsPreviewTypographyCaption => 'Caption text';

  @override
  String get dsPreviewSectionButtons => 'Buttons';

  @override
  String get dsPreviewButtonAddAsset => 'Add asset';

  @override
  String get dsPreviewButtonSecondary => 'Secondary';

  @override
  String get dsPreviewButtonDelete => 'Delete';

  @override
  String get dsPreviewButtonLoading => 'Loading';

  @override
  String get dsPreviewSectionInputs => 'Inputs';

  @override
  String get dsPreviewInputAccountNameLabel => 'Account name';

  @override
  String get dsPreviewInputAccountNameHint => 'e.g., Cash USD';

  @override
  String get dsPreviewInputAmountLabel => 'Amount';

  @override
  String get dsPreviewSectionCards => 'Cards';

  @override
  String get dsPreviewCardPortfolioTitle => 'Portfolio snapshot';

  @override
  String get dsPreviewCardPortfolioBody => 'Diversified across 6 accounts and 19 assets.';

  @override
  String get dsPreviewCardViewReport => 'View report';

  @override
  String get dsPreviewCardRebalance => 'Rebalance';

  @override
  String get dsPreviewSectionListItems => 'List items';

  @override
  String get dsPreviewListCheckingTitle => 'Checking account';

  @override
  String get dsPreviewListBankSubtitle => 'Bank';

  @override
  String get dsPreviewListBrokerageTitle => 'Brokerage';

  @override
  String get dsPreviewListInvestmentSubtitle => 'Investment';

  @override
  String get dsPreviewListCashWalletTitle => 'Cash wallet';

  @override
  String get dsPreviewListCashSubtitle => 'Cash';

  @override
  String get dsPreviewSectionDialogs => 'Dialogs';

  @override
  String get dsPreviewDialogShowButton => 'Show dialog';

  @override
  String get dsPreviewDialogDeleteAccountTitle => 'Delete account';

  @override
  String get dsPreviewDialogDeleteAccountBody => 'This action cannot be undone.';

  @override
  String get dsPreviewDialogCancel => 'Cancel';

  @override
  String get dsPreviewSectionLoaders => 'Loaders';

  @override
  String get dsPreviewSectionShimmers => 'Shimmers';

  @override
  String get dsPreviewSectionStates => 'States';

  @override
  String get dsPreviewStateEmptyTitle => 'No accounts';

  @override
  String get dsPreviewStateEmptyBody => 'Create your first account to get started.';

  @override
  String get dsPreviewStateEmptyAction => 'Create account';

  @override
  String get dsPreviewStateErrorTitle => 'Something went wrong';

  @override
  String get dsPreviewStateErrorBody => 'We could not load your data. Try again.';

  @override
  String dsPreviewPercentThisMonth(String percent) {
    return '$percent this month';
  }

  @override
  String dsPreviewUpdatedAt(String timestamp) {
    return 'Updated at $timestamp';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionPreferences => 'Preferences';

  @override
  String get settingsBaseCurrency => 'Base currency';

  @override
  String get settingsSectionSubscription => 'Subscription';

  @override
  String get settingsPlanStatus => 'Plan status';

  @override
  String get settingsPlanFree => 'Free plan';

  @override
  String get settingsPlanPaid => 'Pro plan';

  @override
  String get settingsManageSubscription => 'Manage subscription';

  @override
  String get profileUpgradePlan => 'Upgrade plan';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsEntitlementsError => 'Couldn\'t verify subscription status.';

  @override
  String get baseCurrencySettingsTitle => 'Base currency';

  @override
  String get baseCurrencySettingsCurrentTitle => 'Your base currency';

  @override
  String get baseCurrencySettingsCurrentBody => 'All totals are converted to this currency.';

  @override
  String get baseCurrencySettingsPickerTitle => 'Choose currency';

  @override
  String get baseCurrencySettingsSave => 'Save';

  @override
  String get baseCurrencySettingsLoadErrorTitle => 'Couldn\'t load currencies.';

  @override
  String get baseCurrencySettingsPaywallHint => 'Upgrade to unlock more base currencies.';

  @override
  String get baseCurrencySettingsSearchHint => 'Search currency';

  @override
  String get baseCurrencySettingsBrowseAll => 'Browse all currencies';

  @override
  String get baseCurrencySettingsSearchTip =>
      'Tip: type at least 2 characters to search. Popular currencies are shown by default.';

  @override
  String get baseCurrencySettingsResultsHint =>
      'Showing a limited set of results. Refine your search to find more.';

  @override
  String get currencyPickerRecentTitle => 'Recent';

  @override
  String get currencyPickerSelectedTitle => 'Selected';

  @override
  String get currencyPickerChangeAction => 'Change';

  @override
  String get currencyPickerNoResultsTitle => 'No currencies found';

  @override
  String get currencyPickerNoResultsBody => 'Try another code or name.';

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String get subscriptionStatusTitle => 'Status';

  @override
  String get subscriptionManage => 'Manage subscription';

  @override
  String get subscriptionRestore => 'Restore purchases';

  @override
  String get subscriptionCancel => 'Cancel subscription';

  @override
  String get subscriptionUpgrade => 'Upgrade to pro';

  @override
  String get subscriptionFreeBody =>
      'You\'re on the free plan. Upgrade to unlock all base currencies.';

  @override
  String get subscriptionPaidBody => 'You\'re on the pro plan. Thanks for supporting Asset Tuner.';

  @override
  String get subscriptionPlaceholderBody =>
      'Subscription management will be available in a future update.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSectionPreferences => 'Preferences';

  @override
  String get profileSectionPortfolio => 'Portfolio';

  @override
  String get profileAccounts => 'Accounts';

  @override
  String get settingsArchivedAccounts => 'Archived accounts';

  @override
  String get archivedAccountsGlobalTotalHint =>
      'Archived accounts are excluded from your global total.';

  @override
  String get archivedAccountsEmptyTitle => 'No archived accounts';

  @override
  String get archivedAccountsEmptyBody => 'Accounts you archive will appear here.';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageSystem => 'System';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageRussian => 'Russian';

  @override
  String get profileTheme => 'Theme';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileSectionAccount => 'Account';

  @override
  String get profileAccountActionsTitle => 'Account actions';

  @override
  String get profileAccountActionsSubtitle => 'Sign out or delete account';

  @override
  String get profileDeleteAccountTitle => 'Delete account';

  @override
  String get profileDeleteAccountBody => 'This will remove your local data and sign you out.';

  @override
  String get profileDeleteAccountCta => 'Delete account';

  @override
  String get profileDeleteConfirmTitle => 'Delete account?';

  @override
  String get profileDeleteConfirmBody => 'This action cannot be undone.';

  @override
  String get profileDeleteConfirmCta => 'Delete';

  @override
  String get profileDeleteConfirmCancel => 'Cancel';

  @override
  String profileHeaderSubtitle(String plan, String currency) {
    return '$plan · Base currency: $currency';
  }

  @override
  String profileHeaderCurrencyLabel(String currency) {
    return 'Base currency: $currency';
  }

  @override
  String get subscriptionManageSuccess => 'Subscription status updated.';

  @override
  String get subscriptionRestoreSuccess => 'Purchases restored.';

  @override
  String get subscriptionCancelSuccess => 'Subscription canceled.';

  @override
  String get guidedTourSkip => 'Skip';

  @override
  String get guidedTourNext => 'Next';

  @override
  String get guidedTourFinish => 'Finish';

  @override
  String guidedTourProgress(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get guidedTourOverviewStep1Title => 'Portfolio total';

  @override
  String get guidedTourOverviewStep1Body =>
      'This card shows your total value in the selected base currency.';

  @override
  String get guidedTourOverviewStep2Title => 'Create an account';

  @override
  String get guidedTourOverviewStep2Body =>
      'Tap here to add a bank, wallet, exchange, cash, or custom account.';

  @override
  String get guidedTourOverviewStep3Title => 'Refresh data';

  @override
  String get guidedTourOverviewStep3Body =>
      'Pull down on the Main screen to update balances and rates.';
}
