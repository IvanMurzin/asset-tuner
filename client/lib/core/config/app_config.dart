final class AppConfig {
  AppConfig._({
    required this.env,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.revenueCatApiKey,
    required this.logApiResponses,
  });

  static AppConfig? _instance;

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
  final String revenueCatApiKey;
  final bool logApiResponses;

  static void init() {
    _instance = requireFromEnvironment();
  }

  static AppConfig? tryFromEnvironment() {
    final env = const String.fromEnvironment('ENV');
    final supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
    final supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
    final revenueCatApiKey = const String.fromEnvironment('REVENUECAT_API_KEY');
    final logApiResponses = const bool.fromEnvironment('LOG_API_RESPONSES', defaultValue: false);
    if (env.isEmpty || supabaseUrl.isEmpty || supabaseAnonKey.isEmpty || revenueCatApiKey.isEmpty) {
      return null;
    }
    return AppConfig._(
      env: env,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      revenueCatApiKey: revenueCatApiKey,
      logApiResponses: logApiResponses,
    );
  }

  static AppConfig requireFromEnvironment() {
    final config = tryFromEnvironment();
    if (config == null) {
      throw StateError(
        'Missing app config. Provide ENV, SUPABASE_URL, SUPABASE_ANON_KEY, REVENUECAT_API_KEY via --dart-define-from-file.',
      );
    }
    return config;
  }
}
