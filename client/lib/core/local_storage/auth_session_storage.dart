import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class AuthSessionStorage {
  static const _key = 'auth_session';

  Future<StoredAuthSession?> readSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      return null;
    }
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return StoredAuthSession.fromJson(data);
  }

  Future<void> writeSession(StoredAuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(session.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class StoredAuthSession {
  const StoredAuthSession({required this.userId, required this.email});

  final String userId;
  final String email;

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'email': email};
  }

  static StoredAuthSession fromJson(Map<String, dynamic> json) {
    return StoredAuthSession(
      userId: json['userId'] as String,
      email: json['email'] as String,
    );
  }
}
