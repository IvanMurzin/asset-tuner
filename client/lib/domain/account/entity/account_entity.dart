import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/utils/money_atomic.dart';

part 'account_entity.freezed.dart';

enum AccountType { bank, wallet, exchange, cash, other }

@freezed
abstract class AccountTotalsEntity with _$AccountTotalsEntity {
  const AccountTotalsEntity._();

  const factory AccountTotalsEntity({
    Decimal? totalUsdAtomic,
    int? totalUsdDecimals,
    Decimal? totalInBaseAtomic,
    int? totalInBaseDecimals,
    String? baseAssetId,
    String? baseAssetCode,
  }) = _AccountTotalsEntity;

  Decimal? get totalUsd {
    final atomic = totalUsdAtomic;
    final decimals = totalUsdDecimals;
    if (atomic == null || decimals == null) {
      return null;
    }
    return MoneyAtomic.fromAtomic(atomic.toString(), decimals);
  }

  Decimal? get totalInBase {
    final atomic = totalInBaseAtomic;
    final decimals = totalInBaseDecimals;
    if (atomic == null || decimals == null) {
      return null;
    }
    return MoneyAtomic.fromAtomic(atomic.toString(), decimals);
  }
}

@freezed
abstract class AccountCacheEntity with _$AccountCacheEntity {
  const AccountCacheEntity._();

  const factory AccountCacheEntity({
    Decimal? cachedTotalUsdAtomic,
    int? cachedTotalUsdDecimals,
    DateTime? cachedTotalUpdatedAt,
  }) = _AccountCacheEntity;

  Decimal? get cachedTotalUsd {
    final atomic = cachedTotalUsdAtomic;
    final decimals = cachedTotalUsdDecimals;
    if (atomic == null || decimals == null) {
      return null;
    }
    return MoneyAtomic.fromAtomic(atomic.toString(), decimals);
  }
}

@freezed
abstract class AccountEntity with _$AccountEntity {
  const factory AccountEntity({
    required String id,
    String? userId,
    required String name,
    required AccountType type,
    required bool archived,
    int? subaccountsCount,
    AccountTotalsEntity? totals,
    AccountCacheEntity? cache,
    Decimal? cachedTotalUsdAtomic,
    int? cachedTotalUsdDecimals,
    DateTime? cachedTotalUpdatedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccountEntity;
}
