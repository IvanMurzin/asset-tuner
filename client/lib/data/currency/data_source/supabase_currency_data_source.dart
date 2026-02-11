import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/data/currency/dto/currency_dto.dart';

@lazySingleton
class SupabaseCurrencyDataSource {
  SupabaseCurrencyDataSource(this._client);

  final SupabaseClient _client;

  Future<List<CurrencyDto>> fetchFiatCurrencies() async {
    final rows = await _client
        .from(SupabaseTables.assets)
        .select('code,name')
        .eq('kind', 'fiat')
        .order('code', ascending: true);
    return (rows as List)
        .whereType<Map<String, dynamic>>()
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

