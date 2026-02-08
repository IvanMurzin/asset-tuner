import 'dart:async';

import 'package:flutter/material.dart';
import 'package:template/app.dart';
import 'package:template/core/di/di.dart';
import 'package:template/core/logger/logger.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await configureDependencies();

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
