import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_summary_entity.freezed.dart';

@freezed
abstract class AnalyticsSummaryEntity with _$AnalyticsSummaryEntity {
  const factory AnalyticsSummaryEntity({
    required String baseCurrency,
    DateTime? asOf,
    required List<AnalyticsBreakdownEntity> breakdown,
    required List<AnalyticsUpdateEntity> updates,
  }) = _AnalyticsSummaryEntity;
}

@freezed
abstract class AnalyticsBreakdownEntity with _$AnalyticsBreakdownEntity {
  const factory AnalyticsBreakdownEntity({
    required String assetCode,
    required Decimal value,
    required Decimal originalAmount,
  }) = _AnalyticsBreakdownEntity;
}

@freezed
abstract class AnalyticsUpdateEntity with _$AnalyticsUpdateEntity {
  const factory AnalyticsUpdateEntity({
    required String accountName,
    required String subaccountName,
    required String assetCode,
    required Decimal diffAmount,
    required Decimal diffBaseAmount,
    required DateTime entryDate,
  }) = _AnalyticsUpdateEntity;
}
