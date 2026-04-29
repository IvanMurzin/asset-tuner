import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:asset_tuner/core/local_storage/onboarding_carousel_storage.dart';

@lazySingleton
class OnboardingCarouselGate {
  OnboardingCarouselGate(this._storage);

  final OnboardingCarouselStorage _storage;
  final ValueNotifier<bool> _completed = ValueNotifier<bool>(false);

  ValueListenable<bool> get listenable => _completed;
  bool get isCompleted => _completed.value;

  Future<void> loadInitial() async {
    _completed.value = await _storage.getCompleted();
  }

  Future<void> markCompleted() async {
    await _storage.setCompleted();
    _completed.value = true;
  }
}
