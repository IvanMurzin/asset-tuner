import 'package:injectable/injectable.dart';
import 'package:asset_tuner/data/asset/dto/asset_dto.dart';

@lazySingleton
class AssetMockDataSource {
  Future<List<AssetDto>> fetchAssets() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const [
      AssetDto(
        id: 'asset_usd',
        kind: 'fiat',
        code: 'USD',
        name: 'United States Dollar',
        decimals: 2,
      ),
      AssetDto(
        id: 'asset_eur',
        kind: 'fiat',
        code: 'EUR',
        name: 'Euro',
        decimals: 2,
      ),
      AssetDto(
        id: 'asset_rub',
        kind: 'fiat',
        code: 'RUB',
        name: 'Russian Ruble',
        decimals: 2,
      ),
      AssetDto(
        id: 'asset_gbp',
        kind: 'fiat',
        code: 'GBP',
        name: 'British Pound',
        decimals: 2,
      ),
      AssetDto(
        id: 'asset_jpy',
        kind: 'fiat',
        code: 'JPY',
        name: 'Japanese Yen',
        decimals: 0,
      ),
      AssetDto(
        id: 'asset_chf',
        kind: 'fiat',
        code: 'CHF',
        name: 'Swiss Franc',
        decimals: 2,
      ),
      AssetDto(
        id: 'asset_btc',
        kind: 'crypto',
        code: 'BTC',
        name: 'Bitcoin',
        decimals: 8,
      ),
      AssetDto(
        id: 'asset_eth',
        kind: 'crypto',
        code: 'ETH',
        name: 'Ethereum',
        decimals: 18,
      ),
      AssetDto(
        id: 'asset_usdt',
        kind: 'crypto',
        code: 'USDT',
        name: 'Tether',
        decimals: 6,
      ),
    ];
  }
}
