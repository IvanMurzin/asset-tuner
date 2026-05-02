import 'package:flutter/foundation.dart';

import 'package:asset_tuner/core/local_storage/onboarding_carousel_gate.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/guards/route_guard.dart';

/// Guards the first-run onboarding carousel ("welcome tour").
///
/// While the user has not finished the carousel, no other route is reachable.
/// Once the carousel is completed, if the user somehow lands on the carousel
/// page again, we send them to a neutral auth route; the [AuthRouteGuard]
/// then decides whether they end up on `/sign-in` or `/main`.
class OnboardingRouteGuard implements RouteGuard {
  OnboardingRouteGuard(this._gate);

  final OnboardingCarouselGate _gate;

  @override
  Listenable? get listenable => _gate.listenable;

  @override
  String? redirect(String location) {
    if (!_gate.isCompleted) {
      return location == AppRoutes.onboardingCarousel ? null : AppRoutes.onboardingCarousel;
    }
    if (location == AppRoutes.onboardingCarousel) {
      return AppRoutes.signIn;
    }
    return null;
  }
}
