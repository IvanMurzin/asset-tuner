import 'package:freezed_annotation/freezed_annotation.dart';

part 'entitlements_entity.freezed.dart';

@freezed
abstract class EntitlementsEntity with _$EntitlementsEntity {
  const factory EntitlementsEntity({
    required int maxAccounts,
    required int maxSubaccounts,
    required bool anyBaseCurrency,
    required Set<String> freeBaseCurrencyCodes,
    DateTime? expiresAt,
  }) = _EntitlementsEntity;
}
