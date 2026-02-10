import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asset_tuner/app.dart';
import 'package:asset_tuner/core/di/get_it.dart';
import 'package:asset_tuner/core/di/injectable.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await getIt.reset();
    initDependencies();
  });

  testWidgets('App shows English strings for en locale', (tester) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('en')];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('App shows Russian strings for ru locale', (tester) async {
    tester.binding.platformDispatcher.localesTestValue = const [Locale('ru')];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Вход'), findsWidgets);
  });
}
