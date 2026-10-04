import 'package:purchases_flutter/purchases_flutter.dart';

Offerings offeringsWithAnnual() {
  const context = PresentedOfferingContext('default', null, null);
  const annual = Package(
    r'$rc_annual',
    PackageType.annual,
    StoreProduct('pro_annual', 'Pro', 'Pro', 29.99, r'$29.99', 'USD'),
    context,
  );
  const offering = Offering('default', 'Default', {}, [annual], annual: annual);
  return const Offerings({'default': offering}, current: offering);
}

class FakeCustomerInfo implements CustomerInfo {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
