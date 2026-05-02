import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asset_tuner/core/native_splash/native_splash_controller.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';

void main() {
  group('NativeSplashController', () {
    test('removes splash on the first non-initial emit', () async {
      var calls = 0;
      final controller = NativeSplashController(splashRemover: () => calls += 1);
      final cubit = _StubAuth(const AuthState());
      addTearDown(cubit.close);

      controller.attach(cubit);
      expect(calls, 0);

      cubit.set(const AuthState(status: AuthStatus.unauthenticated));
      await Future<void>.delayed(Duration.zero);
      expect(calls, 1);
    });

    test('repeated emits do not call remove() again', () async {
      var calls = 0;
      final controller = NativeSplashController(splashRemover: () => calls += 1);
      final cubit = _StubAuth(const AuthState());
      addTearDown(cubit.close);

      controller.attach(cubit);
      cubit.set(const AuthState(status: AuthStatus.unauthenticated));
      await Future<void>.delayed(Duration.zero);
      cubit.set(
        const AuthState(
          status: AuthStatus.authenticated,
          session: AuthSessionEntity(userId: 'u', email: 'a@b.dev'),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(calls, 1);
    });

    test('if the cubit is already resolved at attach time — removes splash immediately', () {
      var calls = 0;
      final controller = NativeSplashController(splashRemover: () => calls += 1);
      final cubit = _StubAuth(const AuthState(status: AuthStatus.unauthenticated));
      addTearDown(cubit.close);

      controller.attach(cubit);
      expect(calls, 1);
    });

    test('a throwing splashRemover does not crash the controller', () async {
      final controller = NativeSplashController(splashRemover: () => throw StateError('no splash'));
      final cubit = _StubAuth(const AuthState());
      addTearDown(cubit.close);

      controller.attach(cubit);
      cubit.set(const AuthState(status: AuthStatus.unauthenticated));
      await Future<void>.delayed(Duration.zero);
      // must not throw
    });

    test('dispose cancels the subscription (later emits do not call remove)', () async {
      var calls = 0;
      final controller = NativeSplashController(splashRemover: () => calls += 1);
      final cubit = _StubAuth(const AuthState());
      addTearDown(cubit.close);

      controller.attach(cubit);
      controller.dispose();

      cubit.set(const AuthState(status: AuthStatus.unauthenticated));
      await Future<void>.delayed(Duration.zero);
      expect(calls, 0);
    });
  });
}

class _StubAuth extends Cubit<AuthState> implements AuthCubit {
  _StubAuth(super.s);

  void set(AuthState s) => emit(s);

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
