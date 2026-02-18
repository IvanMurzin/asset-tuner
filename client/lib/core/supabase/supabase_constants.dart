abstract final class SupabaseApiRoutes {
  static const me = 'api/me';
  static const profileUpdate = 'api/profile/update';
  static const deleteMyAccount = 'api/delete_my_account';
  static const contactDeveloper = 'api/contact_developer';

  static const assetsList = 'api/assets/list';
  static const ratesUsd = 'api/rates/usd';

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

// Legacy compatibility for old tests/docs checks.
abstract final class SupabaseTables {
  static const profiles = 'profiles';
  static const accounts = 'accounts';
  static const assets = 'assets';
  static const accountAssets = 'subaccounts';
  static const balanceEntries = 'balance_entries';
  static const assetRatesUsd = 'asset_rates_usd';
}

// Legacy compatibility for old tests/docs checks.
abstract final class SupabaseFunctions {
  static const bootstrapProfile = 'bootstrap_profile';
  static const createAccount = 'create_account';
  static const deleteAccount = 'account';
  static const createSubaccount = 'create_subaccount';
  static const renameSubaccount = 'rename_subaccount';
  static const deleteSubaccount = 'subaccount';
  static const updateBaseCurrency = 'update_base_currency';
  static const updateSubaccountBalance = 'update_subaccount_balance';
  static const updatePlan = 'update_plan';
}
