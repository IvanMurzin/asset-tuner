import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/domain/profile/entity/plan.dart';

part 'entitlements_entity.freezed.dart';

@freezed
abstract class EntitlementsEntity with _$EntitlementsEntity {
  const EntitlementsEntity._();

  const factory EntitlementsEntity({
    Plan? plan,
    int? maxAccounts,
    int? maxSubaccounts,
    int? fiatLimit,
    int? cryptoLimit,
  }) = _EntitlementsEntity;

  bool get anyBaseCurrency => fiatLimit == null;
}
