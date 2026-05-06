import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:asset_tuner/core/local_storage/onboarding_carousel_gate.dart';
import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/guards/auth_route_guard.dart';
import 'package:asset_tuner/core/routing/guards/onboarding_route_guard.dart';
import 'package:asset_tuner/core/routing/guards/route_guard.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';

/// Tests guard composition against a real GoRouter instance.
/// Routes are replaced with minimal stubs so the focus stays on redirect
/// behaviour: which URL the user ends up on after bootstrap, sign-in,
/// sign-out, token expiry, deep links, etc.
void main() {
  group('App router (guards composition)', () {
    testWidgets('cold start: carousel NOT completed → /onboarding/carousel', (t) async {
      final ctx = _Ctx(carousel: false);
      await _pump(t, ctx);

      ctx.auth.resolveAuthenticated();
      await t.pumpAndSettle();

      expect(ctx.currentLocation, AppRoutes.onboardingCarousel);
    });

    testWidgets('cold start: carousel completed + unauthenticated → /sign-in', (t) async {
      final ctx = _Ctx(carousel: true, initialLocation: AppRoutes.splash);
      await _pump(t, ctx);

      ctx.auth.resolveUnauthenticated();
      await t.pumpAndSettle();

      expect(ctx.currentLocation, AppRoutes.signIn);
    });

    testWidgets('cold start: carousel completed + already authenticated → /main', (t) async {
      final ctx = _Ctx(carousel: true, initialLocation: AppRoutes.splash);
      await _pump(t, ctx);

      ctx.auth.resolveAuthenticated();
      await t.pumpAndSettle();

      expect(ctx.currentLocation, AppRoutes.main);
    });

    testWidgets('login: emitting a session while on /sign-in → automatic /main', (t) async {
      final ctx = _Ctx(carousel: true, initialLocation: AppRoutes.signIn);
      await _pump(t, ctx);
      ctx.auth.resolveUnauthenticated();
      await t.pumpAndSettle();
      expect(ctx.currentLocation, AppRoutes.signIn);

      ctx.auth.resolveAuthenticated();
      await t.pumpAndSettle();

      expect(ctx.currentLocation, AppRoutes.main);
    });

    testWidgets('logout: signing out from /main → automatic /sign-in', (t) async {
      final ctx = _Ctx(carousel: true, initialLocation: AppRoutes.signIn);
      await _pump(t, ctx);
      ctx.auth.resolveAuthenticated();
      await t.pumpAndSettle();

      ctx.auth.resolveUnauthenticated();
      await t.pumpAndSettle();

      expect(ctx.currentLocation, AppRoutes.signIn);
    });

    testWidgets('deep link: /main without auth → /sign-in', (t) async {
      final ctx = _Ctx(carousel: true, initialLocation: AppRoutes.main);
      await _pump(t, ctx);
      ctx.auth.resolveUnauthenticated();
      await t.pumpAndSettle();

      expect(ctx.currentLocation, AppRoutes.signIn);
    });

    testWidgets('deep link: /sign-in while authenticated → /main', (t) async {
      final ctx = _Ctx(carousel: true, initialLocation: AppRoutes.signIn);
      await _pump(t, ctx);
      ctx.auth.resolveAuthenticated();
      await t.pumpAndSettle();

      expect(ctx.currentLocation, AppRoutes.main);
    });

    testWidgets(
      'deep link: /onboarding/carousel after completion → /sign-up (or /main if authed)',
      (t) async {
        final ctx = _Ctx(carousel: true, initialLocation: AppRoutes.onboardingCarousel);
        await _pump(t, ctx);
        ctx.auth.resolveUnauthenticated();
        await t.pumpAndSettle();
        expect(ctx.currentLocation, AppRoutes.signUp);

        ctx.auth.resolveAuthenticated();
        await t.pumpAndSettle();
        expect(ctx.currentLocation, AppRoutes.main);
      },
    );

    testWidgets('deep link: /main + carousel NOT completed → /onboarding/carousel', (t) async {
      final ctx = _Ctx(carousel: false, initialLocation: AppRoutes.main);
      await _pump(t, ctx);
      ctx.auth.resolveAuthenticated();
      await t.pumpAndSettle();

      expect(ctx.currentLocation, AppRoutes.onboardingCarousel);
    });

    testWidgets('finishing the carousel: gate.markCompleted() pulls user into auth flow', (
      t,
    ) async {
      final ctx = _Ctx(carousel: false);
      await _pump(t, ctx);
      ctx.auth.resolveUnauthenticated();
      await t.pumpAndSettle();
      expect(ctx.currentLocation, AppRoutes.onboardingCarousel);

      await ctx.gate.markCompleted();
      await t.pumpAndSettle();
      expect(ctx.currentLocation, AppRoutes.signUp);
    });

    testWidgets('while auth.initial — private initial route is held on /splash', (t) async {
      final ctx = _Ctx(carousel: true, initialLocation: AppRoutes.main);
      await _pump(t, ctx);
      // No resolve — auth stays in the initial state.

      expect(ctx.currentLocation, AppRoutes.splash);
    });
  });
}

