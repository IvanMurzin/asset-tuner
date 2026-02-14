abstract final class SupabaseTables {
  static const profiles = 'profiles';
  static const accounts = 'accounts';
  static const assets = 'assets';
  static const accountAssets = 'subaccounts';
  static const balanceEntries = 'balance_entries';
  static const assetRatesUsd = 'asset_rates_usd';
}

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

abstract final class SupabaseRpc {
  static const listFiatCurrenciesForPicker = 'list_fiat_currencies_for_picker';
  static const listAssetsForSubaccountPicker =
      'list_assets_for_subaccount_picker';
}
