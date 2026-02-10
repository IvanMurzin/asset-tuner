import 'package:decimal/decimal.dart';
import 'package:asset_tuner/core/local_storage/balance_entry_storage.dart';
import 'package:asset_tuner/data/balance/dto/balance_entry_dto.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';

abstract final class BalanceEntryMapper {
  static BalanceEntryEntity toEntity(BalanceEntryDto dto) {
    return BalanceEntryEntity(
      id: dto.id,
      accountAssetId: dto.accountAssetId,
      entryDate: DateTime.parse(dto.entryDateIso),
      entryType: _typeFromWire(dto.entryType),
      snapshotAmount: dto.snapshotAmount == null
          ? null
          : Decimal.parse(dto.snapshotAmount!),
      deltaAmount: dto.deltaAmount == null
          ? null
          : Decimal.parse(dto.deltaAmount!),
      impliedDeltaAmount: dto.impliedDeltaAmount == null
          ? null
          : Decimal.parse(dto.impliedDeltaAmount!),
      createdAt: DateTime.parse(dto.createdAtIso),
    );
  }

  static BalanceEntryDto toDto(StoredBalanceEntry stored) {
    return BalanceEntryDto(
      id: stored.id,
      accountAssetId: stored.accountAssetId,
      entryDateIso: stored.entryDateIso,
      entryType: stored.entryType,
      snapshotAmount: stored.snapshotAmount,
      deltaAmount: stored.deltaAmount,
      impliedDeltaAmount: stored.impliedDeltaAmount,
      createdAtIso: stored.createdAtIso,
    );
  }

  static StoredBalanceEntry toStored(BalanceEntryDto dto) {
    return StoredBalanceEntry(
      id: dto.id,
      accountAssetId: dto.accountAssetId,
      entryDateIso: dto.entryDateIso,
      entryType: dto.entryType,
      snapshotAmount: dto.snapshotAmount,
      deltaAmount: dto.deltaAmount,
      impliedDeltaAmount: dto.impliedDeltaAmount,
      createdAtIso: dto.createdAtIso,
    );
  }

  static BalanceEntryType _typeFromWire(String type) {
    return switch (type) {
      'snapshot' => BalanceEntryType.snapshot,
      'delta' => BalanceEntryType.delta,
      _ => BalanceEntryType.snapshot,
    };
  }
}
