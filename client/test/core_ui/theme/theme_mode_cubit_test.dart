import 'package:asset_tuner/core/local_storage/theme_mode_storage.dart';
import 'package:asset_tuner/core_ui/theme/theme_mode_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModeCubit', () {
    late ThemeModeStorage storage;
    final cubits = <ThemeModeCubit>[];

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = ThemeModeStorage();
    });

    tearDown(() async {
      for (final cubit in cubits) {
        await cubit.close();
      }
      cubits.clear();
    });

    test('defaults to system when no override is stored', () async {
      final cubit = ThemeModeCubit(storage);
      cubits.add(cubit);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      final prefs = await SharedPreferences.getInstance();
      expect(cubit.state, ThemeMode.system);
      expect(prefs.getString('theme_mode'), isNull);
    });

    test('restores explicit override from storage', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final cubit = ThemeModeCubit(storage);
      cubits.add(cubit);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state, ThemeMode.dark);
    });

    test('explicit reset to system stays persisted across restart', () async {
      final cubit = ThemeModeCubit(storage);
      cubits.add(cubit);

      cubit.set(ThemeMode.system);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final reloadedCubit = ThemeModeCubit(storage);
      cubits.add(reloadedCubit);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'system');
      expect(reloadedCubit.state, ThemeMode.system);
    });
  });
}
