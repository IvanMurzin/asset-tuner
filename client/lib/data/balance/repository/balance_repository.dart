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
    required String subaccountId,
    required int limit,
    String? cursor,
  }) async {
    try {
      final response = await _dataSource.fetchHistory(
        subaccountId: subaccountId,
        limit: limit,
        cursor: cursor,
      );

      logger.i(
        'BalanceRepository.fetchHistory success: ${response.items.length}',
      );
      return Success(
        BalanceHistoryPageEntity(
          entries: response.items.map(BalanceEntryMapper.toEntity).toList(),
          nextCursor: response.nextCursor,
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
    required String subaccountId,
    required DateTime entryDate,
    required Decimal snapshotAmount,
  }) async {
    try {
      final dto = await _dataSource.updateBalance(
        subaccountId: subaccountId,
        entryDate: entryDate,
        snapshotAmount: snapshotAmount,
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
    required Set<String> subaccountIds,
  }) async {
    try {
      if (subaccountIds.isEmpty) {
        return const Success(<String, Decimal>{});
      }
      final dtos = await _dataSource.fetchEntriesForPositions(subaccountIds);

      final bySubaccount = <String, List<BalanceEntryDto>>{};
      for (final dto in dtos) {
        (bySubaccount[dto.subaccountId] ??= []).add(dto);
      }

      final result = <String, Decimal>{};
      for (final subaccountId in subaccountIds) {
        final entries = bySubaccount[subaccountId] ?? const <BalanceEntryDto>[];
        if (entries.isEmpty) {
          result[subaccountId] = Decimal.zero;
          continue;
        }
        final latest = BalanceEntryMapper.toEntity(entries.last);
        result[subaccountId] = latest.snapshotAmount;
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
