import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

@lazySingleton
class RevenueCatService {
  Future<Offerings> getOfferings() {
    return Purchases.getOfferings();
  }

  Future<PurchaseResult> purchasePackage(Package package) {
    return Purchases.purchase(PurchaseParams.package(package));
  }

  Future<CustomerInfo> restorePurchases() {
    return Purchases.restorePurchases();
  }

  Future<LogInResult> logIn(String appUserId) {
    return Purchases.logIn(appUserId);
  }

  Future<CustomerInfo> logOut() {
    return Purchases.logOut();
  }

  Future<CustomerInfo> getCustomerInfo() {
    return Purchases.getCustomerInfo();
  }
}
