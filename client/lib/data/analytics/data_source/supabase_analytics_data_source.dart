import 'package:asset_tuner/core/supabase/supabase_constants.dart';
import 'package:asset_tuner/core/supabase/supabase_edge_functions.dart';
import 'package:asset_tuner/data/analytics/dto/analytics_summary_dto.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@lazySingleton
class SupabaseAnalyticsDataSource {
  SupabaseAnalyticsDataSource(this._edgeFunctions);

  final SupabaseEdgeFunctions _edgeFunctions;

  Future<AnalyticsSummaryDto> fetchSummary({int updatesLimit = 200}) async {
    final data = await _edgeFunctions.invokeDataObject(
      SupabaseApiRoutes.analyticsSummary,
      query: {'updatesLimit': updatesLimit},
      method: HttpMethod.get,
    );

    return AnalyticsSummaryDto.fromJson(data);
  }
}
