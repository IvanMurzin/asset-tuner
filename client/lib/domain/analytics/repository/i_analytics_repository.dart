import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/analytics/entity/analytics_summary_entity.dart';

abstract interface class IAnalyticsRepository {
  Future<Result<AnalyticsSummaryEntity>> fetchSummary({int updatesLimit = 200});
}
