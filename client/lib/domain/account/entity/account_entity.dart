import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_entity.freezed.dart';

enum AccountType { bank, cryptoWallet, cash, other }

@freezed
abstract class AccountEntity with _$AccountEntity {
  const factory AccountEntity({
    required String id,
    required String userId,
    required String name,
    required AccountType type,
    required bool archived,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccountEntity;
}
