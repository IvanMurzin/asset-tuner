enum PaywallReason {
  onboarding,
  accountsLimit,
  subaccountsLimit,
  baseCurrency,
  manageSubscription,
  upgrade,
  subaccountCurrency,
}

class PaywallArgs {
  const PaywallArgs({required this.reason});

  final PaywallReason reason;
}

enum PaywallPlanOption { monthly, annual }
