import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';

void main() {
  test('docs/contracts mention all Supabase tables', () async {
    final doc = await File('../docs/contracts/data_contract.md').readAsString();
    final tables = <String>{
      SupabaseTables.profiles,
      SupabaseTables.accounts,
      SupabaseTables.assets,
      SupabaseTables.accountAssets,
      SupabaseTables.balanceEntries,
      SupabaseTables.assetRatesUsd,
    };

    for (final table in tables) {
      expect(doc, contains('`$table`'));
    }
  });

  test('docs/contracts mention all Edge Functions', () async {
    final doc = await File('../docs/contracts/api_surface.md').readAsString();
    final functions = <String>{
      SupabaseFunctions.bootstrapProfile,
      SupabaseFunctions.createAccount,
      SupabaseFunctions.deleteAccount,
      SupabaseFunctions.addAssetToAccount,
      SupabaseFunctions.removeAssetFromAccount,
      SupabaseFunctions.updateBaseCurrency,
      SupabaseFunctions.updateBalance,
      SupabaseFunctions.updatePlan,
    };

    for (final fn in functions) {
      expect(doc, contains('/$fn'));
    }
  });
}
