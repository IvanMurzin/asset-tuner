import 'package:asset_tuner/core/utils/money_atomic.dart';
import 'package:asset_tuner/data/analytics/dto/analytics_summary_dto.dart';
import 'package:asset_tuner/domain/analytics/entity/analytics_summary_entity.dart';

abstract final class AnalyticsSummaryMapper {
  static AnalyticsSummaryEntity toEntity(AnalyticsSummaryDto dto) {
    return AnalyticsSummaryEntity(
      baseCurrency: dto.baseCurrency,
      asOf: dto.asOfIso == null ? null : DateTime.tryParse(dto.asOfIso!),
      breakdown: dto.breakdown
          .map(
            (item) => AnalyticsBreakdownEntity(
              assetCode: item.assetCode,
              value: MoneyAtomic.fromAtomic(item.valueAtomic.toString(), item.valueDecimals),
              originalAmount: MoneyAtomic.fromAtomic(
                item.originalAmountAtomic.toString(),
                item.originalAmountDecimals,
              ),
            ),
          )
          .toList(growable: false),
      updates: dto.updates
          .map(
            (item) => AnalyticsUpdateEntity(
              accountName: item.accountName,
              subaccountName: item.subaccountName,
              assetCode: item.assetCode,
              diffAmount: MoneyAtomic.fromAtomic(item.diffAtomic.toString(), item.diffDecimals),
              diffBaseAmount: MoneyAtomic.fromAtomic(
                item.diffBaseAtomic.toString(),
                item.diffBaseDecimals,
              ),
              entryDate: DateTime.parse(item.createdAtIso),
            ),
          )
          .toList(growable: false),
    );
  }
}
