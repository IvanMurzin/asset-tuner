import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/balance/dto/balance_entry_dto.dart';

@lazySingleton
class SupabaseBalanceDataSource {
  SupabaseBalanceDataSource(this._client, this._edgeFunctions);

  final SupabaseClient _client;
  final SupabaseEdgeFunctions _edgeFunctions;

  Future<List<BalanceEntryDto>> fetchHistory({
    required String subaccountId,
    required int limit,
    required int offset,
  }) async {
    final start = offset;
    final end = start + limit - 1;
    final rows = await _client
        .from(SupabaseTables.balanceEntries)
        .select()
        .eq('subaccount_id', subaccountId)
        .order('entry_date', ascending: false)
        .order('created_at', ascending: false)
        .range(start, end);
    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(BalanceEntryDto.fromJson)
        .toList();
  }

  Future<BalanceEntryDto> updateBalance({
    required String subaccountId,
    required DateTime entryDate,
    required Decimal snapshotAmount,
  }) {
    return _edgeFunctions.invoke(
      SupabaseFunctions.updateSubaccountBalance,
      body: {
        'subaccount_id': subaccountId,
        'entry_date': entryDate.toUtc().toIso8601String(),
        'snapshot_amount': snapshotAmount.toString(),
      },
      decode: BalanceEntryDto.fromJson,
    );
  }

  Future<List<BalanceEntryDto>> fetchEntriesForPositions(
    Set<String> subaccountIds,
  ) async {
    final rows = await _client
        .from(SupabaseTables.balanceEntries)
        .select()
        .inFilter('subaccount_id', subaccountIds.toList())
        .order('entry_date', ascending: true)
        .order('created_at', ascending: true);
    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(BalanceEntryDto.fromJson)
        .toList();
  }

}
