import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class ProfileStorage {
  static const _key = 'profiles';

  Future<StoredProfile?> readProfile(String userId) async {
    final data = await _readAll();
    final json = data[userId];
    if (json == null) {
      return null;
    }
    return StoredProfile.fromJson(json);
  }

  Future<void> writeProfile(StoredProfile profile) async {
    final data = await _readAll();
    data[profile.userId] = profile.toJson();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<void> deleteProfile(String userId) async {
    final data = await _readAll();
    data.remove(userId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<Map<String, Map<String, dynamic>>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      return {};
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, value as Map<String, dynamic>),
    );
  }
}

class StoredProfile {
  const StoredProfile({
    required this.userId,
    required this.baseCurrency,
    required this.plan,
  });

  final String userId;
  final String baseCurrency;
  final String plan;

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'baseCurrency': baseCurrency, 'plan': plan};
  }

  static StoredProfile fromJson(Map<String, dynamic> json) {
    return StoredProfile(
      userId: json['userId'] as String,
      baseCurrency: json['baseCurrency'] as String,
      plan: json['plan'] as String,
    );
  }
}
