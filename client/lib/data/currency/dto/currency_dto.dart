import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency_dto.freezed.dart';
part 'currency_dto.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class CurrencyDto with _$CurrencyDto {
  const factory CurrencyDto({required String code, required String name, required String symbol}) =
      _CurrencyDto;

  factory CurrencyDto.fromJson(Map<String, dynamic> json) {
    return _$CurrencyDtoFromJson(json);
  }
}
