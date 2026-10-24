import 'package:asset_tuner/presentation/auth/bloc/auth_cubit.dart';
import 'package:asset_tuner/presentation/paywall/bloc/paywall_cubit.dart';
import 'package:asset_tuner/presentation/profile/bloc/profile_cubit.dart';

/// What the paywall shows under its header. The offer needs a RevenueCat identity and a loaded
/// profile; until then one of the prerequisite states is shown.
sealed class PaywallBody {
  const PaywallBody();
}

final class PaywallBodyIdentityError extends PaywallBody {
  const PaywallBodyIdentityError(this.message);

  final String? message;
}

final class PaywallBodyProfileLoading extends PaywallBody {
  const PaywallBodyProfileLoading();
}

final class PaywallBodyProfileError extends PaywallBody {
  const PaywallBodyProfileError(this.message);

  final String? message;
}

/// Already Pro with nothing in flight: the paywall is being dismissed.
final class PaywallBodyClosing extends PaywallBody {
  const PaywallBodyClosing();
}

/// The store offer could not be loaded; [storeUnavailable] means the device cannot buy at all.
final class PaywallBodyOfferingsUnavailable extends PaywallBody {
  const PaywallBodyOfferingsUnavailable({required this.storeUnavailable});

  final bool storeUnavailable;
}

final class PaywallBodyOffer extends PaywallBody {
  const PaywallBodyOffer();
}

PaywallBody resolvePaywallBody({
  required AuthState auth,
  required ProfileState profile,
  required PaywallState paywall,
}) {
  if (!auth.isRevenueCatReady) {
    return PaywallBodyIdentityError(auth.revenueCatFailureMessage);
  }
  if (!profile.isReady) {
    return switch (profile.status) {
      ProfileStatus.initial || ProfileStatus.loading => const PaywallBodyProfileLoading(),
      ProfileStatus.ready || ProfileStatus.error => PaywallBodyProfileError(profile.failureMessage),
    };
  }
  if (profile.isPro && paywall.status == PaywallStatus.ready) {
    return const PaywallBodyClosing();
  }
  return switch (paywall.offerings) {
    PaywallOfferings.loading || PaywallOfferings.loaded => const PaywallBodyOffer(),
    PaywallOfferings.storeUnavailable => const PaywallBodyOfferingsUnavailable(
      storeUnavailable: true,
    ),
    PaywallOfferings.failed => const PaywallBodyOfferingsUnavailable(storeUnavailable: false),
  };
}
