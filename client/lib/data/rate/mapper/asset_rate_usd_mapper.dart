import 'package:decimal/decimal.dart';
import 'package:asset_tuner/core/utils/money_atomic.dart';
import 'package:asset_tuner/data/rate/dto/asset_rate_usd_dto.dart';

abstract final class AssetRateUsdMapper {
  static Decimal toUsdPrice(AssetRateUsdDto dto) {
    return MoneyAtomic.fromAtomic(dto.usdPriceAtomic.toString(), dto.usdPriceDecimals);
  }
}
