import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/currency/entity/currency_entity.dart';

abstract interface class ICurrencyRepository {
  Future<Result<List<CurrencyEntity>>> fetchFiatCurrencies();
}
