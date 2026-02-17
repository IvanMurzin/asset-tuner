part of 'paywall_cubit.dart';

enum PaywallStatus { loading, ready, error }

enum PaywallDestination { closeUpgraded }

@freezed
abstract class PaywallNavigation with _$PaywallNavigation {
  const factory PaywallNavigation(PaywallDestination destination) = _PaywallNavigation;
}

@freezed
abstract class PaywallState with _$PaywallState {
  const factory PaywallState({
    @Default(PaywallStatus.loading) PaywallStatus status,
    String? plan,
    @Default(PaywallPlanOption.annual) PaywallPlanOption selectedPlan,
    @Default(false) bool entitlementsUnverified,
    String? loadFailureCode,
    String? loadFailureMessage,
    String? upgradeFailureCode,
    String? upgradeFailureMessage,
    @Default(false) bool isUpdating,
    PaywallNavigation? navigation,
  }) = _PaywallState;
}
