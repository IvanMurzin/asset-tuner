import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/balance/data_source/supabase_balance_data_source.dart';
import 'package:asset_tuner/data/balance/dto/balance_entry_dto.dart';
import 'package:asset_tuner/data/balance/mapper/balance_entry_mapper.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_history_page_entity.dart';
import 'package:asset_tuner/domain/balance/repository/i_balance_repository.dart';

@LazySingleton(as: IBalanceRepository)
class BalanceRepository implements IBalanceRepository {
  BalanceRepository(this._dataSource);

  final SupabaseBalanceDataSource _dataSource;

  @override
  Future<Result<BalanceHistoryPageEntity>> fetchHistory({
    required String accountAssetId,
    required int limit,
    int? offset,
  }) async {
    try {
      final start = offset ?? 0;
      final pageDtos = await _dataSource.fetchHistory(
        accountAssetId: accountAssetId,
        limit: limit,
        offset: start,
      );
      final nextOffset = pageDtos.length == limit ? start + limit : null;

      logger.i('BalanceRepository.fetchHistory success: ${pageDtos.length}');
      return Success(
        BalanceHistoryPageEntity(
          entries: pageDtos.map(BalanceEntryMapper.toEntity).toList(),
          nextOffset: nextOffset,
        ),
      );
    } catch (error) {
      logger.e('BalanceRepository.fetchHistory failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to load history',
        ),
      );
    }
  }

  @override
  Future<Result<BalanceEntryEntity>> updateBalance({
    required String accountAssetId,
    required DateTime entryDate,
    Decimal? snapshotAmount,
    Decimal? deltaAmount,
  }) async {
    try {
      final dto = await _dataSource.updateBalance(
        accountAssetId: accountAssetId,
        entryDate: entryDate,
        snapshotAmount: snapshotAmount,
        deltaAmount: deltaAmount,
      );
      logger.i('BalanceRepository.updateBalance success');
      return Success(BalanceEntryMapper.toEntity(dto));
    } catch (error) {
      logger.e('BalanceRepository.updateBalance failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to save balance',
        ),
      );
    }
  }

  @override
  Future<Result<Map<String, Decimal>>> fetchCurrentBalances({
    required Set<String> accountAssetIds,
  }) async {
    try {
      if (accountAssetIds.isEmpty) {
        return const Success(<String, Decimal>{});
      }
      final dtos = await _dataSource.fetchEntriesForPositions(accountAssetIds);

      final byPosition = <String, List<BalanceEntryDto>>{};
      for (final dto in dtos) {
        (byPosition[dto.accountAssetId] ??= []).add(dto);
      }

      final result = <String, Decimal>{};
      for (final positionId in accountAssetIds) {
        final entries = byPosition[positionId] ?? const <BalanceEntryDto>[];
        var balance = Decimal.zero;
        for (final dto in entries) {
          if (dto.entryType == 'snapshot') {
            if (dto.snapshotAmount != null) {
              balance = Decimal.parse(dto.snapshotAmount!);
            }
            continue;
          }
          if (dto.entryType == 'delta') {
            if (dto.deltaAmount != null) {
              balance += Decimal.parse(dto.deltaAmount!);
            }
          }
        }
        result[positionId] = balance;
      }
      logger.i(
        'BalanceRepository.fetchCurrentBalances success: ${result.length}',
      );
      return Success(result);
    } catch (error) {
      logger.e('BalanceRepository.fetchCurrentBalances failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to compute balances',
        ),
      );
    }
  }
}
