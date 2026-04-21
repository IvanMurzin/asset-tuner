abstract final class AppRoutes {
  static const String home = '/';
  static const String designSystem = '/ds';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String otp = '/otp';
  static const String onboardingCarousel = '/onboarding/carousel';

  static const String main = '/main';
  static const String analytics = '/analytics';
  static const String profile = '/profile';

  static const String accountNew = '/main/accounts/new';
  static const String accountDetail = '/main/accounts/:accountId';
  static const String accountEdit = '/main/accounts/:accountId/edit';
  static const String accountAddSubaccount = '/main/accounts/:accountId/subaccounts/new';

  static const String accountSubaccountDetail =
      '/main/accounts/:accountId/subaccounts/:subaccountId';
  static const String accountSubaccountBalance =
      '/main/accounts/:accountId/subaccounts/:subaccountId/update-balance';

  static const String paywall = '/paywall';
  static const String baseCurrencySettings = '/profile/base-currency';
  static const String manageSubscription = '/profile/subscription';
  static const String archivedAccounts = '/profile/archived-accounts';
  static const String archivedAccountDetail = '/profile/archived-accounts/:accountId';
  static const String contactDeveloper = '/profile/contact-developer';

  static const String accountsNewPath = 'accounts/new';
  static const String accountIdPath = 'accounts/:accountId';
  static const String editPath = 'edit';
  static const String subaccountsNewPath = 'subaccounts/new';
  static const String subaccountIdPath = 'subaccounts/:subaccountId';
  static const String updateBalancePath = 'update-balance';
}
