import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/repository/i_rate_repository.dart';

@injectable
class GetLatestUsdRatesUseCase {
  GetLatestUsdRatesUseCase(this._repository);

  final IRateRepository _repository;

  Future<Result<RatesSnapshotEntity?>> call() {
    return _repository.fetchLatestUsdRates();
  }
}
