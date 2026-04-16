import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/presentation/asset/widget/asset_currency_search_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssetCurrencySearchIndex', () {
    final assets = [
      _asset(id: 'fiat-usd', kind: AssetKind.fiat, code: 'USD', name: 'US Dollar'),
      _asset(id: 'fiat-eur', kind: AssetKind.fiat, code: 'EUR', name: 'Euro'),
      _asset(id: 'crypto-usdt', kind: AssetKind.crypto, code: 'USDT', name: 'Tether USD'),
    ];

    test('returns full list for empty query', () {
      final index = AssetCurrencySearchIndex(assets);

      final result = index.filter('');

      expect(result.map((asset) => asset.id), ['fiat-usd', 'fiat-eur', 'crypto-usdt']);
    });

    test('filters by code and name case-insensitively', () {
      final index = AssetCurrencySearchIndex(assets);

      final byCode = index.filter('usdt');
      final byName = index.filter('dollar');

      expect(byCode.map((asset) => asset.id), ['crypto-usdt']);
      expect(byName.map((asset) => asset.id), ['fiat-usd']);
    });

    test('supports multi-token query', () {
      final index = AssetCurrencySearchIndex(assets);

      final result = index.filter('usd tether');

      expect(result.map((asset) => asset.id), ['crypto-usdt']);
    });
  });
}

AssetEntity _asset({
  required String id,
  required AssetKind kind,
  required String code,
  required String name,
}) {
  return AssetEntity(
    id: id,
    kind: kind,
    code: code,
    name: name,
    provider: '',
    providerRef: '',
    rank: 1,
    decimals: 2,
    isActive: true,
    isLocked: false,
  );
}
