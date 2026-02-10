import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AccountStorage {
  static const _key = 'accounts';

  Future<List<StoredAccount>> readAccounts(String userId) async {
    final data = await _readAll();
    final jsonList = data[userId];
    if (jsonList == null) {
      return [];
    }
    return jsonList.map(StoredAccount.fromJson).toList();
  }

  Future<void> writeAccounts(
    String userId,
    List<StoredAccount> accounts,
  ) async {
    final data = await _readAll();
    data[userId] = accounts.map((a) => a.toJson()).toList();
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

class StoredAccount {
  const StoredAccount({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.archived,
    required this.createdAtIso,
    required this.updatedAtIso,
  });

  final String id;
  final String userId;
  final String name;
  final String type;
  final bool archived;
  final String createdAtIso;
  final String updatedAtIso;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'archived': archived,
      'createdAtIso': createdAtIso,
      'updatedAtIso': updatedAtIso,
    };
  }

  static StoredAccount fromJson(Map<String, dynamic> json) {
    return StoredAccount(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      archived: json['archived'] as bool,
      createdAtIso: json['createdAtIso'] as String,
      updatedAtIso: json['updatedAtIso'] as String,
    );
  }
}
