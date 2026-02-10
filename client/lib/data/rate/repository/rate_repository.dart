import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/rate/data_source/rate_mock_data_source.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/repository/i_rate_repository.dart';

@LazySingleton(as: IRateRepository)
class RateRepository implements IRateRepository {
  RateRepository(this._dataSource);

  final RateMockDataSource _dataSource;

  @override
  Future<Result<RatesSnapshotEntity?>> fetchLatestUsdRates() async {
    try {
      final stored = await _dataSource.fetchLatestUsdRates();
      if (stored.isEmpty) {
        logger.w('RateRepository.fetchLatestUsdRates empty');
        return const Success(null);
      }
      final asOf = stored.values
          .map((e) => DateTime.parse(e.asOfIso))
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final prices = stored.map(
        (key, value) => MapEntry(key, Decimal.parse(value.usdPrice)),
      );
      logger.i('RateRepository.fetchLatestUsdRates success: ${prices.length}');
      return Success(
        RatesSnapshotEntity(usdPriceByAssetId: prices, asOf: asOf),
      );
    } catch (_) {
      logger.e('RateRepository.fetchLatestUsdRates failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to load rates'),
      );
    }
  }
}
