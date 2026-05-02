import 'dart:async';

import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';

/// Removes the native splash screen as soon as the first auth state resolves.
///
/// "When to remove the splash" is a UX concern, hence it lives in core/
/// rather than inside [AuthCubit] (which is purely a domain auth-state
/// holder). The controller is a small stream listener over auth state and is
/// trivial to swap out or mock.
class NativeSplashController {
  NativeSplashController({SplashRemover? splashRemover})
    : _splashRemover = splashRemover ?? FlutterNativeSplash.remove;

  final SplashRemover _splashRemover;

  StreamSubscription<AuthState>? _subscription;
  bool _removed = false;

  /// Subscribes to the cubit. Removes the splash on the first non-initial
  /// emission. If the cubit is already resolved at attach time, removes the
  /// splash immediately.
  void attach(AuthCubit auth) {
    if (auth.state.isResolved) {
      _removeOnce();
      return;
    }
    _subscription ??= auth.stream.listen((state) {
      if (state.isResolved) {
        _removeOnce();
        unawaited(_subscription?.cancel());
        _subscription = null;
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _removeOnce() {
    if (_removed) return;
    _removed = true;
    try {
      _splashRemover();
    } catch (_) {
      // Splash already removed or never activated — fine for tests/hot reload.
    }
  }
}

typedef SplashRemover = void Function();
