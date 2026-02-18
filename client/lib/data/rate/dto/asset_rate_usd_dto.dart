import 'package:decimal/decimal.dart';
import 'package:asset_tuner/data/_shared/money_atomic.dart';

class AssetRateUsdDto {
  const AssetRateUsdDto({
    required this.assetId,
    required this.usdPrice,
    required this.asOfIso,
  });

  final String assetId;
  final Decimal usdPrice;
  final String asOfIso;

  factory AssetRateUsdDto.fromJson(Map<String, dynamic> json) {
    final atomic = (json['usd_price_atomic'] as String?) ?? '0';
    final decimalsRaw = json['usd_price_decimals'];
    final decimals = decimalsRaw is num ? decimalsRaw.toInt() : 12;
    return AssetRateUsdDto(
      assetId:
          (json['asset_id'] as String?) ?? (json['assetId'] as String?) ?? '',
      usdPrice: MoneyAtomic.fromAtomic(atomic, decimals),
      asOfIso: (json['as_of'] as String?) ?? '',
    );
  }
}
