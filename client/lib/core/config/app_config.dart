import 'package:flutter/foundation.dart';

enum AppFlavor {
  dev,
  prod;

  static AppFlavor fromString(String value) {
    final normalized = value.trim().toLowerCase();
    return AppFlavor.values.firstWhere(
      (flavor) => flavor.name == normalized,
      orElse: () => throw StateError('Unknown FLAVOR value "$value". Expected "dev" or "prod".'),
    );
  }
}

final class AppConfig {
  AppConfig._({
    required this.env,
    required this.flavor,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.oauthRedirectUri,
    required this.isOtpEnabled,
    required this.revenueCatApiKey,
    required this.termsOfUseUrl,
    required this.privacyPolicyUrl,
    required this.logApiResponses,
    required this.analyticsEnabled,
  });

  static AppConfig? _instance;
  static const _requiredStringKeys = <String>[
    'ENV',
    'FLAVOR',
    'SUPABASE_URL',
    'SUPABASE_PUBLISHABLE_KEY',
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
  final AppFlavor flavor;
  final String supabaseUrl;
  final String supabasePublishableKey;
  final String oauthRedirectUri;
  final bool isOtpEnabled;
  final String revenueCatApiKey;
  final String termsOfUseUrl;
  final String privacyPolicyUrl;
  final bool logApiResponses;
  final bool analyticsEnabled;

  bool get isProdRelease => flavor == AppFlavor.prod && kReleaseMode;

  bool get firebaseEnabled => flavor == AppFlavor.prod;

  bool get analyticsActive => firebaseEnabled && analyticsEnabled && kReleaseMode;

  static void init() {
    _instance = requireFromEnvironment();
  }

  static AppConfig? tryFromEnvironment() {
    final stringValues = _readStringEnvironment();
    if (_missingRequiredStringKeys(stringValues).isNotEmpty) {
      return null;
    }
    final flavor = AppFlavor.fromString(stringValues['FLAVOR']!);
    final revenueCatApiKey = resolveRevenueCatApiKeyFor(
      stringValues: stringValues,
      flavor: flavor,
      targetPlatform: defaultTargetPlatform,
    );
    if (revenueCatApiKey == null) {
      return null;
    }
    final logApiResponses = const bool.fromEnvironment('LOG_API_RESPONSES', defaultValue: false);
    final isOtpEnabled = const bool.fromEnvironment('IS_OTP_ENABLED', defaultValue: false);
    final analyticsEnabled = const bool.fromEnvironment('ANALYTICS_ENABLED', defaultValue: false);
    return AppConfig._(
      env: stringValues['ENV']!,
      flavor: flavor,
      supabaseUrl: stringValues['SUPABASE_URL']!,
      supabasePublishableKey: stringValues['SUPABASE_PUBLISHABLE_KEY']!,
      oauthRedirectUri: stringValues['OAUTH_REDIRECT_URI']!,
      isOtpEnabled: isOtpEnabled,
      revenueCatApiKey: revenueCatApiKey,
      termsOfUseUrl: stringValues['TERMS_OF_USE_URL']!,
      privacyPolicyUrl: stringValues['PRIVACY_POLICY_URL']!,
      logApiResponses: logApiResponses,
      analyticsEnabled: analyticsEnabled,
    );
  }

  static AppConfig requireFromEnvironment() {
    final config = tryFromEnvironment();
    if (config == null) {
      final stringValues = _readStringEnvironment();
      final missingKeys = _missingRequiredStringKeys(stringValues);
      final flavor = _tryReadFlavor(stringValues);
      final hasRevenueCatKey =
          flavor != null &&
          resolveRevenueCatApiKeyFor(
                stringValues: stringValues,
                flavor: flavor,
                targetPlatform: defaultTargetPlatform,
              ) !=
              null;
      final missingKeySuffix = hasRevenueCatKey
          ? missingKeys.join(', ')
          : [
              ...missingKeys,
              _revenueCatConfigKeyDescription(flavor, defaultTargetPlatform),
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
      'FLAVOR': const String.fromEnvironment('FLAVOR'),
      'SUPABASE_URL': const String.fromEnvironment('SUPABASE_URL'),
      'SUPABASE_PUBLISHABLE_KEY': const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
      'OAUTH_REDIRECT_URI': const String.fromEnvironment('OAUTH_REDIRECT_URI'),
      'REVENUECAT_API_KEY_ANDROID': const String.fromEnvironment('REVENUECAT_API_KEY_ANDROID'),
      'REVENUECAT_API_KEY_IOS': const String.fromEnvironment('REVENUECAT_API_KEY_IOS'),
      'REVENUECAT_API_KEY_TEST': const String.fromEnvironment('REVENUECAT_API_KEY_TEST'),
      'TERMS_OF_USE_URL': const String.fromEnvironment('TERMS_OF_USE_URL'),
      'PRIVACY_POLICY_URL': const String.fromEnvironment('PRIVACY_POLICY_URL'),
    };
  }

  @visibleForTesting
  static String? resolveRevenueCatApiKeyFor({
    required Map<String, String> stringValues,
    required AppFlavor flavor,
    required TargetPlatform targetPlatform,
  }) {
    final androidKey = stringValues['REVENUECAT_API_KEY_ANDROID']?.trim() ?? '';
    final iosKey = stringValues['REVENUECAT_API_KEY_IOS']?.trim() ?? '';
    final testKey = stringValues['REVENUECAT_API_KEY_TEST']?.trim() ?? '';

    if (flavor == AppFlavor.dev) {
      return _isMissingValue(testKey) ? null : testKey;
    }

    final platformKey = switch (targetPlatform) {
      TargetPlatform.android => androidKey,
      TargetPlatform.iOS => iosKey,
      _ => '',
    };
    return _isMissingValue(platformKey) ? null : platformKey;
  }

  static AppFlavor? _tryReadFlavor(Map<String, String> stringValues) {
    final rawFlavor = stringValues['FLAVOR'];
    if (_isMissingValue(rawFlavor)) {
      return null;
    }
    return AppFlavor.fromString(rawFlavor!);
  }

  static String _revenueCatConfigKeyDescription(AppFlavor? flavor, TargetPlatform targetPlatform) {
    if (flavor == AppFlavor.dev) {
      return 'REVENUECAT_API_KEY_TEST';
    }
    return switch (targetPlatform) {
      TargetPlatform.android => 'REVENUECAT_API_KEY_ANDROID',
      TargetPlatform.iOS => 'REVENUECAT_API_KEY_IOS',
      _ => 'REVENUECAT_API_KEY_ANDROID or REVENUECAT_API_KEY_IOS for Android/iOS builds',
    };
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
