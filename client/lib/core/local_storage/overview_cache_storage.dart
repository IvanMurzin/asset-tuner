import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO: remove and reimplement with hidrated cubit or hive, use cache only in repos and move to data
@lazySingleton
class OverviewCacheStorage {
  Future<StoredOverviewSnapshot?> readSnapshot(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null) {
      return null;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return StoredOverviewSnapshot.fromJson(decoded);
  }

  Future<void> writeSnapshot(String userId, StoredOverviewSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(userId), jsonEncode(snapshot.toJson()));
  }

  Future<void> deleteSnapshot(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(userId));
  }

  String _key(String userId) => 'overview_cache_$userId';
}

class StoredOverviewSnapshot {
  const StoredOverviewSnapshot({
    required this.computedAtIso,
    required this.baseCurrencyCode,
    required this.fullTotal,
    required this.pricedTotal,
    required this.hasUnpricedHoldings,
    required this.ratesAsOfIso,
    required this.accountTotals,
    required this.unpricedHoldings,
  });

  final String computedAtIso;
  final String baseCurrencyCode;
  final String? fullTotal;
  final String? pricedTotal;
  final bool hasUnpricedHoldings;
  final String? ratesAsOfIso;
  final List<StoredOverviewAccountTotal> accountTotals;
  final List<StoredUnpricedHolding> unpricedHoldings;

  Map<String, dynamic> toJson() {
    return {
      'computedAtIso': computedAtIso,
      'baseCurrencyCode': baseCurrencyCode,
      'fullTotal': fullTotal,
      'pricedTotal': pricedTotal,
      'hasUnpricedHoldings': hasUnpricedHoldings,
      'ratesAsOfIso': ratesAsOfIso,
      'accountTotals': accountTotals.map((e) => e.toJson()).toList(),
      'unpricedHoldings': unpricedHoldings.map((e) => e.toJson()).toList(),
    };
  }

  static StoredOverviewSnapshot fromJson(Map<String, dynamic> json) {
    return StoredOverviewSnapshot(
      computedAtIso: json['computedAtIso'] as String,
      baseCurrencyCode: json['baseCurrencyCode'] as String,
      fullTotal: json['fullTotal'] as String?,
      pricedTotal: json['pricedTotal'] as String?,
      hasUnpricedHoldings: json['hasUnpricedHoldings'] as bool,
      ratesAsOfIso: json['ratesAsOfIso'] as String?,
      accountTotals: (json['accountTotals'] as List<dynamic>)
          .map((e) => StoredOverviewAccountTotal.fromJson(e as Map<String, dynamic>))
          .toList(),
      unpricedHoldings: (json['unpricedHoldings'] as List<dynamic>)
          .map((e) => StoredUnpricedHolding.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  DateTime get computedAt => DateTime.parse(computedAtIso);
  DateTime? get ratesAsOf => ratesAsOfIso == null ? null : DateTime.parse(ratesAsOfIso!);

  Decimal? get fullTotalDecimal => fullTotal == null ? null : Decimal.parse(fullTotal!);
  Decimal? get pricedTotalDecimal => pricedTotal == null ? null : Decimal.parse(pricedTotal!);
}

class StoredOverviewAccountTotal {
  const StoredOverviewAccountTotal({
    required this.accountId,
    required this.accountName,
    required this.total,
    required this.hasUnpriced,
  });

  final String accountId;
  final String accountName;
  final String? total;
  final bool hasUnpriced;

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'accountName': accountName,
      'total': total,
      'hasUnpriced': hasUnpriced,
    };
  }

  static StoredOverviewAccountTotal fromJson(Map<String, dynamic> json) {
    return StoredOverviewAccountTotal(
      accountId: json['accountId'] as String,
      accountName: json['accountName'] as String,
      total: json['total'] as String?,
      hasUnpriced: json['hasUnpriced'] as bool,
    );
  }

  Decimal? get totalDecimal => total == null ? null : Decimal.parse(total!);
}

class StoredUnpricedHolding {
  const StoredUnpricedHolding({required this.assetCode, required this.amount});

  final String assetCode;
  final String amount;

  Map<String, dynamic> toJson() {
    return {'assetCode': assetCode, 'amount': amount};
  }

  static StoredUnpricedHolding fromJson(Map<String, dynamic> json) {
    return StoredUnpricedHolding(
      assetCode: json['assetCode'] as String,
      amount: json['amount'] as String,
    );
  }

  Decimal get amountDecimal => Decimal.parse(amount);
}
