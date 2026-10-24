part of 'paywall_cubit.dart';

enum PaywallStatus {
  ready,
  processing,

  /// The store reported success; the page syncs the profile and reports back via
  /// [PaywallCubit.onVerified].
  verifying,

  /// Terminal: the paywall must be closed. Reached at most once.
  done,

  /// Terminal: the store accepted a payment that settles later (e.g. a slow card). The paywall
  /// closes; Pro arrives through the regular subscription sync once the payment completes.
  pending,
}

/// Where the store offer stands; the paywall can only sell once it is [loaded].
enum PaywallOfferings {
  loading,
  loaded,

  /// The store refused: no store account or billing on the device.
  storeUnavailable,

  /// Loading failed for another reason, or the offering has no packages.
  failed,
}

@freezed
abstract class PaywallState with _$PaywallState {
  const PaywallState._();

  const factory PaywallState({
    @Default(PaywallStatus.ready) PaywallStatus status,
    @Default(PaywallOfferings.loading) PaywallOfferings offerings,
    Package? monthlyPackage,
    Package? annualPackage,
    @Default(PaywallPlanOption.annual) PaywallPlanOption selectedOption,
    String? failureCode,
    String? failureMessage,
  }) = _PaywallState;

  bool get isTerminal => status == PaywallStatus.done || status == PaywallStatus.pending;

  bool get isBusy =>
      status == PaywallStatus.processing || status == PaywallStatus.verifying || isTerminal;

  Package? get selectedPackage =>
      selectedOption == PaywallPlanOption.monthly ? monthlyPackage : annualPackage;

  bool get canContinue =>
      status == PaywallStatus.ready &&
      offerings == PaywallOfferings.loaded &&
      selectedPackage != null;
}
