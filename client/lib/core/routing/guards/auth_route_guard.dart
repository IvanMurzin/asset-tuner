import 'package:flutter/foundation.dart';

import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/go_router_refresh_stream.dart';
import 'package:asset_tuner/core/routing/guards/route_guard.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';

/// Auth guard: the single owner of "can the user see private routes, and
/// where should we send misrouted users".
///
/// Logic:
/// - while session is `initial` (the auth stream has not produced anything
///   yet) — stay out of the way; native splash still covers the Flutter UI;
/// - unauthenticated user on any non-public route → `/sign-in`;
/// - authenticated user landing inside the auth flow (sign-in/sign-up/otp)
///   → `/main`.
///
/// Everything else (carousel, paywall, etc.) is the responsibility of other
/// guards in the chain.
class AuthRouteGuard implements RouteGuard {
  AuthRouteGuard(this._auth);

  final AuthCubit _auth;

  late final Listenable _listenable = GoRouterRefreshStream(_auth.stream);

  @override
  Listenable? get listenable => _listenable;

  @override
  String? redirect(String location) {
    final state = _auth.state;
    if (!state.isResolved) {
      return null;
    }

    if (!state.isAuthenticated) {
      // Public routes only (auth flow + onboarding carousel). Carousel is
      // owned by [OnboardingRouteGuard]; we deliberately do not interfere.
      return AppRoutes.publicLocations.contains(location) ? null : AppRoutes.signIn;
    }

    // Kick authenticated users out of auth-only screens. Other public paths
    // (onboarding) are handled by their own guard.
    if (AppRoutes.authFlowLocations.contains(location)) {
      return AppRoutes.main;
    }
    return null;
  }
}
