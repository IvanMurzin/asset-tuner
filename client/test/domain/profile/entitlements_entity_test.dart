import 'package:asset_tuner/domain/profile/entity/entitlements_entity.dart';
import 'package:asset_tuner/domain/profile/entity/plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Pro unlocks any base currency even with a numeric fiat limit (QA-021)', () {
    expect(const EntitlementsEntity(plan: Plan.pro, fiatLimit: 100).anyBaseCurrency, isTrue);
    expect(const EntitlementsEntity(plan: Plan.free, fiatLimit: 5).anyBaseCurrency, isFalse);
    expect(const EntitlementsEntity().anyBaseCurrency, isTrue);
  });
}
