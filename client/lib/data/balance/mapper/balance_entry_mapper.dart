import 'package:asset_tuner/data/balance/dto/balance_entry_dto.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';

abstract final class BalanceEntryMapper {
  static BalanceEntryEntity toEntity(BalanceEntryDto dto) {
    return BalanceEntryEntity(
      id: dto.id,
      userId: dto.userId,
      subaccountId: dto.subaccountId,
      amountAtomic: dto.amountAtomic,
      amountDecimals: dto.amountDecimals,
      note: dto.note,
      diffAmount: dto.diffAmount,
      createdAt: DateTime.parse(dto.createdAtIso),
    );
  }
}
