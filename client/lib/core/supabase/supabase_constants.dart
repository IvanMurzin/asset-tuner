abstract final class SupabaseTables {
  static const profiles = 'profiles';
  static const accounts = 'accounts';
  static const assets = 'assets';
  static const accountAssets = 'account_assets';
  static const balanceEntries = 'balance_entries';
  static const assetRatesUsd = 'asset_rates_usd';
}

abstract final class SupabaseFunctions {
  static const bootstrapProfile = 'bootstrap_profile';
  static const createAccount = 'create_account';
  static const deleteAccount = 'account';
  static const addAssetToAccount = 'add_asset_to_account';
  static const removeAssetFromAccount = 'remove_asset_from_account';
  static const updateBaseCurrency = 'update_base_currency';
  static const updateBalance = 'update_balance';
  static const updatePlan = 'update_plan';
}
