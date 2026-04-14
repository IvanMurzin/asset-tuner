import 'dart:ui';

import 'package:asset_tuner/core/local_storage/locale_storage.dart';
import 'package:asset_tuner/core/localization/system_locale_provider.dart';
import 'package:asset_tuner/core/supabase/supabase_error_translator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'locale_cubit.freezed.dart';
part 'locale_state.dart';

@lazySingleton
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this._storage, this._systemLocaleProvider) : super(const LocaleState());

  final LocaleStorage _storage;
  final ISystemLocaleProvider _systemLocaleProvider;

  Future<void> load() async {
    final storedTag = await _storage.readLocaleTag();
    final normalizedStoredTag = _normalizeTag(storedTag);
    if (storedTag != null && normalizedStoredTag == null) {
      await _storage.writeLocaleTag(null);
    }
    final effectiveTag =
        normalizedStoredTag ??
        _normalizeTag(_systemLocaleProvider.getCurrentLocale().languageCode) ??
        'en';
    emit(state.copyWith(localeTag: normalizedStoredTag));
    SupabaseErrorTranslator.setLanguage(SupportedLanguageExtension.fromCode(effectiveTag));
  }

  Future<void> setLocale(Locale? locale) async {
    final tag = _normalizeTag(locale?.languageCode);
    await _storage.writeLocaleTag(tag);
    emit(state.copyWith(localeTag: tag));
    final effectiveTag =
        tag ?? _normalizeTag(_systemLocaleProvider.getCurrentLocale().languageCode) ?? 'en';
    SupabaseErrorTranslator.setLanguage(SupportedLanguageExtension.fromCode(effectiveTag));
  }

  Locale? get locale {
    final tag = state.localeTag;
    if (tag == null) {
      return null;
    }
    return Locale.fromSubtags(languageCode: tag);
  }

  String? _normalizeTag(String? tag) {
    final normalized = tag?.trim().toLowerCase();
    if (normalized == 'en') {
      return 'en';
    }
    if (normalized == 'ru') {
      return 'ru';
    }
    return null;
  }
}
