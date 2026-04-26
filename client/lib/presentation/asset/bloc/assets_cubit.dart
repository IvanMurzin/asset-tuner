import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/usecase/get_latest_usd_rates_usecase.dart';

part 'assets_cubit.freezed.dart';
part 'assets_state.dart';

@injectable
class AssetsCubit extends Cubit<AssetsState> {
  AssetsCubit(this._getCachedSession, this._getAssets, this._getLatestUsdRates)
    : super(const AssetsState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetAssetsUseCase _getAssets;
  final GetLatestUsdRatesUseCase _getLatestUsdRates;

  Timer? _timer;
  bool _isFetching = false;
  bool _queuedFetch = false;
  bool _queuedSilent = true;
  bool _queuedForceRefresh = false;

  Future<void> load() async {
    if (_timer != null) {
      return;
    }
    emit(state.copyWith(status: AssetsStatus.loading, failureCode: null, failureMessage: null));
    await _fetch(silent: false, forceRefresh: false);
    _timer ??= Timer.periodic(const Duration(minutes: 1), (_) => refresh());
  }

  Future<void> refresh({bool silent = false, bool forceRefresh = false}) async {
    await _fetch(silent: silent, forceRefresh: forceRefresh);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _timer = null;
    return super.close();
  }

  Future<void> _fetch({required bool silent, required bool forceRefresh}) async {
    if (_isFetching) {
      _queuedFetch = true;
      _queuedSilent = _queuedSilent && silent;
      _queuedForceRefresh = _queuedForceRefresh || forceRefresh;
      return;
    }
    _isFetching = true;

    try {
      final session = await _getCachedSession();
      if (isClosed) {
        return;
      }
      if (session == null) {
        emit(
          state.copyWith(
            status: AssetsStatus.error,
            assets: const <AssetEntity>[],
            failureCode: 'unauthorized',
            failureMessage: null,
          ),
        );
        return;
      }

      final assetsResult = await _getAssets(forceRefresh: forceRefresh);
      if (isClosed) {
        return;
      }

      List<AssetEntity> sortedAssets;
      switch (assetsResult) {
        case FailureResult<List<AssetEntity>>(failure: final failure):
          if (!silent || state.status != AssetsStatus.ready) {
            emit(
              state.copyWith(
                status: AssetsStatus.error,
                failureCode: failure.code,
                failureMessage: failure.message,
              ),
            );
          } else {
            emit(state.copyWith(failureCode: failure.code, failureMessage: failure.message));
          }
          return;
        case Success<List<AssetEntity>>(value: final assets):
          sortedAssets = [...assets]
            ..sort((a, b) {
              final rankA = a.rank ?? 999999;
              final rankB = b.rank ?? 999999;
              if (rankA != rankB) return rankA.compareTo(rankB);
              return a.code.compareTo(b.code);
            });
          break;
      }

      final ratesResult = await _getLatestUsdRates();
      if (isClosed) {
        return;
      }

      final now = DateTime.now();

      switch (ratesResult) {
        case Success<RatesSnapshotEntity?>(value: final snapshot):
          emit(
            state.copyWith(
              status: AssetsStatus.ready,
              assets: sortedAssets,
              snapshot: snapshot ?? state.snapshot,
              lastRatesRefreshAt: now,
              failureCode: null,
              failureMessage: null,
            ),
          );
        case FailureResult<RatesSnapshotEntity?>(failure: final failure):
          if (state.snapshot != null) {
            emit(
              state.copyWith(
                status: AssetsStatus.ready,
                assets: sortedAssets,
                lastRatesRefreshAt: now,
                failureCode: failure.code,
                failureMessage: failure.message,
              ),
            );
          } else if (!silent || state.status != AssetsStatus.ready) {
            emit(
              state.copyWith(
                status: AssetsStatus.error,
                assets: sortedAssets,
                failureCode: failure.code,
                failureMessage: failure.message,
              ),
            );
          } else {
            emit(
              state.copyWith(
                assets: sortedAssets,
                failureCode: failure.code,
                failureMessage: failure.message,
              ),
            );
          }
      }
    } finally {
      _isFetching = false;
      if (_queuedFetch && !isClosed) {
        final nextSilent = _queuedSilent;
        final nextForceRefresh = _queuedForceRefresh;
        _queuedFetch = false;
        _queuedSilent = true;
        _queuedForceRefresh = false;
        unawaited(_fetch(silent: nextSilent, forceRefresh: nextForceRefresh));
      }
    }
  }
}
