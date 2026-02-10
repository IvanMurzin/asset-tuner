import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/logger/logger.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/data/account/data_source/account_mock_data_source.dart';
import 'package:asset_tuner/data/account/mapper/account_mapper.dart';
import 'package:asset_tuner/data/account/service/i_account_edge_function_service.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/repository/i_account_repository.dart';

@LazySingleton(as: IAccountRepository)
class AccountRepository implements IAccountRepository {
  AccountRepository(this._dataSource, this._edgeFunctions);

  final AccountMockDataSource _dataSource;
  final IAccountEdgeFunctionService _edgeFunctions;

  @override
  Future<Result<List<AccountEntity>>> fetchAccounts(String userId) async {
    try {
      final accounts = await _dataSource.fetchAccounts(userId);
      logger.i('AccountRepository.fetchAccounts success');
      return Success(accounts.map(AccountMapper.toEntity).toList());
    } catch (_) {
      logger.e('AccountRepository.fetchAccounts failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to load accounts'),
      );
    }
  }

  @override
  Future<Result<AccountEntity>> createAccount({
    required String userId,
    required String name,
    required AccountType type,
  }) async {
    try {
      final dto = await _dataSource.createAccount(
        userId: userId,
        name: name,
        type: _typeToWire(type),
      );
      logger.i('AccountRepository.createAccount success');
      return Success(AccountMapper.toEntity(dto));
    } on MockAccountException catch (e) {
      logger.w('AccountRepository.createAccount failed: ${e.code}');
      return FailureResult(_mapMockFailure(e));
    } catch (_) {
      logger.e('AccountRepository.createAccount failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to create account'),
      );
    }
  }

  @override
  Future<Result<AccountEntity>> updateAccount({
    required String userId,
    required String accountId,
    required String name,
    required AccountType type,
  }) async {
    try {
      final dto = await _dataSource.updateAccount(
        userId: userId,
        accountId: accountId,
        name: name,
        type: _typeToWire(type),
      );
      logger.i('AccountRepository.updateAccount success');
      return Success(AccountMapper.toEntity(dto));
    } on MockAccountException catch (e) {
      logger.w('AccountRepository.updateAccount failed: ${e.code}');
      return FailureResult(_mapMockFailure(e));
    } catch (_) {
      logger.e('AccountRepository.updateAccount failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to update account'),
      );
    }
  }

  @override
  Future<Result<AccountEntity>> setArchived({
    required String userId,
    required String accountId,
    required bool archived,
  }) async {
    try {
      final dto = await _dataSource.setArchived(
        userId: userId,
        accountId: accountId,
        archived: archived,
      );
      logger.i('AccountRepository.setArchived success');
      return Success(AccountMapper.toEntity(dto));
    } on MockAccountException catch (e) {
      logger.w('AccountRepository.setArchived failed: ${e.code}');
      return FailureResult(_mapMockFailure(e));
    } catch (_) {
      logger.e('AccountRepository.setArchived failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to update account'),
      );
    }
  }

  @override
  Future<Result<void>> deleteAccount({
    required String userId,
    required String accountId,
  }) async {
    try {
      await _edgeFunctions.deleteAccountCascade(
        userId: userId,
        accountId: accountId,
      );
      logger.i('AccountRepository.deleteAccount success');
      return const Success(null);
    } on MockAccountException catch (e) {
      logger.w('AccountRepository.deleteAccount failed: ${e.code}');
      return FailureResult(_mapMockFailure(e));
    } catch (_) {
      logger.e('AccountRepository.deleteAccount failed');
      return const FailureResult(
        Failure(code: 'unknown', message: 'Unable to delete account'),
      );
    }
  }

  Failure _mapMockFailure(MockAccountException e) {
    final code = switch (e.code) {
      MockAccountErrorCode.network => 'network',
      MockAccountErrorCode.unauthorized => 'unauthorized',
      MockAccountErrorCode.notFound => 'not_found',
      MockAccountErrorCode.validation => 'validation',
      MockAccountErrorCode.unknown => 'unknown',
    };
    return Failure(code: code, message: e.message);
  }

  String _typeToWire(AccountType type) {
    return switch (type) {
      AccountType.bank => 'bank',
      AccountType.cryptoWallet => 'crypto_wallet',
      AccountType.cash => 'cash',
      AccountType.other => 'other',
    };
  }
}
