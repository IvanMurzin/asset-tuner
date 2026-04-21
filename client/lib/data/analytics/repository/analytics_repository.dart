import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/analytics/data_source/supabase_analytics_data_source.dart';
import 'package:asset_tuner/data/analytics/mapper/analytics_summary_mapper.dart';
import 'package:asset_tuner/domain/analytics/entity/analytics_summary_entity.dart';
import 'package:asset_tuner/domain/analytics/repository/i_analytics_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IAnalyticsRepository)
class AnalyticsRepository implements IAnalyticsRepository {
  AnalyticsRepository(this._dataSource);

  final SupabaseAnalyticsDataSource _dataSource;

  @override
  Future<Result<AnalyticsSummaryEntity>> fetchSummary({int updatesLimit = 200}) async {
    try {
      final dto = await _dataSource.fetchSummary(updatesLimit: updatesLimit);
      logger.i('AnalyticsRepository.fetchSummary success');
      return Success(AnalyticsSummaryMapper.toEntity(dto));
    } catch (error) {
      logger.e('AnalyticsRepository.fetchSummary failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(error, fallbackMessage: 'Unable to load analytics'),
      );
    }
  }
}
