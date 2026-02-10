import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';

abstract interface class IAccountRepository {
  Future<Result<List<AccountEntity>>> fetchAccounts(String userId);

  Future<Result<AccountEntity>> createAccount({
    required String userId,
    required String name,
    required AccountType type,
  });

  Future<Result<AccountEntity>> updateAccount({
    required String userId,
    required String accountId,
    required String name,
    required AccountType type,
  });

  Future<Result<AccountEntity>> setArchived({
    required String userId,
    required String accountId,
    required bool archived,
  });

  Future<Result<void>> deleteAccount({
    required String userId,
    required String accountId,
  });
}
