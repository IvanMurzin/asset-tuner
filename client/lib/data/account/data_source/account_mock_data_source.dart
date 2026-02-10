import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/local_storage/account_storage.dart';
import 'package:asset_tuner/data/account/dto/account_dto.dart';

enum MockAccountErrorCode {
  network,
  unauthorized,
  notFound,
  validation,
  unknown,
}

class MockAccountException implements Exception {
  MockAccountException(this.code, this.message);

  final MockAccountErrorCode code;
  final String message;

  @override
  String toString() {
    return 'MockAccountException(code: $code, message: $message)';
  }
}

@lazySingleton
class AccountMockDataSource {
  AccountMockDataSource(this._storage);

  final AccountStorage _storage;

  Future<List<AccountDto>> fetchAccounts(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final stored = await _storage.readAccounts(userId);
    if (stored.isEmpty) {
      final seeded = _seedAccounts(userId);
      await _storage.writeAccounts(userId, seeded.map(_toStored).toList());
      return seeded;
    }
    return stored.map(_fromStored).toList();
  }

  Future<AccountDto?> fetchAccount(String userId, String accountId) async {
    final all = await fetchAccounts(userId);
    return all.where((a) => a.id == accountId).firstOrNull;
  }

  Future<AccountDto> createAccount({
    required String userId,
    required String name,
    required String type,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final normalized = name.trim();
    if (normalized.isEmpty) {
      throw MockAccountException(
        MockAccountErrorCode.validation,
        'Name is required.',
      );
    }
    if (normalized.toLowerCase().contains('offline')) {
      throw MockAccountException(
        MockAccountErrorCode.network,
        'Network unavailable.',
      );
    }

    final now = DateTime.now();
    final idSuffix = Random().nextInt(999999).toString().padLeft(6, '0');
    final id = 'acc_${now.microsecondsSinceEpoch}_$idSuffix';
    final dto = AccountDto(
      id: id,
      userId: userId,
      name: normalized,
      type: type,
      archived: false,
      createdAtIso: now.toIso8601String(),
      updatedAtIso: now.toIso8601String(),
    );
    final existing = await _storage.readAccounts(userId);
    await _storage.writeAccounts(userId, [...existing, _toStored(dto)]);
    return dto;
  }

  Future<AccountDto> updateAccount({
    required String userId,
    required String accountId,
    required String name,
    required String type,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final normalized = name.trim();
    if (normalized.isEmpty) {
      throw MockAccountException(
        MockAccountErrorCode.validation,
        'Name is required.',
      );
    }
    if (normalized.toLowerCase().contains('offline')) {
      throw MockAccountException(
        MockAccountErrorCode.network,
        'Network unavailable.',
      );
    }

    final existing = await _storage.readAccounts(userId);
    final index = existing.indexWhere((a) => a.id == accountId);
    if (index < 0) {
      throw MockAccountException(
        MockAccountErrorCode.notFound,
        'Account not found.',
      );
    }
    final current = existing[index];
    final updated = StoredAccount(
      id: current.id,
      userId: current.userId,
      name: normalized,
      type: type,
      archived: current.archived,
      createdAtIso: current.createdAtIso,
      updatedAtIso: DateTime.now().toIso8601String(),
    );
    final next = [...existing]..[index] = updated;
    await _storage.writeAccounts(userId, next);
    return _fromStored(updated);
  }

  Future<AccountDto> setArchived({
    required String userId,
    required String accountId,
    required bool archived,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final existing = await _storage.readAccounts(userId);
    final index = existing.indexWhere((a) => a.id == accountId);
    if (index < 0) {
      throw MockAccountException(
        MockAccountErrorCode.notFound,
        'Account not found.',
      );
    }
    final current = existing[index];
    final updated = StoredAccount(
      id: current.id,
      userId: current.userId,
      name: current.name,
      type: current.type,
      archived: archived,
      createdAtIso: current.createdAtIso,
      updatedAtIso: DateTime.now().toIso8601String(),
    );
    final next = [...existing]..[index] = updated;
    await _storage.writeAccounts(userId, next);
    return _fromStored(updated);
  }

  Future<void> deleteAccountCascade({
    required String userId,
    required String accountId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final existing = await _storage.readAccounts(userId);
    final next = existing.where((a) => a.id != accountId).toList();
    if (next.length == existing.length) {
      throw MockAccountException(
        MockAccountErrorCode.notFound,
        'Account not found.',
      );
    }
    await _storage.writeAccounts(userId, next);
  }

  List<AccountDto> _seedAccounts(String userId) {
    final now = DateTime.now();
    return [
      AccountDto(
        id: 'acc_seed_cash',
        userId: userId,
        name: 'Cash',
        type: 'cash',
        archived: false,
        createdAtIso: now.toIso8601String(),
        updatedAtIso: now.toIso8601String(),
      ),
      AccountDto(
        id: 'acc_seed_wallet',
        userId: userId,
        name: 'Crypto wallet',
        type: 'crypto_wallet',
        archived: false,
        createdAtIso: now.toIso8601String(),
        updatedAtIso: now.toIso8601String(),
      ),
    ];
  }

  AccountDto _fromStored(StoredAccount stored) {
    return AccountDto(
      id: stored.id,
      userId: stored.userId,
      name: stored.name,
      type: stored.type,
      archived: stored.archived,
      createdAtIso: stored.createdAtIso,
      updatedAtIso: stored.updatedAtIso,
    );
  }

  StoredAccount _toStored(AccountDto dto) {
    return StoredAccount(
      id: dto.id,
      userId: dto.userId,
      name: dto.name,
      type: dto.type,
      archived: dto.archived,
      createdAtIso: dto.createdAtIso,
      updatedAtIso: dto.updatedAtIso,
    );
  }
}

extension on Iterable<AccountDto> {
  AccountDto? get firstOrNull {
    for (final item in this) {
      return item;
    }
    return null;
  }
}
