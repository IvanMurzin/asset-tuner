import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/rate/dto/asset_rate_usd_dto.dart';

@lazySingleton
class SupabaseRateDataSource {
  SupabaseRateDataSource(this._edgeFunctions);

  final SupabaseEdgeFunctions _edgeFunctions;

  Future<List<AssetRateUsdDto>> fetchLatestUsdRates() async {
    final fiat = await _edgeFunctions.invokeDataList(
      SupabaseApiRoutes.assetsList,
      query: {'kind': 'fiat', 'limit': 100},
      method: HttpMethod.get,
    );
    final crypto = await _edgeFunctions.invokeDataList(
      SupabaseApiRoutes.assetsList,
      query: {'kind': 'crypto', 'limit': 100},
      method: HttpMethod.get,
    );

    final assetIds = <String>[
      ...fiat.map((e) => e['id'] as String?).whereType<String>(),
      ...crypto.map((e) => e['id'] as String?).whereType<String>(),
    ];
    if (assetIds.isEmpty) {
      return const [];
    }

    final envelope = await _edgeFunctions.invokeApiEnvelope(
      SupabaseApiRoutes.ratesUsd,
      query: {'assetIds': assetIds.join(',')},
      method: HttpMethod.get,
    );

    final data = envelope.data;
    if (data is! Map<String, dynamic>) {
      return const [];
    }

    final result = <AssetRateUsdDto>[];
    for (final entry in data.entries) {
      final rate = entry.value;
      if (rate is! Map<String, dynamic>) {
        continue;
      }
      result.add(AssetRateUsdDto.fromJson({'asset_id': entry.key, ...rate}));
    }

    return result;
  }
}
