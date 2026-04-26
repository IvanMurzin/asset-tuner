enum PaywallReason { onboarding, accountsLimit, subaccountsLimit, baseCurrency, manageSubscription }

class PaywallArgs {
  const PaywallArgs({required this.reason, this.requestedBaseCurrencyCode});

  final PaywallReason reason;
  final String? requestedBaseCurrencyCode;
}

enum PaywallPlanOption { monthly, annual }
