import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'rates_snapshot_entity.freezed.dart';

@freezed
abstract class RatesSnapshotEntity with _$RatesSnapshotEntity {
  const factory RatesSnapshotEntity({
    required Map<String, Decimal> usdPriceByAssetId,
    required DateTime asOf,
  }) = _RatesSnapshotEntity;
}
