import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/usecase/get_latest_usd_rates_usecase.dart';

part 'usd_rates_cubit.freezed.dart';
part 'usd_rates_state.dart';

@injectable
class UsdRatesCubit extends Cubit<UsdRatesState> {
  UsdRatesCubit(this._getLatestUsdRates) : super(const UsdRatesState()) {
    start();
  }

  final GetLatestUsdRatesUseCase _getLatestUsdRates;

  Timer? _timer;
  bool _isRefreshing = false;

  Future<void> start() async {
    await refresh();
    _timer ??= Timer.periodic(const Duration(minutes: 1), (_) => refresh());
  }

  Future<void> refresh() async {
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;

    try {
      final result = await _getLatestUsdRates();
      switch (result) {
        case Success<RatesSnapshotEntity?>(value: final snapshot):
          emit(
            state.copyWith(
              status: UsdRatesStatus.ready,
              snapshot: snapshot,
              failureCode: null,
              lastRefreshAt: DateTime.now(),
            ),
          );
        case FailureResult<RatesSnapshotEntity?>(failure: final failure):
          emit(
            state.copyWith(
              status: state.snapshot == null ? UsdRatesStatus.error : state.status,
              failureCode: failure.code,
              failureMessage: failure.message,
              lastRefreshAt: DateTime.now(),
            ),
          );
      }
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _timer = null;
    return super.close();
  }
}
