abstract final class SupabaseApiRoutes {
  static const me = 'api/me';
  static const profileUpdate = 'api/profile/update';
  static const deleteMyAccount = 'api/delete_my_account';
  static const contactDeveloper = 'api/contact_developer';

  static const assetsList = 'api/assets/list';
  static const ratesUsd = 'api/rates/usd';
  static const analyticsSummary = 'api/analytics/summary';

  static const accountsList = 'api/accounts/list';
  static const accountsCreate = 'api/accounts/create';
  static const accountsUpdate = 'api/accounts/update';
  static const accountsDelete = 'api/accounts/delete';

  static const subaccountsList = 'api/subaccounts/list';
  static const subaccountsCreate = 'api/subaccounts/create';
  static const subaccountsUpdate = 'api/subaccounts/update';
  static const subaccountsDelete = 'api/subaccounts/delete';
  static const subaccountsSetBalance = 'api/subaccounts/set_balance';
  static const subaccountsHistory = 'api/subaccounts/history';

  static const revenuecatRefresh = 'api/revenuecat/refresh';
}
