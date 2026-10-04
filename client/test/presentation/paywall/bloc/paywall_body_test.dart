import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/profile/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/plan.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_body.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_cubit.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const _session = AuthSessionEntity(userId: 'u-1', email: 'u@example.com');
const _authReady = AuthState(
  status: AuthStatus.authenticated,
  session: _session,
  revenueCatStatus: RevenueCatIdentityStatus.synced,
  revenueCatUserId: 'u-1',
);

ProfileState _profile(Plan plan) => ProfileState(
  status: ProfileStatus.ready,
  profile: ProfileEntity(userId: 'u-1', plan: plan, entitlements: const EntitlementsEntity()),
);

void main() {
  PaywallBody resolve({
    AuthState auth = _authReady,
    ProfileState? profile,
    PaywallState paywall = const PaywallState(),
  }) => resolvePaywallBody(auth: auth, profile: profile ?? _profile(Plan.free), paywall: paywall);

  test('identity not ready → identity error with its message', () {
    final body = resolve(
      auth: _authReady.copyWith(
        revenueCatStatus: RevenueCatIdentityStatus.error,
        revenueCatFailureMessage: 'rc down',
      ),
    );
    expect(body, isA<PaywallBodyIdentityError>());
    expect((body as PaywallBodyIdentityError).message, 'rc down');
  });

  test('profile initial or loading → loading', () {
    expect(resolve(profile: const ProfileState()), isA<PaywallBodyProfileLoading>());
    expect(
      resolve(profile: const ProfileState(status: ProfileStatus.loading)),
      isA<PaywallBodyProfileLoading>(),
    );
  });

  test('profile error → profile error with its message', () {
    final body = resolve(
      profile: const ProfileState(status: ProfileStatus.error, failureMessage: 'boom'),
    );
    expect(body, isA<PaywallBodyProfileError>());
    expect((body as PaywallBodyProfileError).message, 'boom');
  });

  test('free user → offer', () {
    expect(resolve(), isA<PaywallBodyOffer>());
  });

  test('Pro with nothing in flight → closing; during a purchase → offer', () {
    expect(resolve(profile: _profile(Plan.pro)), isA<PaywallBodyClosing>());
    expect(
      resolve(
        profile: _profile(Plan.pro),
        paywall: const PaywallState(status: PaywallStatus.verifying),
      ),
      isA<PaywallBodyOffer>(),
    );
  });
}
