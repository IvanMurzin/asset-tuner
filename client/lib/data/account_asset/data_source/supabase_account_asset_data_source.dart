import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/_shared/money_atomic.dart';
import 'package:asset_tuner/data/account_asset/dto/account_asset_dto.dart';

@lazySingleton
class SupabaseAccountAssetDataSource {
  SupabaseAccountAssetDataSource(this._edgeFunctions);

  final SupabaseEdgeFunctions _edgeFunctions;

  Future<List<AccountAssetDto>> fetchAccountAssets({
    required String accountId,
  }) async {
    final rows = await _edgeFunctions.invokeDataList(
      SupabaseApiRoutes.subaccountsList,
      query: {'accountId': accountId},
      method: HttpMethod.get,
    );
    return rows.map(AccountAssetDto.fromJson).toList(growable: false);
  }

  Future<int> countAssetPositions() async {
    final accounts = await _edgeFunctions.invokeDataList(
      SupabaseApiRoutes.accountsList,
      method: HttpMethod.get,
    );
    var total = 0;
    for (final account in accounts) {
      final countRaw = account['subaccounts_count'];
      if (countRaw is num) {
        total += countRaw.toInt();
      }
    }
    return total;
  }

  Future<AccountAssetDto> addAssetToAccount({
    required String accountId,
    required String name,
    required String assetId,
    required Decimal snapshotAmount,
    required DateTime entryDate,
  }) async {
    // API stores event time server-side via created_at.
    final _ = entryDate;
    final decimals = await _resolveAssetDecimals(assetId);
    final row = await _edgeFunctions.invokeDataObject(
      SupabaseApiRoutes.subaccountsCreate,
      body: {
        'accountId': accountId,
        'assetId': assetId,
        'name': name,
        'initialAmountAtomic': MoneyAtomic.toAtomic(snapshotAmount, decimals),
        'initialAmountDecimals': decimals,
      },
      method: HttpMethod.post,
    );
    return AccountAssetDto.fromJson(row);
  }

  Future<AccountAssetDto> renameSubaccount({
    required String subaccountId,
    required String name,
  }) async {
    final row = await _edgeFunctions.invokeDataObject(
      SupabaseApiRoutes.subaccountsUpdate,
      body: {'subaccountId': subaccountId, 'name': name},
      method: HttpMethod.post,
    );
    return AccountAssetDto.fromJson(row);
  }

  Future<void> removeAssetFromAccount({required String subaccountId}) async {
    await _edgeFunctions.invokeVoid(
      SupabaseApiRoutes.subaccountsDelete,
      body: {'subaccountId': subaccountId},
      method: HttpMethod.post,
    );
  }

  Future<int> _resolveAssetDecimals(String assetId) async {
    Future<int?> findInKind(String kind) async {
      final rows = await _edgeFunctions.invokeDataList(
        SupabaseApiRoutes.assetsList,
        query: {'kind': kind, 'limit': 100},
        method: HttpMethod.get,
      );

      for (final row in rows) {
        if (row['id'] == assetId) {
          final raw = row['decimals'];
          if (raw is num) {
            return raw.toInt();
          }
          throw const EdgeFunctionException(
            code: 'INTERNAL_ERROR',
            message: 'Asset decimals are missing in assets response',
          );
        }
      }
      return null;
    }

    final fiatDecimals = await findInKind('fiat');
    if (fiatDecimals != null) {
      return fiatDecimals;
    }
    final cryptoDecimals = await findInKind('crypto');
    if (cryptoDecimals != null) {
      return cryptoDecimals;
    }

    throw const EdgeFunctionException(
      code: 'NOT_FOUND',
      message: 'Asset not found for subaccount creation',
    );
  }
}
