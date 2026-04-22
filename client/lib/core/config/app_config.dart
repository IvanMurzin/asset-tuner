import 'package:flutter/foundation.dart';

final class AppConfig {
  AppConfig._({
    required this.env,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.oauthRedirectUri,
    required this.isOtpEnabled,
    required this.revenueCatApiKey,
    required this.termsOfUseUrl,
    required this.privacyPolicyUrl,
    required this.logApiResponses,
  });

  static AppConfig? _instance;
  static const _requiredStringKeys = <String>[
    'ENV',
    'SUPABASE_URL',
    'SUPABASE_ANON_KEY',
    'OAUTH_REDIRECT_URI',
    'TERMS_OF_USE_URL',
    'PRIVACY_POLICY_URL',
  ];

  static AppConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError(
        'AppConfig not initialized. Call AppConfig.init() before accessing instance.',
      );
    }
    return config;
  }

  final String env;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String oauthRedirectUri;
  final bool isOtpEnabled;
  final String revenueCatApiKey;
  final String termsOfUseUrl;
  final String privacyPolicyUrl;
  final bool logApiResponses;

  static void init() {
    _instance = requireFromEnvironment();
  }

  static AppConfig? tryFromEnvironment() {
    final stringValues = _readStringEnvironment();
    if (_missingRequiredStringKeys(stringValues).isNotEmpty) {
      return null;
    }
    final revenueCatApiKey = _resolveRevenueCatApiKey(stringValues);
    if (revenueCatApiKey == null) {
      return null;
    }
    final logApiResponses = const bool.fromEnvironment('LOG_API_RESPONSES', defaultValue: false);
    final isOtpEnabled = const bool.fromEnvironment('IS_OTP_ENABLED', defaultValue: false);
    return AppConfig._(
      env: stringValues['ENV']!,
      supabaseUrl: stringValues['SUPABASE_URL']!,
      supabaseAnonKey: stringValues['SUPABASE_ANON_KEY']!,
      oauthRedirectUri: stringValues['OAUTH_REDIRECT_URI']!,
      isOtpEnabled: isOtpEnabled,
      revenueCatApiKey: revenueCatApiKey,
      termsOfUseUrl: stringValues['TERMS_OF_USE_URL']!,
      privacyPolicyUrl: stringValues['PRIVACY_POLICY_URL']!,
      logApiResponses: logApiResponses,
    );
  }

  static AppConfig requireFromEnvironment() {
    final config = tryFromEnvironment();
    if (config == null) {
      final missingKeys = _missingRequiredStringKeys(_readStringEnvironment());
      final hasRevenueCatKey = _resolveRevenueCatApiKey(_readStringEnvironment()) != null;
      final missingKeySuffix = hasRevenueCatKey
          ? missingKeys.join(', ')
          : [
              ...missingKeys,
              'REVENUECAT_API_KEY (or REVENUECAT_API_KEY_ANDROID/REVENUECAT_API_KEY_IOS)',
            ].join(', ');
      throw StateError(
        'Missing app config keys: $missingKeySuffix. '
        'Provide required keys via --dart-define-from-file.',
      );
    }
    return config;
  }

  static Map<String, String> _readStringEnvironment() {
    return {
      'ENV': const String.fromEnvironment('ENV'),
      'SUPABASE_URL': const String.fromEnvironment('SUPABASE_URL'),
      'SUPABASE_ANON_KEY': const String.fromEnvironment('SUPABASE_ANON_KEY'),
      'OAUTH_REDIRECT_URI': const String.fromEnvironment('OAUTH_REDIRECT_URI'),
      'REVENUECAT_API_KEY': const String.fromEnvironment('REVENUECAT_API_KEY'),
      'REVENUECAT_API_KEY_ANDROID': const String.fromEnvironment('REVENUECAT_API_KEY_ANDROID'),
      'REVENUECAT_API_KEY_IOS': const String.fromEnvironment('REVENUECAT_API_KEY_IOS'),
      'REVENUECAT_API_KEY_TEST': const String.fromEnvironment('REVENUECAT_API_KEY_TEST'),
      'TERMS_OF_USE_URL': const String.fromEnvironment('TERMS_OF_USE_URL'),
      'PRIVACY_POLICY_URL': const String.fromEnvironment('PRIVACY_POLICY_URL'),
    };
  }

  static String? _resolveRevenueCatApiKey(Map<String, String> stringValues) {
    final genericKey = stringValues['REVENUECAT_API_KEY']?.trim() ?? '';
    if (!_isMissingValue(genericKey)) {
      return genericKey;
    }

    final androidKey = stringValues['REVENUECAT_API_KEY_ANDROID']?.trim() ?? '';
    final iosKey = stringValues['REVENUECAT_API_KEY_IOS']?.trim() ?? '';
    final testKey = stringValues['REVENUECAT_API_KEY_TEST']?.trim() ?? '';

    final platformKey = switch (defaultTargetPlatform) {
      TargetPlatform.android => androidKey,
      TargetPlatform.iOS => iosKey,
      _ => '',
    };
    if (!_isMissingValue(platformKey)) {
      return platformKey;
    }

    if (!_isMissingValue(androidKey)) {
      return androidKey;
    }
    if (!_isMissingValue(iosKey)) {
      return iosKey;
    }
    if (!_isMissingValue(testKey)) {
      return testKey;
    }
    return null;
  }

  static List<String> _missingRequiredStringKeys(Map<String, String> stringValues) {
    return _requiredStringKeys
        .where((key) => _isMissingValue(stringValues[key]))
        .toList(growable: false);
  }

  static bool _isMissingValue(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return true;
    }
    if (normalized == 'replace_me') {
      return true;
    }
    return normalized.toUpperCase().contains('YOUR_');
  }
}
