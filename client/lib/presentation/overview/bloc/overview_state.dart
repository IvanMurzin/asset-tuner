part of 'overview_cubit.dart';

enum OverviewStatus { loading, ready, error }

@freezed
abstract class OverviewNavigation with _$OverviewNavigation {
  const factory OverviewNavigation({required OverviewDestination destination}) =
      _OverviewNavigation;
}

@freezed
abstract class OverviewState with _$OverviewState {
  const factory OverviewState({
    @Default(OverviewStatus.loading) OverviewStatus status,
    String? userId,
    String? baseCurrency,
    String? plan,
    String? failureCode,
    DateTime? ratesAsOf,
    String? ratesFailureCode,
    OverviewNavigation? navigation,
  }) = _OverviewState;
}
