import 'package:asset_tuner/core/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig RevenueCat key resolution', () {
    test('uses the test key for dev Android builds', () {
      final key = AppConfig.resolveRevenueCatApiKeyFor(
        stringValues: _revenueCatKeys(),
        flavor: AppFlavor.dev,
        targetPlatform: TargetPlatform.android,
      );

      expect(key, 'test-key');
    });

    test('uses the test key for dev iOS builds', () {
      final key = AppConfig.resolveRevenueCatApiKeyFor(
        stringValues: _revenueCatKeys(),
        flavor: AppFlavor.dev,
        targetPlatform: TargetPlatform.iOS,
      );

      expect(key, 'test-key');
    });

    test('uses the Android key for prod Android builds', () {
      final key = AppConfig.resolveRevenueCatApiKeyFor(
        stringValues: _revenueCatKeys(),
        flavor: AppFlavor.prod,
        targetPlatform: TargetPlatform.android,
      );

      expect(key, 'android-key');
    });

    test('uses the iOS key for prod iOS builds', () {
      final key = AppConfig.resolveRevenueCatApiKeyFor(
        stringValues: _revenueCatKeys(),
        flavor: AppFlavor.prod,
        targetPlatform: TargetPlatform.iOS,
      );

      expect(key, 'ios-key');
    });

    test('ignores the legacy generic key', () {
      final key = AppConfig.resolveRevenueCatApiKeyFor(
        stringValues: _revenueCatKeys(android: 'replace_me', generic: 'legacy-key'),
        flavor: AppFlavor.prod,
        targetPlatform: TargetPlatform.android,
      );

      expect(key, isNull);
    });

    test('does not fall back to another platform key for prod desktop builds', () {
      final key = AppConfig.resolveRevenueCatApiKeyFor(
        stringValues: _revenueCatKeys(),
        flavor: AppFlavor.prod,
        targetPlatform: TargetPlatform.macOS,
      );

      expect(key, isNull);
    });
  });
}

Map<String, String> _revenueCatKeys({
  String test = 'test-key',
  String android = 'android-key',
  String ios = 'ios-key',
  String? generic,
}) {
  return {
    if (generic != null) 'REVENUECAT_API_KEY': generic,
    'REVENUECAT_API_KEY_TEST': test,
    'REVENUECAT_API_KEY_ANDROID': android,
    'REVENUECAT_API_KEY_IOS': ios,
  };
}
