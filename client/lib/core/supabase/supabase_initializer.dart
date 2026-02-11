import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:asset_tuner/core/config/app_config.dart';

abstract final class SupabaseInitializer {
  static Future<void> init(AppConfig config) {
    final debug = config.env.toLowerCase() == 'dev';
    return Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
      debug: debug,
    );
  }
}
