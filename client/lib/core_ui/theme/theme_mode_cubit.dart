import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/local_storage/theme_mode_storage.dart';

@injectable
class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit(this._storage) : super(ThemeMode.system) {
    _load();
  }

  final ThemeModeStorage _storage;

  Future<void> _load() async {
    final stored = await _storage.readThemeMode();
    if (stored != null) {
      emit(stored);
    }
  }

  void toggle() {
    if (state == ThemeMode.dark) {
      set(ThemeMode.light);
    } else {
      set(ThemeMode.dark);
    }
  }

  void set(ThemeMode mode) {
    emit(mode);
    _storage.writeThemeMode(mode);
  }
}
