import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/_shared/money_atomic.dart';
import 'package:asset_tuner/data/subaccount/dto/subaccount_dto.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class SupabaseSubaccountDataSource {
  SupabaseSubaccountDataSource(this._edgeFunctions);

  final SupabaseEdgeFunctions _edgeFunctions;

  Future<List<SubaccountDto>> fetchSubaccounts({required String accountId}) async {
    final rows = await _edgeFunctions.invokeDataList(
      SupabaseApiRoutes.subaccountsList,
      query: {'accountId': accountId},
      method: HttpMethod.get,
    );
    return rows.map(SubaccountDto.fromJson).toList(growable: false);
  }

  Future<SubaccountDto> createSubaccount({
    required String accountId,
    required String name,
    required AssetEntity asset,
    required Decimal snapshotAmount,
    required DateTime entryDate,
  }) async {
    final _ = entryDate;
    final decimals = asset.decimals;
    if (decimals == null) {
      throw const EdgeFunctionException(
        code: 'VALIDATION',
        message: 'Asset decimals are required for subaccount creation',
      );
    }
    final row = await _edgeFunctions.invokeDataObject(
      SupabaseApiRoutes.subaccountsCreate,
      body: {
        'accountId': accountId,
        'assetId': asset.id,
        'name': name,
        'initialAmountAtomic': MoneyAtomic.toAtomic(snapshotAmount, decimals),
        'initialAmountDecimals': decimals,
      },
      method: HttpMethod.post,
    );
    return SubaccountDto.fromJson(row);
  }

  Future<SubaccountDto> renameSubaccount({
    required String subaccountId,
    required String name,
  }) async {
    final row = await _edgeFunctions.invokeDataObject(
      SupabaseApiRoutes.subaccountsUpdate,
      body: {'subaccountId': subaccountId, 'name': name},
      method: HttpMethod.post,
    );
    return SubaccountDto.fromJson(row);
  }

  Future<void> deleteSubaccount({required String subaccountId}) async {
    await _edgeFunctions.invokeVoid(
      SupabaseApiRoutes.subaccountsDelete,
      body: {'subaccountId': subaccountId},
      method: HttpMethod.post,
    );
  }
}
