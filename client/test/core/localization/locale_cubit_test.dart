import 'dart:ui';

import 'package:asset_tuner/core/local_storage/locale_storage.dart';
import 'package:asset_tuner/core/localization/locale_cubit.dart';
import 'package:asset_tuner/core/localization/system_locale_provider.dart';
import 'package:asset_tuner/core/supabase/supabase_error_translator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleCubit', () {
    late LocaleStorage storage;
    LocaleCubit? cubit;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = LocaleStorage();
      SupabaseErrorTranslator.setLanguage(SupportedLanguage.en);
    });

    tearDown(() async {
      await cubit?.close();
    });

    test('uses system locale when no override is stored', () async {
      cubit = LocaleCubit(storage, _FakeSystemLocaleProvider(const Locale('ru', 'GE')));

      await cubit!.load();

      final prefs = await SharedPreferences.getInstance();
      expect(cubit!.state.localeTag, isNull);
      expect(cubit!.locale, isNull);
      expect(prefs.getString('locale_override'), isNull);
      expect(SupabaseErrorTranslator.translate('unknown_error'), contains('неизвестная ошибка'));
    });

    test('restores explicit override and keeps it across restart', () async {
      SharedPreferences.setMockInitialValues({'locale_override': 'en'});
      cubit = LocaleCubit(storage, _FakeSystemLocaleProvider(const Locale('ru')));

      await cubit!.load();

      expect(cubit!.state.localeTag, 'en');
      expect(cubit!.locale?.languageCode, 'en');
      expect(
        SupabaseErrorTranslator.translate('unknown_error'),
        contains('An unknown error occurred'),
      );
    });

    test('reset to system removes override from storage', () async {
      SharedPreferences.setMockInitialValues({'locale_override': 'en'});
      cubit = LocaleCubit(storage, _FakeSystemLocaleProvider(const Locale('ru')));

      await cubit!.load();
      await cubit!.setLocale(null);

      final prefs = await SharedPreferences.getInstance();
      expect(cubit!.state.localeTag, isNull);
      expect(prefs.getString('locale_override'), isNull);
      expect(SupabaseErrorTranslator.translate('unknown_error'), contains('неизвестная ошибка'));
    });

    test('cleans invalid stored override and falls back to system locale', () async {
      SharedPreferences.setMockInitialValues({'locale_override': 'en-US'});
      cubit = LocaleCubit(storage, _FakeSystemLocaleProvider(const Locale('ru')));

      await cubit!.load();

      final prefs = await SharedPreferences.getInstance();
      expect(cubit!.state.localeTag, isNull);
      expect(cubit!.locale, isNull);
      expect(prefs.getString('locale_override'), isNull);
      expect(SupabaseErrorTranslator.translate('unknown_error'), contains('неизвестная ошибка'));
    });
  });
}

class _FakeSystemLocaleProvider implements ISystemLocaleProvider {
  const _FakeSystemLocaleProvider(this.locale);

  final Locale locale;

  @override
  Locale getCurrentLocale() => locale;
}
