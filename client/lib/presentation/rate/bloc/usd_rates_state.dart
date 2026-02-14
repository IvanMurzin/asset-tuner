part of 'usd_rates_cubit.dart';

enum UsdRatesStatus { idle, ready, error }

@freezed
abstract class UsdRatesState with _$UsdRatesState {
  const factory UsdRatesState({
    @Default(UsdRatesStatus.idle) UsdRatesStatus status,
    RatesSnapshotEntity? snapshot,
    String? failureCode,
    String? failureMessage,
    DateTime? lastRefreshAt,
  }) = _UsdRatesState;
}
