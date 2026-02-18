import 'package:decimal/decimal.dart';
import 'package:asset_tuner/core/local_storage/balance_entry_storage.dart';
import 'package:asset_tuner/data/balance/dto/balance_entry_dto.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';

abstract final class BalanceEntryMapper {
  static BalanceEntryEntity toEntity(BalanceEntryDto dto) {
    return BalanceEntryEntity(
      id: dto.id,
      subaccountId: dto.subaccountId,
      entryDate: DateTime.parse(dto.entryDateIso),
      snapshotAmount: dto.snapshotAmount,
      diffAmount: dto.diffAmount,
      createdAt: DateTime.parse(dto.createdAtIso),
    );
  }

  static BalanceEntryDto toDto(StoredBalanceEntry stored) {
    return BalanceEntryDto(
      id: stored.id,
      subaccountId: stored.accountAssetId,
      entryDateIso: stored.entryDateIso,
      snapshotAmount: Decimal.parse(stored.snapshotAmount ?? '0'),
      amountDecimals: _decimalsFromStored(stored.snapshotAmount),
      diffAmount: stored.impliedDeltaAmount == null
          ? null
          : Decimal.parse(stored.impliedDeltaAmount!),
      createdAtIso: stored.createdAtIso,
    );
  }

  static StoredBalanceEntry toStored(BalanceEntryDto dto) {
    return StoredBalanceEntry(
      id: dto.id,
      accountAssetId: dto.subaccountId,
      entryDateIso: dto.entryDateIso,
      entryType: 'snapshot',
      snapshotAmount: dto.snapshotAmount.toString(),
      deltaAmount: null,
      impliedDeltaAmount: dto.diffAmount?.toString(),
      createdAtIso: dto.createdAtIso,
    );
  }

  static int _decimalsFromStored(String? amount) {
    if (amount == null || amount.isEmpty) {
      return 0;
    }
    final index = amount.indexOf('.');
    if (index < 0) {
      return 0;
    }
    return amount.length - index - 1;
  }
}
