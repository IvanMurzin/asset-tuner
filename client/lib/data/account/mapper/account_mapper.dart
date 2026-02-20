import 'package:asset_tuner/data/account/dto/account_dto.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';

abstract final class AccountMapper {
  static AccountEntity toEntity(AccountDto dto) {
    return AccountEntity(
      id: dto.id,
      userId: dto.userId,
      name: dto.name,
      type: _typeFromWire(dto.type),
      archived: dto.archived,
      subaccountsCount: dto.subaccountsCount,
      totals: _totalsToEntity(dto.totals),
      cache: _cacheToEntity(dto.cache),
      cachedTotalUsdAtomic: dto.cachedTotalUsdAtomic,
      cachedTotalUsdDecimals: dto.cachedTotalUsdDecimals,
      cachedTotalUpdatedAt: _parseDateOrNull(dto.cachedTotalUpdatedAtIso),
      createdAt: DateTime.parse(dto.createdAtIso),
      updatedAt: DateTime.parse(dto.updatedAtIso),
    );
  }

  static AccountDto toDto(AccountEntity entity) {
    return AccountDto(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      type: _typeToWire(entity.type),
      archived: entity.archived,
      subaccountsCount: entity.subaccountsCount,
      totals: _totalsToDto(entity.totals),
      cache: _cacheToDto(entity.cache),
      cachedTotalUsdAtomic: entity.cachedTotalUsdAtomic,
      cachedTotalUsdDecimals: entity.cachedTotalUsdDecimals,
      cachedTotalUpdatedAtIso: entity.cachedTotalUpdatedAt?.toIso8601String(),
      createdAtIso: entity.createdAt.toIso8601String(),
      updatedAtIso: entity.updatedAt.toIso8601String(),
    );
  }

  static AccountType _typeFromWire(String type) {
    return switch (type) {
      'bank' => AccountType.bank,
      'wallet' => AccountType.wallet,
      'exchange' => AccountType.exchange,
      'cash' => AccountType.cash,
      'other' => AccountType.other,
      _ => AccountType.other,
    };
  }

  static String _typeToWire(AccountType type) {
    return switch (type) {
      AccountType.bank => 'bank',
      AccountType.wallet => 'wallet',
      AccountType.exchange => 'exchange',
      AccountType.cash => 'cash',
      AccountType.other => 'other',
    };
  }

  static AccountTotalsEntity? _totalsToEntity(AccountTotalsDto? dto) {
    if (dto == null) {
      return null;
    }
    return AccountTotalsEntity(
      totalUsdAtomic: dto.totalUsdAtomic,
      totalUsdDecimals: dto.totalUsdDecimals,
      totalInBaseAtomic: dto.totalInBaseAtomic,
      totalInBaseDecimals: dto.totalInBaseDecimals,
      baseAssetId: dto.baseAssetId,
      baseAssetCode: dto.baseAssetCode,
    );
  }

  static AccountTotalsDto? _totalsToDto(AccountTotalsEntity? entity) {
    if (entity == null) {
      return null;
    }
    return AccountTotalsDto(
      totalUsdAtomic: entity.totalUsdAtomic,
      totalUsdDecimals: entity.totalUsdDecimals,
      totalInBaseAtomic: entity.totalInBaseAtomic,
      totalInBaseDecimals: entity.totalInBaseDecimals,
      baseAssetId: entity.baseAssetId,
      baseAssetCode: entity.baseAssetCode,
    );
  }

  static AccountCacheEntity? _cacheToEntity(AccountCacheDto? dto) {
    if (dto == null) {
      return null;
    }
    return AccountCacheEntity(
      cachedTotalUsdAtomic: dto.cachedTotalUsdAtomic,
      cachedTotalUsdDecimals: dto.cachedTotalUsdDecimals,
      cachedTotalUpdatedAt: _parseDateOrNull(dto.cachedTotalUpdatedAtIso),
    );
  }

  static AccountCacheDto? _cacheToDto(AccountCacheEntity? entity) {
    if (entity == null) {
      return null;
    }
    return AccountCacheDto(
      cachedTotalUsdAtomic: entity.cachedTotalUsdAtomic,
      cachedTotalUsdDecimals: entity.cachedTotalUsdDecimals,
      cachedTotalUpdatedAtIso: entity.cachedTotalUpdatedAt?.toIso8601String(),
    );
  }

  static DateTime? _parseDateOrNull(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
