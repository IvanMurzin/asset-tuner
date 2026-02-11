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
    required String accountAssetId,
    required int limit,
    required int offset,
  }) async {
    final start = offset;
    final end = start + limit - 1;
    final rows = await _client
        .from(SupabaseTables.balanceEntries)
        .select()
        .eq('account_asset_id', accountAssetId)
        .order('entry_date', ascending: false)
        .order('created_at', ascending: false)
        .range(start, end);
    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(BalanceEntryDto.fromJson)
        .toList();
  }

  Future<BalanceEntryDto> updateBalance({
    required String accountAssetId,
    required DateTime entryDate,
    Decimal? snapshotAmount,
    Decimal? deltaAmount,
  }) {
    final body = <String, dynamic>{
      'account_asset_id': accountAssetId,
      'entry_date': _formatDate(entryDate),
    };
    if (snapshotAmount != null) {
      body['snapshot_amount'] = snapshotAmount.toString();
    }
    if (deltaAmount != null) {
      body['delta_amount'] = deltaAmount.toString();
    }
    return _edgeFunctions.invoke(
      SupabaseFunctions.updateBalance,
      body: body,
      decode: BalanceEntryDto.fromJson,
    );
  }

  Future<List<BalanceEntryDto>> fetchEntriesForPositions(
    Set<String> accountAssetIds,
  ) async {
    final rows = await _client
        .from(SupabaseTables.balanceEntries)
        .select()
        .inFilter('account_asset_id', accountAssetIds.toList())
        .order('entry_date', ascending: true)
        .order('created_at', ascending: true);
    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(BalanceEntryDto.fromJson)
        .toList();
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

