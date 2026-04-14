import 'package:shared_preferences/shared_preferences.dart';

class GuidedTourStorage {
  static const _key = 'guided_tour_overview_completed';

  Future<bool> getCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> setCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
