import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/local_storage/balance_entry_storage.dart';
import 'package:asset_tuner/data/balance/dto/balance_entry_dto.dart';
import 'package:asset_tuner/data/balance/mapper/balance_entry_mapper.dart';
import 'package:asset_tuner/data/balance/service/i_update_balance_edge_function_service.dart';

enum MockBalanceErrorCode {
  network,
  unauthorized,
  validation,
  conflict,
  unknown,
}

class MockBalanceException implements Exception {
  MockBalanceException(this.code, this.message);

  final MockBalanceErrorCode code;
  final String message;

  @override
  String toString() {
    return 'MockBalanceException(code: $code, message: $message)';
  }
}

@LazySingleton(as: IUpdateBalanceEdgeFunctionService)
class MockUpdateBalanceEdgeFunctionService
    implements IUpdateBalanceEdgeFunctionService {
  MockUpdateBalanceEdgeFunctionService(this._storage);

  final BalanceEntryStorage _storage;

  @override
  Future<BalanceEntryDto> updateBalance({
    required String userId,
    required String accountAssetId,
    required DateTime entryDate,
    Decimal? snapshotAmount,
    Decimal? deltaAmount,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final hasSnapshot = snapshotAmount != null;
    final hasDelta = deltaAmount != null;
    if (hasSnapshot == hasDelta) {
      throw MockBalanceException(MockBalanceErrorCode.validation, 'amount');
    }

    final normalizedDate = DateTime(
      entryDate.year,
      entryDate.month,
      entryDate.day,
    );
    if (normalizedDate.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      throw MockBalanceException(MockBalanceErrorCode.validation, 'date');
    }

    final existingStored = await _storage.readEntries(userId);
    final existingDtos =
        existingStored
            .map(BalanceEntryMapper.toDto)
            .where((e) => e.accountAssetId == accountAssetId)
            .toList()
          ..sort(_sortAsc);

    final now = DateTime.now();
    final suffix = Random().nextInt(999999).toString().padLeft(6, '0');
    final id = 'be_${now.microsecondsSinceEpoch}_$suffix';

    Decimal? implied;
    if (snapshotAmount != null) {
      final previousSnapshot = existingDtos
          .where((e) => e.entryType == 'snapshot')
          .where(
            (e) =>
                _compareAsc(
                  DateTime.parse(e.entryDateIso),
                  DateTime.parse(e.createdAtIso),
                  normalizedDate,
                  now,
                ) <
                0,
          )
          .lastOrNull;
      if (previousSnapshot?.snapshotAmount != null) {
        implied =
            snapshotAmount - Decimal.parse(previousSnapshot!.snapshotAmount!);
      }
    }

    final dto = BalanceEntryDto(
      id: id,
      accountAssetId: accountAssetId,
      entryDateIso: normalizedDate.toIso8601String(),
      entryType: snapshotAmount != null ? 'snapshot' : 'delta',
      snapshotAmount: snapshotAmount?.toString(),
      deltaAmount: deltaAmount?.toString(),
      impliedDeltaAmount: implied?.toString(),
      createdAtIso: now.toIso8601String(),
    );

    final next = [...existingStored, BalanceEntryMapper.toStored(dto)];
    await _storage.writeEntries(userId, next);
    return dto;
  }

  int _sortAsc(BalanceEntryDto a, BalanceEntryDto b) {
    return _compareAsc(
      DateTime.parse(a.entryDateIso),
      DateTime.parse(a.createdAtIso),
      DateTime.parse(b.entryDateIso),
      DateTime.parse(b.createdAtIso),
    );
  }

  int _compareAsc(
    DateTime dateA,
    DateTime createdA,
    DateTime dateB,
    DateTime createdB,
  ) {
    final dateCmp = dateA.compareTo(dateB);
    if (dateCmp != 0) {
      return dateCmp;
    }
    return createdA.compareTo(createdB);
  }
}

extension<T> on Iterable<T> {
  T? get lastOrNull {
    var found = false;
    late final T last;
    for (final item in this) {
      found = true;
      last = item;
    }
    return found ? last : null;
  }
}
