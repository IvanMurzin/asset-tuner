import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/rate/data_source/supabase_rate_data_source.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/repository/i_rate_repository.dart';

@LazySingleton(as: IRateRepository)
class RateRepository implements IRateRepository {
  RateRepository(this._dataSource);

  final SupabaseRateDataSource _dataSource;

  @override
  Future<Result<RatesSnapshotEntity?>> fetchLatestUsdRates() async {
    try {
      final dtos = await _dataSource.fetchLatestUsdRates();
      if (dtos.isEmpty) {
        logger.w('RateRepository.fetchLatestUsdRates empty');
        return const Success(null);
      }
      final asOf = dtos
          .map((e) => DateTime.parse(e.asOfIso))
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final prices = <String, Decimal>{};
      for (final dto in dtos) {
        prices[dto.assetId] = Decimal.parse(dto.usdPrice);
      }
      logger.i('RateRepository.fetchLatestUsdRates success: ${prices.length}');
      return Success(
        RatesSnapshotEntity(usdPriceByAssetId: prices, asOf: asOf),
      );
    } catch (error) {
      logger.e('RateRepository.fetchLatestUsdRates failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to load rates',
        ),
      );
    }
  }
}
