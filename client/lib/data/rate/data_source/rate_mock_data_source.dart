import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/local_storage/asset_rates_storage.dart';

@lazySingleton
class RateMockDataSource {
  RateMockDataSource(this._storage);

  final AssetRatesStorage _storage;

  Future<Map<String, StoredAssetRateUsd>> fetchLatestUsdRates() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final existing = await _storage.readRates();
    if (existing.isNotEmpty) {
      return existing;
    }

    final asOf = DateTime.now().subtract(const Duration(minutes: 7));
    final seed = <String, StoredAssetRateUsd>{
      'asset_usd': StoredAssetRateUsd(
        assetId: 'asset_usd',
        usdPrice: '1',
        asOfIso: asOf.toIso8601String(),
      ),
      'asset_eur': StoredAssetRateUsd(
        assetId: 'asset_eur',
        usdPrice: '1.08',
        asOfIso: asOf.toIso8601String(),
      ),
      'asset_gbp': StoredAssetRateUsd(
        assetId: 'asset_gbp',
        usdPrice: '1.26',
        asOfIso: asOf.toIso8601String(),
      ),
      'asset_jpy': StoredAssetRateUsd(
        assetId: 'asset_jpy',
        usdPrice: '0.0067',
        asOfIso: asOf.toIso8601String(),
      ),
      'asset_chf': StoredAssetRateUsd(
        assetId: 'asset_chf',
        usdPrice: '1.10',
        asOfIso: asOf.toIso8601String(),
      ),
      'asset_rub': StoredAssetRateUsd(
        assetId: 'asset_rub',
        usdPrice: '0.011',
        asOfIso: asOf.toIso8601String(),
      ),
      'asset_btc': StoredAssetRateUsd(
        assetId: 'asset_btc',
        usdPrice: '65000',
        asOfIso: asOf.toIso8601String(),
      ),
      'asset_eth': StoredAssetRateUsd(
        assetId: 'asset_eth',
        usdPrice: '3200',
        asOfIso: asOf.toIso8601String(),
      ),
      'asset_usdt': StoredAssetRateUsd(
        assetId: 'asset_usdt',
        usdPrice: '1',
        asOfIso: asOf.toIso8601String(),
      ),
    };
    await _storage.writeRates(seed);
    return seed;
  }
}
