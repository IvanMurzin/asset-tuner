import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AssetRatesStorage {
  static const _key = 'asset_rates_usd_latest';

  Future<Map<String, StoredAssetRateUsd>> readRates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      return {};
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        StoredAssetRateUsd.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  Future<void> writeRates(Map<String, StoredAssetRateUsd> rates) async {
    final prefs = await SharedPreferences.getInstance();
    final json = rates.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_key, jsonEncode(json));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class StoredAssetRateUsd {
  const StoredAssetRateUsd({
    required this.assetId,
    required this.usdPrice,
    required this.asOfIso,
  });

  final String assetId;
  final String usdPrice;
  final String asOfIso;

  Map<String, dynamic> toJson() {
    return {'assetId': assetId, 'usdPrice': usdPrice, 'asOfIso': asOfIso};
  }

  static StoredAssetRateUsd fromJson(Map<String, dynamic> json) {
    return StoredAssetRateUsd(
      assetId: json['assetId'] as String,
      usdPrice: json['usdPrice'] as String,
      asOfIso: json['asOfIso'] as String,
    );
  }
}
