import 'package:asset_tuner/data/account/dto/account_dto.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';

abstract final class AccountMapper {
  static AccountEntity toEntity(AccountDto dto) {
    return AccountEntity(
      id: dto.id,
      name: dto.name,
      type: _typeFromWire(dto.type),
      archived: dto.archived,
      createdAt: DateTime.parse(dto.createdAtIso),
      updatedAt: DateTime.parse(dto.updatedAtIso),
    );
  }

  static AccountDto toDto(AccountEntity entity) {
    return AccountDto(
      id: entity.id,
      name: entity.name,
      type: _typeToWire(entity.type),
      archived: entity.archived,
      createdAtIso: entity.createdAt.toIso8601String(),
      updatedAtIso: entity.updatedAt.toIso8601String(),
    );
  }

  static AccountType _typeFromWire(String type) {
    return switch (type) {
      'bank' => AccountType.bank,
      'crypto_wallet' => AccountType.cryptoWallet,
      'cash' => AccountType.cash,
      'other' => AccountType.other,
      _ => AccountType.other,
    };
  }

  static String _typeToWire(AccountType type) {
    return switch (type) {
      AccountType.bank => 'bank',
      AccountType.cryptoWallet => 'crypto_wallet',
      AccountType.cash => 'cash',
      AccountType.other => 'other',
    };
  }
}
