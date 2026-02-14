part of 'analytics_cubit.dart';

enum AnalyticsStatus { loading, ready, error }

@freezed
abstract class AnalyticsNavigation with _$AnalyticsNavigation {
  const factory AnalyticsNavigation({
    required AnalyticsDestination destination,
  }) = _AnalyticsNavigation;
}

@freezed
abstract class AnalyticsBreakdownItem with _$AnalyticsBreakdownItem {
  const factory AnalyticsBreakdownItem({
    required String assetCode,
    required Decimal value,
    required Decimal percent,
  }) = _AnalyticsBreakdownItem;
}

@freezed
abstract class AnalyticsUpdateItem with _$AnalyticsUpdateItem {
  const factory AnalyticsUpdateItem({
    required String accountName,
    required String subaccountName,
    required String assetCode,
    required Decimal diffAmount,
    required Decimal diffBaseAmount,
    required DateTime entryDate,
  }) = _AnalyticsUpdateItem;
}

@freezed
abstract class AnalyticsState with _$AnalyticsState {
  const factory AnalyticsState({
    @Default(AnalyticsStatus.loading) AnalyticsStatus status,
    String? baseCurrency,
    DateTime? ratesAsOf,
    @Default([]) List<AnalyticsBreakdownItem> breakdown,
    @Default([]) List<AnalyticsUpdateItem> updates,
    String? failureCode,
    String? failureMessage,
    AnalyticsNavigation? navigation,
  }) = _AnalyticsState;
}
