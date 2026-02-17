import 'package:asset_tuner/l10n/supabase_error_localization_en.dart';
import 'package:asset_tuner/l10n/supabase_error_localization_ru.dart';

enum SupportedLanguage { en, ru }

extension SupportedLanguageExtension on SupportedLanguage {
  String get code {
    switch (this) {
      case SupportedLanguage.en:
        return 'en';
      case SupportedLanguage.ru:
        return 'ru';
    }
  }

  static SupportedLanguage fromCode(String code) {
    switch (code) {
      case 'en':
        return SupportedLanguage.en;
      case 'ru':
        return SupportedLanguage.ru;
      default:
        return SupportedLanguage.en;
    }
  }
}

class SupabaseErrorTranslator {
  static SupportedLanguage _currentLanguage = SupportedLanguage.en;
  static late Map<String, dynamic> _translations;
  static const _fallbackTranslations = supabaseErrorLocalizationEn;

  static void setLanguage(SupportedLanguage language) {
    _currentLanguage = language;
    _translations = switch (language) {
      SupportedLanguage.en => supabaseErrorLocalizationEn,
      SupportedLanguage.ru => supabaseErrorLocalizationRu,
    };
  }

  static String translate(String? errorCode) {
    final normalizedCode = (errorCode?.trim().isEmpty ?? true)
        ? 'unknown_error'
        : errorCode!.trim();

    String? translation = _translations[normalizedCode] as String?;

    if (translation != null) {
      return translation;
    }

    final genericMessage =
        _fallbackTranslations[_currentLanguage.code]?['unknown_error'] as String? ??
        _fallbackTranslations['unknown_error'] as String? ??
        'An unknown error occurred';

    if (genericMessage.isNotEmpty) {
      return genericMessage;
    }

    return _fallbackTranslations['unknown_error'] as String? ?? 'An unknown error occurred';
  }
}
