import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asset_tuner/core/routing/app_routes.dart';
import 'package:asset_tuner/core/routing/guards/auth_route_guard.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';

void main() {
  group('AuthRouteGuard', () {
    test('initial status — never redirects (native splash still on top)', () {
      final cubit = _StubAuthCubit(const AuthState());
      addTearDown(cubit.close);
      final guard = AuthRouteGuard(cubit);

      expect(guard.redirect(AppRoutes.signIn), isNull);
      expect(guard.redirect(AppRoutes.main), isNull);
      expect(guard.redirect('/some/deep/link'), isNull);
    });

    test('unauthenticated — redirects from private routes to sign-in', () {
      final cubit = _StubAuthCubit(const AuthState(status: AuthStatus.unauthenticated));
      addTearDown(cubit.close);
      final guard = AuthRouteGuard(cubit);

      expect(guard.redirect(AppRoutes.main), AppRoutes.signIn);
      expect(guard.redirect(AppRoutes.profile), AppRoutes.signIn);
      expect(guard.redirect(AppRoutes.paywall), AppRoutes.signIn);
      expect(guard.redirect('/main/accounts/abc'), AppRoutes.signIn);
    });

    test('unauthenticated — lets auth-flow paths through', () {
      final cubit = _StubAuthCubit(const AuthState(status: AuthStatus.unauthenticated));
      addTearDown(cubit.close);
      final guard = AuthRouteGuard(cubit);

      expect(guard.redirect(AppRoutes.signIn), isNull);
      expect(guard.redirect(AppRoutes.signUp), isNull);
      expect(guard.redirect(AppRoutes.otp), isNull);
    });

    test(
      'unauthenticated — does not interfere with /onboarding/carousel (owned by OnboardingGuard)',
      () {
        final cubit = _StubAuthCubit(const AuthState(status: AuthStatus.unauthenticated));
        addTearDown(cubit.close);
        final guard = AuthRouteGuard(cubit);

        expect(guard.redirect(AppRoutes.onboardingCarousel), isNull);
      },
    );

    test('authenticated — does not interfere with /onboarding/carousel', () {
      final cubit = _StubAuthCubit(_authed);
      addTearDown(cubit.close);
      final guard = AuthRouteGuard(cubit);

      expect(guard.redirect(AppRoutes.onboardingCarousel), isNull);
    });

    test('authenticated inside auth-flow — redirects to /main', () {
      final cubit = _StubAuthCubit(_authed);
      addTearDown(cubit.close);
      final guard = AuthRouteGuard(cubit);

      expect(guard.redirect(AppRoutes.signIn), AppRoutes.main);
      expect(guard.redirect(AppRoutes.signUp), AppRoutes.main);
      expect(guard.redirect(AppRoutes.otp), AppRoutes.main);
    });

    test('authenticated on private routes — passes through', () {
      final cubit = _StubAuthCubit(_authed);
      addTearDown(cubit.close);
      final guard = AuthRouteGuard(cubit);

      expect(guard.redirect(AppRoutes.main), isNull);
      expect(guard.redirect(AppRoutes.profile), isNull);
      expect(guard.redirect('/main/accounts/123'), isNull);
    });

    test('exposes a listenable that re-fires on state change', () async {
      final cubit = _StubAuthCubit(const AuthState());
      addTearDown(cubit.close);
      final guard = AuthRouteGuard(cubit);
      final listenable = guard.listenable!;

      var ticks = 0;
      listenable.addListener(() => ticks += 1);

      cubit.setState(_authed);
      // microtask delay — broadcast stream delivers asynchronously.
      await Future<void>.delayed(Duration.zero);
      expect(ticks, greaterThanOrEqualTo(1));
    });
  });
}

const _authed = AuthState(
  status: AuthStatus.authenticated,
  session: AuthSessionEntity(userId: 'u1', email: 'a@b.dev'),
);

class _StubAuthCubit extends Cubit<AuthState> implements AuthCubit {
  _StubAuthCubit(super.initialState);

  void setState(AuthState s) => emit(s);

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
