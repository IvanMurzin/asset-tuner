import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asset_tuner/core/local_storage/onboarding_carousel_gate.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/guards/onboarding_route_guard.dart';

void main() {
  group('OnboardingRouteGuard', () {
    test('carousel NOT completed — all paths except the carousel redirect to it', () {
      final gate = _FakeGate(initial: false);
      final guard = OnboardingRouteGuard(gate);

      expect(guard.redirect(AppRoutes.signIn), AppRoutes.onboardingCarousel);
      expect(guard.redirect(AppRoutes.signUp), AppRoutes.onboardingCarousel);
      expect(guard.redirect(AppRoutes.main), AppRoutes.onboardingCarousel);
      expect(guard.redirect('/main/accounts/abc'), AppRoutes.onboardingCarousel);

      expect(guard.redirect(AppRoutes.onboardingCarousel), isNull);
    });

    test('carousel completed — on the carousel page redirects to /sign-up', () {
      final gate = _FakeGate(initial: true);
      final guard = OnboardingRouteGuard(gate);

      expect(guard.redirect(AppRoutes.onboardingCarousel), AppRoutes.signUp);
      expect(guard.redirect(AppRoutes.signIn), isNull);
      expect(guard.redirect(AppRoutes.main), isNull);
    });

    test('listenable fires when the flag flips', () async {
      final gate = _FakeGate(initial: false);
      final guard = OnboardingRouteGuard(gate);
      var ticks = 0;
      guard.listenable!.addListener(() => ticks += 1);

      gate.flip(true);
      expect(ticks, 1);
    });
  });
}

class _FakeGate implements OnboardingCarouselGate {
  _FakeGate({required bool initial}) : _notifier = ValueNotifier(initial);

  final ValueNotifier<bool> _notifier;

  void flip(bool value) => _notifier.value = value;

  @override
  ValueListenable<bool> get listenable => _notifier;

  @override
  bool get isCompleted => _notifier.value;

  @override
  Future<void> loadInitial() async {}

  @override
  Future<void> markCompleted() async {
    _notifier.value = true;
  }
}
