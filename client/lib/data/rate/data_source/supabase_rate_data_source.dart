import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/data/rate/dto/asset_rate_usd_dto.dart';

@lazySingleton
class SupabaseRateDataSource {
  SupabaseRateDataSource(this._client);

  final SupabaseClient _client;

  Future<List<AssetRateUsdDto>> fetchLatestUsdRates() async {
    final rows = await _client.from(SupabaseTables.assetRatesUsd).select();
    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map(AssetRateUsdDto.fromJson)
        .toList();
  }
}
