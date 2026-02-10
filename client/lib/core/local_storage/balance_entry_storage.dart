import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class BalanceEntryStorage {
  static const _key = 'balance_entries';

  Future<List<StoredBalanceEntry>> readEntries(String userId) async {
    final data = await _readAll();
    final jsonList = data[userId];
    if (jsonList == null) {
      return [];
    }
    return jsonList.map(StoredBalanceEntry.fromJson).toList();
  }

  Future<void> writeEntries(
    String userId,
    List<StoredBalanceEntry> entries,
  ) async {
    final data = await _readAll();
    data[userId] = entries.map((e) => e.toJson()).toList();
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

class StoredBalanceEntry {
  const StoredBalanceEntry({
    required this.id,
    required this.accountAssetId,
    required this.entryDateIso,
    required this.entryType,
    this.snapshotAmount,
    this.deltaAmount,
    this.impliedDeltaAmount,
    required this.createdAtIso,
  });

  final String id;
  final String accountAssetId;
  final String entryDateIso;
  final String entryType;
  final String? snapshotAmount;
  final String? deltaAmount;
  final String? impliedDeltaAmount;
  final String createdAtIso;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountAssetId': accountAssetId,
      'entryDateIso': entryDateIso,
      'entryType': entryType,
      'snapshotAmount': snapshotAmount,
      'deltaAmount': deltaAmount,
      'impliedDeltaAmount': impliedDeltaAmount,
      'createdAtIso': createdAtIso,
    };
  }

  static StoredBalanceEntry fromJson(Map<String, dynamic> json) {
    return StoredBalanceEntry(
      id: json['id'] as String,
      accountAssetId: json['accountAssetId'] as String,
      entryDateIso: json['entryDateIso'] as String,
      entryType: json['entryType'] as String,
      snapshotAmount: json['snapshotAmount'] as String?,
      deltaAmount: json['deltaAmount'] as String?,
      impliedDeltaAmount: json['impliedDeltaAmount'] as String?,
      createdAtIso: json['createdAtIso'] as String,
    );
  }
}
