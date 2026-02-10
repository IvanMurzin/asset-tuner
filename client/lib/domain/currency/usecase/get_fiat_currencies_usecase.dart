import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/currency/entity/currency_entity.dart';
import 'package:asset_tuner/domain/currency/repository/i_currency_repository.dart';

@injectable
class GetFiatCurrenciesUseCase {
  GetFiatCurrenciesUseCase(this._repository);

  final ICurrencyRepository _repository;

  Future<Result<List<CurrencyEntity>>> call() {
    return _repository.fetchFiatCurrencies();
  }
}
