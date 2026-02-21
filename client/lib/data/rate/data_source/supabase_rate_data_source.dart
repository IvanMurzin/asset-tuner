import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/asset/data_source/supabase_asset_data_source.dart';
import 'package:asset_tuner/data/rate/dto/asset_rate_usd_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class SupabaseRateDataSource {
  SupabaseRateDataSource(this._edgeFunctions, this._assetDataSource);

  final SupabaseEdgeFunctions _edgeFunctions;
  final SupabaseAssetDataSource _assetDataSource;

  Future<List<AssetRateUsdDto>> fetchLatestUsdRates() async {
    final assets = await _assetDataSource.fetchAssets();
    final assetIds = assets.map((a) => a.id).toList();
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
