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

  /// Pro has a numeric `fiat_limit` (the catalog size), so the plan decides, not a null limit
  /// (QA-021).
  bool get anyBaseCurrency => plan == Plan.pro || fiatLimit == null;
}
