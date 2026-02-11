import 'dart:async';

import 'package:flutter/material.dart';
import 'package:asset_tuner/app.dart';
import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/di/di.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/supabase/supabase_initializer.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      final config = AppConfig.requireFromEnvironment();
      await SupabaseInitializer.init(config);
      await configureDependencies();

      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      logger.i('locale_active: ${locale.toLanguageTag()}');

      FlutterError.onError = (details) {
        logger.e('Flutter error:', error: details, stackTrace: details.stack);
        FlutterError.presentError(details);
      };

      runApp(const App());
    },
    (error, stackTrace) =>
        logger.e('Unhandled exception:', error: error, stackTrace: stackTrace),
  );
}
