final class AppConfig {
  const AppConfig({
    required this.env,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.revenueCatApiKey,
  });

  final String env;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String revenueCatApiKey;

  static AppConfig? tryFromEnvironment() {
    final env = const String.fromEnvironment('ENV');
    final supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
    final supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
    final revenueCatApiKey =
        const String.fromEnvironment('REVENUECAT_API_KEY');
    if (env.isEmpty ||
        supabaseUrl.isEmpty ||
        supabaseAnonKey.isEmpty ||
        revenueCatApiKey.isEmpty) {
      return null;
    }
    return AppConfig(
      env: env,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      revenueCatApiKey: revenueCatApiKey,
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