class _Ctx {
  _Ctx({required bool carousel, String? initialLocation})
    : gate = _FakeGate(initial: carousel),
      auth = _FakeAuthCubit(),
      _initialLocation =
          initialLocation ?? (carousel ? AppRoutes.splash : AppRoutes.onboardingCarousel);

  final _FakeGate gate;
  final _FakeAuthCubit auth;
  final String _initialLocation;
  late final GoRouter router = _buildRouter();

  String get currentLocation => router.routerDelegate.currentConfiguration.uri.path;

  GoRouter _buildRouter() {
    final guards = <RouteGuard>[OnboardingRouteGuard(gate), AuthRouteGuard(auth)];
    final listenables = guards
        .map((g) => g.listenable)
        .whereType<Listenable>()
        .toList(growable: false);

    return GoRouter(
      initialLocation: _initialLocation,
      refreshListenable: listenables.isEmpty ? null : Listenable.merge(listenables),
      redirect: (context, state) {
        final loc = state.matchedLocation;
        for (final g in guards) {
          final r = g.redirect(loc);
          if (r != null && r != loc) return r;
        }
        return null;
      },
      routes: [
        _StubRoute(AppRoutes.signIn, 'SIGN_IN'),
        _StubRoute(AppRoutes.signUp, 'SIGN_UP'),
        _StubRoute(AppRoutes.otp, 'OTP'),
        _StubRoute(AppRoutes.onboardingCarousel, 'CAROUSEL'),
        _StubRoute(AppRoutes.splash, 'SPLASH'),
        _StubRoute(AppRoutes.main, 'MAIN'),
        _StubRoute(AppRoutes.profile, 'PROFILE'),
        _StubRoute(AppRoutes.paywall, 'PAYWALL'),
      ],
    );
  }
}

class _StubRoute extends GoRoute {
  _StubRoute(String path, String tag) : super(path: path, builder: _build, name: tag);

  static Widget _build(BuildContext context, GoRouterState state) =>
      Scaffold(body: Text(state.matchedLocation));
}

Future<void> _pump(WidgetTester t, _Ctx ctx) {
  return t.pumpWidget(MaterialApp.router(routerConfig: ctx.router));
}

class _FakeGate implements OnboardingCarouselGate {
  _FakeGate({required bool initial}) : _notifier = ValueNotifier(initial);

  final ValueNotifier<bool> _notifier;

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

class _FakeAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _FakeAuthCubit() : super(const AuthState());

  void resolveUnauthenticated() => emit(const AuthState(status: AuthStatus.unauthenticated));
  void resolveAuthenticated() => emit(
    const AuthState(
      status: AuthStatus.authenticated,
      session: AuthSessionEntity(userId: 'u', email: 'a@b.dev'),
    ),
  );

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> syncRevenueCat() async {}

  @override
  Future<void> forceLocalSignOut() async {}
}
