import 'package:decimal/decimal.dart';
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

  Future<List<AccountAssetDto>> fetchAccountAssets({
    required String accountId,
  }) async {
    final rows = await _client
        .from(SupabaseTables.accountAssets)
        .select()
        .eq('account_id', accountId)
        .eq('archived', false)
        .order('sort_order', ascending: true)
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
    required String name,
    required String assetId,
    required Decimal snapshotAmount,
    required DateTime entryDate,
  }) async {
    final payload = await _edgeFunctions.invokeJson(
      SupabaseFunctions.createSubaccount,
      body: {
        'account_id': accountId,
        'name': name,
        'asset_id': assetId,
        'snapshot_amount': snapshotAmount.toString(),
        'entry_date': entryDate.toUtc().toIso8601String(),
      },
    );
    final subaccountJson = payload['subaccount'];
    if (subaccountJson is! Map<String, dynamic>) {
      throw StateError('create_subaccount returned invalid payload');
    }
    return AccountAssetDto.fromJson(subaccountJson);
  }

  Future<AccountAssetDto> renameSubaccount({
    required String subaccountId,
    required String name,
  }) {
    return _edgeFunctions.invoke(
      SupabaseFunctions.renameSubaccount,
      body: {'subaccount_id': subaccountId, 'name': name},
      decode: AccountAssetDto.fromJson,
    );
  }

  Future<void> removeAssetFromAccount({required String subaccountId}) async {
    await _edgeFunctions.invokeVoid(
      SupabaseFunctions.deleteSubaccount,
      method: HttpMethod.delete,
      body: {'subaccount_id': subaccountId},
    );
  }

}
