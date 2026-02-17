import 'dart:ui';

import 'package:asset_tuner/core/local_storage/locale_storage.dart';
import 'package:asset_tuner/core/supabase/supabase_error_translator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'locale_cubit.freezed.dart';
part 'locale_state.dart';

@lazySingleton
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this._storage) : super(const LocaleState());

  final LocaleStorage _storage;

  Future<void> load() async {
    final tag = await _storage.readLocaleTag();
    final effectiveTag = tag != null ? tag.split('-').first : 'en';
    if (tag == null || tag.contains('-')) {
      await _storage.writeLocaleTag(effectiveTag);
    }
    emit(state.copyWith(localeTag: effectiveTag));
    SupabaseErrorTranslator.setLanguage(SupportedLanguageExtension.fromCode(effectiveTag));
  }

  Future<void> setLocale(Locale locale) async {
    final tag = locale.languageCode;
    await _storage.writeLocaleTag(tag);
    emit(state.copyWith(localeTag: tag));
    SupabaseErrorTranslator.setLanguage(SupportedLanguageExtension.fromCode(tag));
  }

  Locale? get locale {
    final tag = state.localeTag;
    if (tag == null) {
      return null;
    }
    return Locale.fromSubtags(languageCode: tag);
  }
}
