import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AccountAssetStorage {
  static const _key = 'account_assets';

  Future<List<StoredAccountAsset>> readAccountAssets(String userId) async {
    final data = await _readAll();
    final jsonList = data[userId];
    if (jsonList == null) {
      return [];
    }
    return jsonList.map(StoredAccountAsset.fromJson).toList();
  }

  Future<void> writeAccountAssets(
    String userId,
    List<StoredAccountAsset> assets,
  ) async {
    final data = await _readAll();
    data[userId] = assets.map((a) => a.toJson()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<void> deleteAllForUser(String userId) async {
    final data = await _readAll();
    data.remove(userId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<Map<String, List<Map<String, dynamic>>>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      return {};
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).map((e) => e as Map<String, dynamic>).toList(),
      ),
    );
  }
}

class StoredAccountAsset {
  const StoredAccountAsset({
    required this.id,
    required this.accountId,
    required this.assetId,
    required this.createdAtIso,
    this.sortOrder,
  });

  final String id;
  final String accountId;
  final String assetId;
  final String createdAtIso;
  final int? sortOrder;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'assetId': assetId,
      'createdAtIso': createdAtIso,
      'sortOrder': sortOrder,
    };
  }

  static StoredAccountAsset fromJson(Map<String, dynamic> json) {
    return StoredAccountAsset(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      assetId: json['assetId'] as String,
      createdAtIso: json['createdAtIso'] as String,
      sortOrder: json['sortOrder'] as int?,
    );
  }
}
