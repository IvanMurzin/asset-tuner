import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/supabase/supabase_failure_mapper.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/account/data_source/supabase_account_data_source.dart';
import 'package:asset_tuner/data/account/mapper/account_mapper.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/repository/i_account_repository.dart';

@LazySingleton(as: IAccountRepository)
class AccountRepository implements IAccountRepository {
  AccountRepository(this._dataSource);

  final SupabaseAccountDataSource _dataSource;

  @override
  Future<Result<List<AccountEntity>>> fetchAccounts() async {
    try {
      final accounts = await _dataSource.fetchAccounts();
      logger.i('AccountRepository.fetchAccounts success');
      return Success(accounts.map(AccountMapper.toEntity).toList());
    } catch (error) {
      logger.e('AccountRepository.fetchAccounts failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to load accounts',
        ),
      );
    }
  }

  @override
  Future<Result<AccountEntity>> createAccount({
    required String name,
    required AccountType type,
  }) async {
    try {
      final dto = await _dataSource.createAccount(
        name: name,
        type: _typeToWire(type),
      );
      logger.i('AccountRepository.createAccount success');
      return Success(AccountMapper.toEntity(dto));
    } catch (error) {
      logger.e('AccountRepository.createAccount failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to create account',
        ),
      );
    }
  }

  @override
  Future<Result<AccountEntity>> updateAccount({
    required String accountId,
    required String name,
    required AccountType type,
  }) async {
    try {
      final dto = await _dataSource.updateAccount(
        accountId: accountId,
        name: name,
        type: _typeToWire(type),
      );
      logger.i('AccountRepository.updateAccount success');
      return Success(AccountMapper.toEntity(dto));
    } catch (error) {
      logger.e('AccountRepository.updateAccount failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to update account',
        ),
      );
    }
  }

  @override
  Future<Result<AccountEntity>> setArchived({
    required String accountId,
    required bool archived,
  }) async {
    try {
      final dto = await _dataSource.setArchived(
        accountId: accountId,
        archived: archived,
      );
      logger.i('AccountRepository.setArchived success');
      return Success(AccountMapper.toEntity(dto));
    } catch (error) {
      logger.e('AccountRepository.setArchived failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to update account',
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteAccount({required String accountId}) async {
    try {
      await _dataSource.deleteAccountCascade(accountId: accountId);
      logger.i('AccountRepository.deleteAccount success');
      return const Success(null);
    } catch (error) {
      logger.e('AccountRepository.deleteAccount failed', error: error);
      return FailureResult(
        SupabaseFailureMapper.toFailure(
          error,
          fallbackMessage: 'Unable to delete account',
        ),
      );
    }
  }

  String _typeToWire(AccountType type) {
    return switch (type) {
      AccountType.bank => 'bank',
      AccountType.wallet => 'wallet',
      AccountType.exchange => 'exchange',
      AccountType.cash => 'cash',
      AccountType.other => 'other',
    };
  }
}
