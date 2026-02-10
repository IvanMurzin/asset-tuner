import 'package:asset_tuner/data/currency/dto/currency_dto.dart';
import 'package:asset_tuner/domain/currency/entity/currency_entity.dart';

abstract final class CurrencyMapper {
  static CurrencyEntity toEntity(CurrencyDto dto) {
    return CurrencyEntity(code: dto.code, name: dto.name, symbol: dto.symbol);
  }
}
