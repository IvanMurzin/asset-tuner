import 'package:asset_tuner/domain/entitlement/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';

const freeEntitlements = EntitlementsEntity(
  plan: 'free',
  maxAccounts: 5,
  maxSubaccounts: 20,
  fiatLimit: 5,
  cryptoLimit: 5,
);

const paidEntitlements = EntitlementsEntity(
  plan: 'pro',
  maxAccounts: 999,
  maxSubaccounts: 9999,
);

AssetEntity _baseAsset(String code) {
  return AssetEntity(
    id: '${code.toLowerCase()}-asset',
    kind: AssetKind.fiat,
    code: code,
    name: code,
  );
}

ProfileEntity freeProfile({String baseCurrency = 'USD'}) {
  return ProfileEntity(
    baseAsset: _baseAsset(baseCurrency),
    plan: 'free',
    entitlements: freeEntitlements,
  );
}

ProfileEntity paidProfile({String baseCurrency = 'USD'}) {
  return ProfileEntity(
    baseAsset: _baseAsset(baseCurrency),
    plan: 'pro',
    entitlements: paidEntitlements,
  );
}
