import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/repository/i_account_repository.dart';
import 'package:asset_tuner/domain/account/usecase/get_accounts_usecase.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';

void main() {
  test('load fetches and stores accounts', () async {
    final authRepository = _FakeAuthRepository(
      cachedSession: const AuthSessionEntity(userId: 'u1', email: 'u1@example.com'),
    );
    final accountRepository = _FakeAccountRepository(
      accounts: [_account(id: 'a1', name: 'Broker')],
    );
    final cubit = AccountsCubit(
      GetCachedSessionUseCase(authRepository),
      GetAccountsUseCase(accountRepository),
    );

    await cubit.load();

    expect(cubit.state.status, AccountsStatus.ready);
    expect(cubit.state.accounts.map((e) => e.id), ['a1']);
  });

  test('refresh(silent: true) does not emit loading state', () async {
    final authRepository = _FakeAuthRepository(
      cachedSession: const AuthSessionEntity(userId: 'u1', email: 'u1@example.com'),
    );
    final accountRepository = _FakeAccountRepository(
      accounts: [_account(id: 'a1', name: 'Broker')],
    );
    final cubit = AccountsCubit(
      GetCachedSessionUseCase(authRepository),
      GetAccountsUseCase(accountRepository),
    );
    await cubit.load();
    final statuses = <AccountsStatus>[];
    final sub = cubit.stream.listen((state) => statuses.add(state.status));

    accountRepository.accounts = [_account(id: 'a2', name: 'Cash')];
    await cubit.refresh(silent: true);
    await sub.cancel();

    expect(statuses, isNot(contains(AccountsStatus.loading)));
    expect(cubit.state.accounts.map((e) => e.id), ['a2']);
  });

  test('applyCreated, applyUpdated and applyDeleted mutate list immediately', () async {
    final authRepository = _FakeAuthRepository();
    final accountRepository = _FakeAccountRepository(accounts: const []);
    final cubit = AccountsCubit(
      GetCachedSessionUseCase(authRepository),
      GetAccountsUseCase(accountRepository),
    );
    cubit.applyCreated(_account(id: 'a1', name: 'Wallet'));
    cubit.applyUpdated(_account(id: 'a1', name: 'Wallet Updated'));
    cubit.applyDeleted('a1');

    expect(cubit.state.accounts, isEmpty);
  });
}

AccountEntity _account({
  required String id,
  required String name,
  AccountType type = AccountType.other,
  bool archived = false,
}) {
  final now = DateTime.utc(2025, 1, 1);
  return AccountEntity(
    id: id,
    name: name,
    type: type,
    archived: archived,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeAccountRepository implements IAccountRepository {
  _FakeAccountRepository({required this.accounts});

  List<AccountEntity> accounts;

  @override
  Future<Result<List<AccountEntity>>> fetchAccounts() async {
    return Success(accounts);
  }

  @override
  Future<Result<AccountEntity>> createAccount({
    required String name,
    required AccountType type,
  }) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<AccountEntity>> updateAccount({
    required String accountId,
    required String name,
    required AccountType type,
  }) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<AccountEntity>> setArchived({
    required String accountId,
    required bool archived,
  }) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<void>> deleteAccount({required String accountId}) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }
}

class _FakeAuthRepository implements IAuthRepository {
  _FakeAuthRepository({this.cachedSession});

  final AuthSessionEntity? cachedSession;

  @override
  Future<Result<AuthSessionEntity?>> restoreSession() async {
    return Success(cachedSession);
  }

  @override
  Future<AuthSessionEntity?> getCachedSession() async {
    return cachedSession;
  }

  @override
  Future<Result<void>> requestEmailOtp(String email) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<AuthSessionEntity>> confirmEmailOtp(String email) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<void>> signInWithPassword(String email, String password) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<OtpVerificationEntity>> signUpWithPassword(String email, String password) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<AuthSessionEntity>> verifySignUpOtp(String email, String code) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<Result<AuthSessionEntity>> signInWithOAuth(AuthProvider provider) async {
    return const FailureResult(Failure(code: 'validation', message: 'Not used'));
  }

  @override
  Future<List<AuthProvider>> getAvailableProviders() async {
    return const [];
  }

  @override
  Future<Result<void>> signOut() async {
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    return const Success(null);
  }
}
