import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class LocaleStorage {
  static const _key = 'locale_override';

  Future<String?> readLocaleTag() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> writeLocaleTag(String? localeTag) async {
    final prefs = await SharedPreferences.getInstance();
    if (localeTag == null) {
      await prefs.remove(_key);
      return;
    }
    await prefs.setString(_key, localeTag);
  }
}
