enum PaywallReason { accountsLimit, positionsLimit, baseCurrency }

class PaywallArgs {
  const PaywallArgs({required this.reason, this.requestedBaseCurrencyCode});

  final PaywallReason reason;
  final String? requestedBaseCurrencyCode;
}

enum PaywallPlanOption { monthly, annual }
