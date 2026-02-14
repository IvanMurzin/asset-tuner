import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/local_storage/locale_storage.dart';

part 'locale_cubit.freezed.dart';
part 'locale_state.dart';

@lazySingleton
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this._storage) : super(const LocaleState());

  final LocaleStorage _storage;

  Future<void> load() async {
    final tag = await _storage.readLocaleTag();
    final effectiveTag = tag ?? 'en';
    if (tag == null) {
      await _storage.writeLocaleTag('en');
    }
    emit(state.copyWith(localeTag: effectiveTag));
  }

  Future<void> setSystem() async {
    await _storage.writeLocaleTag(null);
    emit(state.copyWith(localeTag: null));
  }

  Future<void> setLocale(Locale locale) async {
    final tag = locale.toLanguageTag();
    await _storage.writeLocaleTag(tag);
    emit(state.copyWith(localeTag: tag));
  }

  Locale? get locale {
    final tag = state.localeTag;
    if (tag == null) {
      return null;
    }
    return Locale.fromSubtags(languageCode: tag.split('-').first);
  }
}
