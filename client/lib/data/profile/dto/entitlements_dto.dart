import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/json_name.dart';

part 'entitlements_dto.freezed.dart';
part 'entitlements_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class EntitlementsDto with _$EntitlementsDto {
  const factory EntitlementsDto({
    @JsonName('max_accounts') required int maxAccounts,
    @JsonName('max_positions') required int maxPositions,
    @JsonName('any_base_currency') required bool anyBaseCurrency,
    @JsonName('allowed_base_currency_codes')
    @Default(<String>[])
    List<String> allowedBaseCurrencyCodes,
    @JsonName('expires_at') String? expiresAtIso,
  }) = _EntitlementsDto;

  factory EntitlementsDto.fromJson(Map<String, dynamic> json) {
    return _$EntitlementsDtoFromJson(json);
  }
}
