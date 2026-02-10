import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/local_storage/account_asset_storage.dart';
import 'package:asset_tuner/core/local_storage/balance_entry_storage.dart';

enum MockAccountAssetErrorCode {
  network,
  unauthorized,
  notFound,
  validation,
  unknown,
}

class MockAccountAssetException implements Exception {
  MockAccountAssetException(this.code, this.message);

  final MockAccountAssetErrorCode code;
  final String message;

  @override
  String toString() {
    return 'MockAccountAssetException(code: $code, message: $message)';
  }
}

@lazySingleton
class AccountAssetMockDataSource {
  AccountAssetMockDataSource(this._storage, this._balanceStorage);

  final AccountAssetStorage _storage;
  final BalanceEntryStorage _balanceStorage;

  Future<List<StoredAccountAsset>> fetchPositions(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final stored = await _storage.readAccountAssets(userId);
    if (stored.isEmpty) {
      final seeded = _seed(userId);
      await _storage.writeAccountAssets(userId, seeded);
      return seeded;
    }
    return stored;
  }

  Future<List<StoredAccountAsset>> fetchAccountPositions({
    required String userId,
    required String accountId,
  }) async {
    final all = await fetchPositions(userId);
    return all.where((p) => p.accountId == accountId).toList();
  }

  Future<int> countPositions(String userId) async {
    final all = await fetchPositions(userId);
    return all.length;
  }

  Future<StoredAccountAsset> addPosition({
    required String userId,
    required String accountId,
    required String assetId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    final all = await fetchPositions(userId);
    final isDuplicate = all.any(
      (p) => p.accountId == accountId && p.assetId == assetId,
    );
    if (isDuplicate) {
      throw MockAccountAssetException(
        MockAccountAssetErrorCode.validation,
        'Duplicate asset position.',
      );
    }

    final now = DateTime.now();
    final suffix = Random().nextInt(999999).toString().padLeft(6, '0');
    final id = 'pos_${now.microsecondsSinceEpoch}_$suffix';
    final created = StoredAccountAsset(
      id: id,
      accountId: accountId,
      assetId: assetId,
      createdAtIso: now.toIso8601String(),
      sortOrder: null,
    );
    await _storage.writeAccountAssets(userId, [...all, created]);
    return created;
  }

  Future<void> removePosition({
    required String userId,
    required String accountId,
    required String assetId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final all = await fetchPositions(userId);
    final next = all
        .where((p) => !(p.accountId == accountId && p.assetId == assetId))
        .toList();
    if (next.length == all.length) {
      throw MockAccountAssetException(
        MockAccountAssetErrorCode.notFound,
        'Asset position not found.',
      );
    }
    await _storage.writeAccountAssets(userId, next);

    final removed = all
        .where((p) => p.accountId == accountId && p.assetId == assetId)
        .firstOrNull;
    if (removed != null) {
      final entries = await _balanceStorage.readEntries(userId);
      final filtered = entries
          .where((e) => e.accountAssetId != removed.id)
          .toList();
      await _balanceStorage.writeEntries(userId, filtered);
    }
  }

  List<StoredAccountAsset> _seed(String userId) {
    final now = DateTime.now().toIso8601String();
    return [
      StoredAccountAsset(
        id: 'pos_seed_cash_usd',
        accountId: 'acc_seed_cash',
        assetId: 'asset_usd',
        createdAtIso: now,
      ),
      StoredAccountAsset(
        id: 'pos_seed_wallet_btc',
        accountId: 'acc_seed_wallet',
        assetId: 'asset_btc',
        createdAtIso: now,
      ),
    ];
  }
}

extension on Iterable<StoredAccountAsset> {
  StoredAccountAsset? get firstOrNull {
    for (final item in this) {
      return item;
    }
    return null;
  }
}
