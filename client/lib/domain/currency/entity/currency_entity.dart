import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency_entity.freezed.dart';

@freezed
abstract class CurrencyEntity with _$CurrencyEntity {
  const factory CurrencyEntity({
    required String code,
    required String name,
    required String symbol,
  }) = _CurrencyEntity;
}
