import 'package:injectable/injectable.dart';
import 'package:asset_tuner/data/currency/dto/currency_dto.dart';

@lazySingleton
class CurrencyMockDataSource {
  Future<List<CurrencyDto>> fetchFiatCurrencies() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const [
      CurrencyDto(code: 'USD', name: 'United States Dollar', symbol: 'USD'),
      CurrencyDto(code: 'EUR', name: 'Euro', symbol: 'EUR'),
      CurrencyDto(code: 'RUB', name: 'Russian Ruble', symbol: 'RUB'),
      CurrencyDto(code: 'GBP', name: 'British Pound', symbol: 'GBP'),
      CurrencyDto(code: 'JPY', name: 'Japanese Yen', symbol: 'JPY'),
      CurrencyDto(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF'),
    ];
  }
}
