abstract final class AppRoutes {
  static const String home = '/';
  static const String designSystem = '/ds';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String otp = '/otp';
  static const String onboardingBaseCurrency = '/onboarding/base-currency';
  static const String overview = '/overview';
  static const String accounts = '/accounts';
  static const String accountNew = '/accounts/new';
  static const String accountDetail = '/accounts/:id';
  static const String accountEdit = '/accounts/:id/edit';
  static const String accountAddAsset = '/accounts/:id/add-asset';
  static const String assetPositionDetail =
      '/accounts/:accountId/assets/:assetId';
  static const String addBalance =
      '/accounts/:accountId/assets/:assetId/add-balance';
  static const String paywall = '/paywall';
  static const String settings = '/settings';
  static const String accountActions = '/settings/account';
  static const String baseCurrencySettings = '/settings/base-currency';
  static const String manageSubscription = '/settings/subscription';
  static const String language = '/settings/language';
  static const String theme = '/settings/theme';
}
