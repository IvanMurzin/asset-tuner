final class AppConfig {
  AppConfig._({
    required this.env,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.googleIosClientId,
    required this.googleAndroidClientId,
    required this.appleServiceId,
    required this.appleRedirectUri,
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
    'GOOGLE_IOS_CLIENT_ID',
    'GOOGLE_ANDROID_CLIENT_ID',
    'APPLE_SERVICE_ID',
    'APPLE_REDIRECT_URI',
    'REVENUECAT_API_KEY',
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
  final String googleIosClientId;
  final String googleAndroidClientId;
  final String appleServiceId;
  final String appleRedirectUri;
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
    final logApiResponses = const bool.fromEnvironment(
      'LOG_API_RESPONSES',
      defaultValue: false,
    );
    return AppConfig._(
      env: stringValues['ENV']!,
      supabaseUrl: stringValues['SUPABASE_URL']!,
      supabaseAnonKey: stringValues['SUPABASE_ANON_KEY']!,
      googleIosClientId: stringValues['GOOGLE_IOS_CLIENT_ID']!,
      googleAndroidClientId: stringValues['GOOGLE_ANDROID_CLIENT_ID']!,
      appleServiceId: stringValues['APPLE_SERVICE_ID']!,
      appleRedirectUri: stringValues['APPLE_REDIRECT_URI']!,
      revenueCatApiKey: stringValues['REVENUECAT_API_KEY']!,
      termsOfUseUrl: stringValues['TERMS_OF_USE_URL']!,
      privacyPolicyUrl: stringValues['PRIVACY_POLICY_URL']!,
      logApiResponses: logApiResponses,
    );
  }

  static AppConfig requireFromEnvironment() {
    final config = tryFromEnvironment();
    if (config == null) {
      final missingKeys = _missingRequiredStringKeys(_readStringEnvironment());
      throw StateError(
        'Missing app config keys: ${missingKeys.join(', ')}. '
        'Provide required keys via --dart-define-from-file.',
      );
    }
    return config;
  }

  static Map<String, String> _readStringEnvironment() {
    return const {
      'ENV': String.fromEnvironment('ENV'),
      'SUPABASE_URL': String.fromEnvironment('SUPABASE_URL'),
      'SUPABASE_ANON_KEY': String.fromEnvironment('SUPABASE_ANON_KEY'),
      'GOOGLE_IOS_CLIENT_ID': String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
      'GOOGLE_ANDROID_CLIENT_ID': String.fromEnvironment(
        'GOOGLE_ANDROID_CLIENT_ID',
      ),
      'APPLE_SERVICE_ID': String.fromEnvironment('APPLE_SERVICE_ID'),
      'APPLE_REDIRECT_URI': String.fromEnvironment('APPLE_REDIRECT_URI'),
      'REVENUECAT_API_KEY': String.fromEnvironment('REVENUECAT_API_KEY'),
      'TERMS_OF_USE_URL': String.fromEnvironment('TERMS_OF_USE_URL'),
      'PRIVACY_POLICY_URL': String.fromEnvironment('PRIVACY_POLICY_URL'),
    };
  }

  static List<String> _missingRequiredStringKeys(
    Map<String, String> stringValues,
  ) {
    return _requiredStringKeys
        .where((key) => stringValues[key]?.trim().isEmpty ?? true)
        .toList(growable: false);
  }
}
