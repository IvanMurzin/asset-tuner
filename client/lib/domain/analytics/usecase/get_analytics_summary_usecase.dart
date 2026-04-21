import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/analytics/entity/analytics_summary_entity.dart';
import 'package:asset_tuner/domain/analytics/repository/i_analytics_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAnalyticsSummaryUseCase {
  GetAnalyticsSummaryUseCase(this._repository);

  final IAnalyticsRepository _repository;

  Future<Result<AnalyticsSummaryEntity>> call({int updatesLimit = 200}) {
    return _repository.fetchSummary(updatesLimit: updatesLimit);
  }
}
