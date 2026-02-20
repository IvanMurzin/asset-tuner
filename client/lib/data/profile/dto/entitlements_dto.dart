import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/json_name.dart';

part 'entitlements_dto.freezed.dart';
part 'entitlements_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class EntitlementsDto with _$EntitlementsDto {
  const factory EntitlementsDto({
    String? plan,
    @JsonName('max_accounts') int? maxAccounts,
    @JsonName('max_subaccounts') int? maxSubaccounts,
    @JsonName('fiat_limit') int? fiatLimit,
    @JsonName('crypto_limit') int? cryptoLimit,
  }) = _EntitlementsDto;

  factory EntitlementsDto.fromJson(Map<String, dynamic> json) {
    return _$EntitlementsDtoFromJson(json);
  }
}
