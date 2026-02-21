import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/data/_shared/money_atomic.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';

part 'subaccount_entity.freezed.dart';

@freezed
abstract class SubaccountEntity with _$SubaccountEntity {
  const SubaccountEntity._();

  const factory SubaccountEntity({
    required String id,
    String? userId,
    required String accountId,
    required String assetId,
    required String name,
    required bool archived,
    Decimal? currentAmountAtomic,
    int? currentAmountDecimals,
    AssetEntity? asset,
    AssetUsdRateEntity? usdRate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SubaccountEntity;

  Decimal? get currentAmount {
    final atomic = currentAmountAtomic;
    final decimals = currentAmountDecimals;
    if (atomic == null || decimals == null) {
      return null;
    }
    return MoneyAtomic.fromAtomic(atomic.toString(), decimals);
  }
}
