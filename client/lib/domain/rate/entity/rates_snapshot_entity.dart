import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'rates_snapshot_entity.freezed.dart';

@freezed
abstract class RatesSnapshotEntity with _$RatesSnapshotEntity {
  const factory RatesSnapshotEntity({
    required Map<String, Decimal> usdPriceByAssetId,
    required DateTime asOf,
    @Default(<String, Decimal>{}) Map<String, Decimal> usdPriceAtomicByAssetId,
    @Default(<String, int>{}) Map<String, int> usdPriceDecimalsByAssetId,
    @Default(<String, DateTime>{}) Map<String, DateTime> asOfByAssetId,
  }) = _RatesSnapshotEntity;
}
