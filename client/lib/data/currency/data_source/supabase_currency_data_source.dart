import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/data/currency/dto/currency_dto.dart';

@lazySingleton
class SupabaseCurrencyDataSource {
  SupabaseCurrencyDataSource(this._client);

  final SupabaseClient _client;

  Future<List<CurrencyDto>> fetchFiatCurrencies() async {
    final rows = await _client.rpc(SupabaseRpc.listFiatCurrenciesForPicker);

    final sortedRows = (rows as List).whereType<Map<String, dynamic>>().toList()
      ..sort((a, b) {
        final aRank = (a['rank'] as num?)?.toInt() ?? 999999;
        final bRank = (b['rank'] as num?)?.toInt() ?? 999999;
        if (aRank != bRank) {
          return aRank.compareTo(bRank);
        }
        final aCode = (a['code'] as String?)?.toUpperCase() ?? '';
        final bCode = (b['code'] as String?)?.toUpperCase() ?? '';
        return aCode.compareTo(bCode);
      });

    return sortedRows
        .map(
          (e) => CurrencyDto(
            code: (e['code'] as String?) ?? '',
            name: (e['name'] as String?) ?? '',
            symbol: (e['code'] as String?) ?? '',
          ),
        )
        .where((e) => e.code.trim().isNotEmpty)
        .toList();
  }
}
