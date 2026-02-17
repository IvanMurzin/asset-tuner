import 'package:asset_tuner/domain/entitlement/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';

const freeEntitlements = EntitlementsEntity(
  maxAccounts: 5,
  maxSubaccounts: 20,
  anyBaseCurrency: false,
  freeBaseCurrencyCodes: {'USD', 'EUR', 'RUB'},
);

const paidEntitlements = EntitlementsEntity(
  maxAccounts: 999,
  maxSubaccounts: 9999,
  anyBaseCurrency: true,
  freeBaseCurrencyCodes: <String>{},
);

ProfileEntity freeProfile({String baseCurrency = 'USD'}) {
  return ProfileEntity(baseCurrency: baseCurrency, plan: 'free', entitlements: freeEntitlements);
}

ProfileEntity paidProfile({String baseCurrency = 'USD'}) {
  return ProfileEntity(baseCurrency: baseCurrency, plan: 'paid', entitlements: paidEntitlements);
}
