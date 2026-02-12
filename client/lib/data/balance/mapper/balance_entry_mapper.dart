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
      snapshotAmount: Decimal.parse(dto.snapshotAmount),
      diffAmount: dto.diffAmount == null
          ? null
          : Decimal.parse(dto.diffAmount!),
      createdAt: DateTime.parse(dto.createdAtIso),
    );
  }

  static BalanceEntryDto toDto(StoredBalanceEntry stored) {
    return BalanceEntryDto(
      id: stored.id,
      subaccountId: stored.accountAssetId,
      entryDateIso: stored.entryDateIso,
      snapshotAmount: stored.snapshotAmount ?? '0',
      diffAmount: stored.impliedDeltaAmount,
      createdAtIso: stored.createdAtIso,
    );
  }

  static StoredBalanceEntry toStored(BalanceEntryDto dto) {
    return StoredBalanceEntry(
      id: dto.id,
      accountAssetId: dto.subaccountId,
      entryDateIso: dto.entryDateIso,
      entryType: 'snapshot',
      snapshotAmount: dto.snapshotAmount,
      deltaAmount: null,
      impliedDeltaAmount: dto.diffAmount,
      createdAtIso: dto.createdAtIso,
    );
  }
}
