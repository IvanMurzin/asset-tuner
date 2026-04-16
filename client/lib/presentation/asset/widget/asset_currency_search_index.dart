import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';

class AssetCurrencySearchIndex {
  AssetCurrencySearchIndex(List<AssetEntity> assets)
    : _items = assets.map(_IndexedAsset.fromAsset).toList(growable: false);

  final List<_IndexedAsset> _items;

  List<AssetEntity> filter(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return _items.map((item) => item.asset).toList(growable: false);
    }
    final tokens = normalized.split(RegExp(r'\s+')).where((token) => token.isNotEmpty).toList();
    return _items
        .where((item) => item.matches(tokens))
        .map((item) => item.asset)
        .toList(growable: false);
  }
}

class _IndexedAsset {
  const _IndexedAsset({
    required this.asset,
    required this.code,
    required this.name,
    required this.combined,
  });

  final AssetEntity asset;
  final String code;
  final String name;
  final String combined;

  factory _IndexedAsset.fromAsset(AssetEntity asset) {
    final code = asset.code.toLowerCase();
    final name = asset.name.toLowerCase();
    return _IndexedAsset(asset: asset, code: code, name: name, combined: '$code $name');
  }

  bool matches(List<String> tokens) {
    for (final token in tokens) {
      if (!(code.contains(token) || name.contains(token) || combined.contains(token))) {
        return false;
      }
    }
    return true;
  }
}
