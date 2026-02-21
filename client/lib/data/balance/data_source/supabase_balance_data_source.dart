import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/_shared/money_atomic.dart';
import 'package:asset_tuner/data/balance/dto/balance_entry_dto.dart';
import 'package:asset_tuner/data/balance/dto/balance_history_response_dto.dart';

@lazySingleton
class SupabaseBalanceDataSource {
  SupabaseBalanceDataSource(this._edgeFunctions);

  final SupabaseEdgeFunctions _edgeFunctions;

  Future<BalanceHistoryResponseDto> fetchHistory({
    required String subaccountId,
    required int limit,
    String? cursor,
  }) async {
    final envelope = await _edgeFunctions.invokeApiEnvelope(
      SupabaseApiRoutes.subaccountsHistory,
      query: {
        'subaccountId': subaccountId,
        'limit': limit.toString(),
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
      method: HttpMethod.get,
    );

    final data = envelope.data;
    if (data is! List) {
      return const BalanceHistoryResponseDto(items: [], nextCursor: null);
    }

    final items = data.whereType<Map<String, dynamic>>().map(BalanceEntryDto.fromJson).toList();
    final nextCursor = envelope.meta?['nextCursor'] as String?;

    return BalanceHistoryResponseDto(items: items, nextCursor: nextCursor);
  }

  Future<BalanceEntryDto> updateBalance({
    required String subaccountId,
    required DateTime entryDate,
    required Decimal snapshotAmount,
  }) async {
    final _ = entryDate;
    final decimals = await _resolveSubaccountDecimals(subaccountId);
    final row = await _edgeFunctions.invokeDataObject(
      SupabaseApiRoutes.subaccountsSetBalance,
      body: {
        'subaccountId': subaccountId,
        'amountAtomic': MoneyAtomic.toAtomic(snapshotAmount, decimals),
        'amountDecimals': decimals,
      },
      method: HttpMethod.post,
    );
    return BalanceEntryDto.fromJson(row);
  }

  Future<List<BalanceEntryDto>> fetchEntriesForPositions(Set<String> subaccountIds) async {
    if (subaccountIds.isEmpty) return [];
    final pages = await Future.wait(
      subaccountIds.map((id) => fetchHistory(subaccountId: id, limit: 1)),
    );
    return [
      for (final page in pages)
        if (page.items.isNotEmpty) ...page.items,
    ];
  }

  Future<int> _resolveSubaccountDecimals(String subaccountId) async {
    final page = await fetchHistory(subaccountId: subaccountId, limit: 1);
    if (page.items.isNotEmpty) {
      return page.items.first.amountDecimals;
    }
    throw const EdgeFunctionException(
      code: 'INTERNAL_ERROR',
      message: 'Cannot resolve subaccount decimals: no balance history',
    );
  }
}
