import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/local_storage/asset_rates_storage.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/rate/data_source/supabase_rate_data_source.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/repository/i_rate_repository.dart';

@LazySingleton(as: IRateRepository)
class RateRepository implements IRateRepository {
  RateRepository(this._dataSource, this._storage);

  final SupabaseRateDataSource _dataSource;
  final AssetRatesStorage _storage;

  static const _minRefreshInterval = Duration(minutes: 1);

  bool _hydrated = false;
  RatesSnapshotEntity? _cached;
  DateTime? _lastRefreshAttemptAt;
  Future<Result<RatesSnapshotEntity?>>? _inFlightRefresh;

  @override
  Future<Result<RatesSnapshotEntity?>> fetchLatestUsdRates() async {
    await _hydrateFromDiskOnce();

    final now = DateTime.now();
    final cached = _cached;

    if (cached != null) {
      final lastAttempt = _lastRefreshAttemptAt;
      final canAttemptRefresh =
          lastAttempt == null ||
          now.difference(lastAttempt) >= _minRefreshInterval;

      if (canAttemptRefresh) {
        _startRefreshIfNeeded(now);
      }

      return Success(cached);
    }

    return _refreshAndReturn(now);
  }

  void _startRefreshIfNeeded(DateTime now) {
    if (_inFlightRefresh != null) {
      return;
    }
    _lastRefreshAttemptAt = now;
    _inFlightRefresh = _refresh().whenComplete(() {
      _inFlightRefresh = null;
    });

    unawaited(_inFlightRefresh);
  }

  Future<Result<RatesSnapshotEntity?>> _refreshAndReturn(DateTime now) async {
    final inFlight = _inFlightRefresh;
    if (inFlight != null) {
      return inFlight;
    }
    _lastRefreshAttemptAt = now;
    final future = _refresh();
    _inFlightRefresh = future.whenComplete(() {
      _inFlightRefresh = null;
    });
    return _inFlightRefresh!;
  }

  Future<Result<RatesSnapshotEntity?>> _refresh() async {
    try {
      final dtos = await _dataSource.fetchLatestUsdRates();
      if (dtos.isEmpty) {
        logger.w('RateRepository.fetchLatestUsdRates empty');
        final cached = _cached;
        return cached == null ? const Success(null) : Success(cached);
      }
      final asOf = dtos
          .map((e) => DateTime.parse(e.asOfIso))
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final prices = <String, Decimal>{};
      for (final dto in dtos) {
        prices[dto.assetId] = Decimal.parse(dto.usdPrice);
      }
      logger.i('RateRepository.fetchLatestUsdRates success: ${prices.length}');
      final snapshot = RatesSnapshotEntity(
        usdPriceByAssetId: prices,
        asOf: asOf,
      );

      _cached = snapshot;
      final stored = <String, StoredAssetRateUsd>{};
      for (final dto in dtos) {
        stored[dto.assetId] = StoredAssetRateUsd(
          assetId: dto.assetId,
          usdPrice: dto.usdPrice,
          asOfIso: dto.asOfIso,
        );
      }
      await _storage.writeRates(stored);

      return Success(snapshot);
    } catch (error) {
      logger.e('RateRepository.fetchLatestUsdRates failed', error: error);
      final cached = _cached;
      if (cached != null) {
        return Success(cached);
      }
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to load rates',
        ),
      );
    }
  }

  Future<void> _hydrateFromDiskOnce() async {
    if (_hydrated) {
      return;
    }
    _hydrated = true;

    try {
      final stored = await _storage.readRates();
      if (stored.isEmpty) {
        return;
      }

      final prices = <String, Decimal>{};
      DateTime? asOf;

      for (final entry in stored.entries) {
        prices[entry.key] = Decimal.parse(entry.value.usdPrice);
        final rateAsOf = DateTime.parse(entry.value.asOfIso);
        asOf = asOf == null || rateAsOf.isAfter(asOf) ? rateAsOf : asOf;
      }

      if (prices.isEmpty || asOf == null) {
        return;
      }

      _cached = RatesSnapshotEntity(usdPriceByAssetId: prices, asOf: asOf);
      logger.i('RateRepository hydrated from disk: ${prices.length}');
    } catch (error) {
      logger.w('RateRepository hydrate from disk failed', error: error);
    }
  }
}
