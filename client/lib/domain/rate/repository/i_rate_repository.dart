import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';

abstract interface class IRateRepository {
  Future<Result<RatesSnapshotEntity?>> fetchLatestUsdRates();
}
