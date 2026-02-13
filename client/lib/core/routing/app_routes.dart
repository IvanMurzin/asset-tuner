abstract final class AppRoutes {
  static const String home = '/';
  static const String designSystem = '/ds';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String otp = '/otp';
  static const String onboardingBaseCurrency = '/onboarding/base-currency';

  static const String main = '/main';
  static const String analytics = '/analytics';
  static const String profile = '/profile';

  static const String accountNew = '/main/accounts/new';
  static const String accountDetail = '/main/accounts/:id';
  static const String accountEdit = '/main/accounts/:id/edit';
  static const String accountAddAsset = '/main/accounts/:id/subaccounts/new';

  static const String subaccountDetail = '/main/subaccounts/:id';
  static const String addBalance = '/main/subaccounts/:id/update-balance';

  static const String paywall = '/paywall';
  static const String baseCurrencySettings = '/profile/base-currency';
  static const String manageSubscription = '/profile/subscription';
  static const String accountActions = '/profile/account';
  static const String language = '/profile/language';
  static const String theme = '/profile/theme';
}
