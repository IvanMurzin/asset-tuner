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
    final logApiResponses = const bool.fromEnvironment(
      'LOG_API_RESPONSES',
      defaultValue: false,
    );
    final isOtpEnabled = const bool.fromEnvironment(
      'IS_OTP_ENABLED',
      defaultValue: false,
    );
    return AppConfig._(
      env: stringValues['ENV']!,
      supabaseUrl: stringValues['SUPABASE_URL']!,
      supabaseAnonKey: stringValues['SUPABASE_ANON_KEY']!,
      oauthRedirectUri: stringValues['OAUTH_REDIRECT_URI']!,
      isOtpEnabled: isOtpEnabled,
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
    return {
      'ENV': const String.fromEnvironment('ENV'),
      'SUPABASE_URL': const String.fromEnvironment('SUPABASE_URL'),
      'SUPABASE_ANON_KEY': const String.fromEnvironment('SUPABASE_ANON_KEY'),
      'OAUTH_REDIRECT_URI': const String.fromEnvironment('OAUTH_REDIRECT_URI'),
      'REVENUECAT_API_KEY': const String.fromEnvironment('REVENUECAT_API_KEY'),
      'TERMS_OF_USE_URL': const String.fromEnvironment('TERMS_OF_USE_URL'),
      'PRIVACY_POLICY_URL': const String.fromEnvironment('PRIVACY_POLICY_URL'),
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
