import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/currency/data_source/currency_mock_data_source.dart';
import 'package:asset_tuner/data/currency/mapper/currency_mapper.dart';
import 'package:asset_tuner/domain/currency/entity/currency_entity.dart';
import 'package:asset_tuner/domain/currency/repository/i_currency_repository.dart';

@LazySingleton(as: ICurrencyRepository)
class CurrencyRepository implements ICurrencyRepository {
  CurrencyRepository(this._dataSource);

  final CurrencyMockDataSource _dataSource;

  @override
  Future<Result<List<CurrencyEntity>>> fetchFiatCurrencies() async {
    try {
      final dtos = await _dataSource.fetchFiatCurrencies();
      final entities = dtos.map(CurrencyMapper.toEntity).toList();
      logger.i(
        'CurrencyRepository.fetchFiatCurrencies success: ${entities.length}',
      );
      return Success(entities);
    } catch (_) {
      logger.e('CurrencyRepository.fetchFiatCurrencies failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to load currencies'),
      );
    }
  }
}
