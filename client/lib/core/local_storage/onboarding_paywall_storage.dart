import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPaywallStorage {
  static const _key = 'onboarding_paywall_seen';

  Future<bool> getSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> setSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
