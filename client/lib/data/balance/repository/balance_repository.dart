import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/local_storage/balance_entry_storage.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/balance/dto/balance_entry_dto.dart';
import 'package:asset_tuner/data/balance/mapper/balance_entry_mapper.dart';
import 'package:asset_tuner/data/balance/service/i_update_balance_edge_function_service.dart';
import 'package:asset_tuner/data/balance/service/mock_update_balance_edge_function_service.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_history_page_entity.dart';
import 'package:asset_tuner/domain/balance/repository/i_balance_repository.dart';

@LazySingleton(as: IBalanceRepository)
class BalanceRepository implements IBalanceRepository {
  BalanceRepository(this._storage, this._edgeFunctions);

  final BalanceEntryStorage _storage;
  final IUpdateBalanceEdgeFunctionService _edgeFunctions;

  @override
  Future<Result<BalanceHistoryPageEntity>> fetchHistory({
    required String userId,
    required String accountAssetId,
    required int limit,
    int? offset,
  }) async {
    try {
      final allStored = await _storage.readEntries(userId);
      final allDtos =
          allStored
              .map(BalanceEntryMapper.toDto)
              .where((e) => e.accountAssetId == accountAssetId)
              .toList()
            ..sort(_sortDesc);

      final start = offset ?? 0;
      final page = allDtos.skip(start).take(limit).toList();
      final nextOffset = start + page.length < allDtos.length
          ? start + page.length
          : null;

      logger.i('BalanceRepository.fetchHistory success: ${page.length}');
      return Success(
        BalanceHistoryPageEntity(
          entries: page.map(BalanceEntryMapper.toEntity).toList(),
          nextOffset: nextOffset,
        ),
      );
    } catch (_) {
      logger.e('BalanceRepository.fetchHistory failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to load history'),
      );
    }
  }

  @override
  Future<Result<BalanceEntryEntity>> updateBalance({
    required String userId,
    required String accountAssetId,
    required DateTime entryDate,
    Decimal? snapshotAmount,
    Decimal? deltaAmount,
  }) async {
    try {
      final dto = await _edgeFunctions.updateBalance(
        userId: userId,
        accountAssetId: accountAssetId,
        entryDate: entryDate,
        snapshotAmount: snapshotAmount,
        deltaAmount: deltaAmount,
      );
      logger.i('BalanceRepository.updateBalance success');
      return Success(BalanceEntryMapper.toEntity(dto));
    } on MockBalanceException catch (e) {
      logger.w('BalanceRepository.updateBalance failed: ${e.code}');
      return FailureResult(_mapMockFailure(e));
    } catch (_) {
      logger.e('BalanceRepository.updateBalance failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to save balance'),
      );
    }
  }

  Failure _mapMockFailure(MockBalanceException e) {
    final code = switch (e.code) {
      MockBalanceErrorCode.network => 'network',
      MockBalanceErrorCode.unauthorized => 'unauthorized',
      MockBalanceErrorCode.validation => 'validation',
      MockBalanceErrorCode.conflict => 'conflict',
      MockBalanceErrorCode.unknown => 'unknown',
    };
    return Failure(code: code, message: e.message);
  }

  int _sortDesc(BalanceEntryDto a, BalanceEntryDto b) {
    final dateCmp = DateTime.parse(
      b.entryDateIso,
    ).compareTo(DateTime.parse(a.entryDateIso));
    if (dateCmp != 0) {
      return dateCmp;
    }
    return DateTime.parse(
      b.createdAtIso,
    ).compareTo(DateTime.parse(a.createdAtIso));
  }
}
