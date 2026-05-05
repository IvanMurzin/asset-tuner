import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/utils/money_atomic.dart';

part 'asset_entity.freezed.dart';

enum AssetKind { fiat, crypto }

@freezed
abstract class AssetUsdRateEntity with _$AssetUsdRateEntity {
  const AssetUsdRateEntity._();

  const factory AssetUsdRateEntity({
    String? assetId,
    required Decimal usdPriceAtomic,
    required int usdPriceDecimals,
    required DateTime asOf,
  }) = _AssetUsdRateEntity;

  Decimal get usdPrice {
    return MoneyAtomic.fromAtomic(usdPriceAtomic.toString(), usdPriceDecimals);
  }
}

@freezed
abstract class AssetEntity with _$AssetEntity {
  const factory AssetEntity({
    required String id,
    required AssetKind kind,
    required String code,
    required String name,
    String? provider,
    String? providerRef,
    int? rank,
    int? decimals,
    bool? isActive,
    bool? isLocked,
    AssetUsdRateEntity? usdRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AssetEntity;
}
