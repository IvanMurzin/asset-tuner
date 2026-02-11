import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/account_asset/dto/account_asset_dto.dart';

@lazySingleton
class SupabaseAccountAssetDataSource {
  SupabaseAccountAssetDataSource(this._client, this._edgeFunctions);

  final SupabaseClient _client;
  final SupabaseEdgeFunctions _edgeFunctions;

  Future<List<AccountAssetDto>> fetchAccountAssets({required String accountId}) async {
    final rows = await _client
        .from(SupabaseTables.accountAssets)
        .select()
        .eq('account_id', accountId)
        .order('created_at', ascending: true);
    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(AccountAssetDto.fromJson)
        .toList();
  }

  Future<int> countAssetPositions() async {
    return _client.from(SupabaseTables.accountAssets).count(CountOption.exact);
  }

  Future<AccountAssetDto> addAssetToAccount({
    required String accountId,
    required String assetId,
  }) {
    return _edgeFunctions.invoke(
      SupabaseFunctions.addAssetToAccount,
      body: {'account_id': accountId, 'asset_id': assetId},
      decode: AccountAssetDto.fromJson,
    );
  }

  Future<void> removeAssetFromAccount({
    required String accountId,
    required String assetId,
  }) async {
    await _edgeFunctions.invokeVoid(
      SupabaseFunctions.removeAssetFromAccount,
      body: {'account_id': accountId, 'asset_id': assetId},
    );
  }
}
