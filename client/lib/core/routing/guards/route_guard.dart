import 'package:flutter/foundation.dart';

/// One atomic piece of navigation logic that owns a single concern (auth,
/// onboarding, paywall, etc.).
///
/// A guard:
/// - inspects the current location and decides whether to redirect,
/// - exposes a [Listenable] whose changes must re-trigger the redirect chain.
///
/// `redirect` contract:
/// - return `null` if the guard does not want to interfere,
/// - return a path to send the user there.
///
/// Guards are evaluated in a fixed order. The first guard returning a non-null
/// path wins; go_router then re-runs the whole chain after the redirect, so
/// guards compose naturally without having to coordinate with each other.
abstract interface class RouteGuard {
  String? redirect(String location);

  Listenable? get listenable;
}
