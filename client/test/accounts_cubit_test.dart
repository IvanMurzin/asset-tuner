import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/repository/i_account_repository.dart';
import 'package:asset_tuner/domain/account/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/account/usecase/get_accounts_usecase.dart';
import 'package:asset_tuner/domain/account/usecase/set_account_archived_usecase.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/presentation/account/bloc/accounts_cubit.dart';

class FakeAuthRepository implements IAuthRepository {
  FakeAuthRepository({this.cachedSession});

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
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<AuthSessionEntity>> confirmEmailOtp(String email) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<AuthSessionEntity>> signInWithOAuth(provider) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<void>> signInWithPassword(String email, String password) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<OtpVerificationEntity>> signUpWithPassword(
    String email,
    String password,
  ) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<AuthSessionEntity>> verifySignUpOtp(
    String email,
    String code,
  ) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<void>> signOut() async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<List<AuthProvider>> getAvailableProviders() async {
    return const [];
  }

  @override
  Future<Result<void>> deleteAccount() async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }
}

class FakeAccountRepository implements IAccountRepository {
  FakeAccountRepository(this._accounts);

  final List<AccountEntity> _accounts;

  @override
  Future<Result<List<AccountEntity>>> fetchAccounts() async {
    return Success(_accounts);
  }

  @override
  Future<Result<AccountEntity>> createAccount({
    required String name,
    required AccountType type,
  }) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<AccountEntity>> updateAccount({
    required String accountId,
    required String name,
    required AccountType type,
  }) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<AccountEntity>> setArchived({
    required String accountId,
    required bool archived,
  }) async {
    final index = _accounts.indexWhere((a) => a.id == accountId);
    if (index < 0) {
      return const FailureResult(
        Failure(code: 'not_found', message: 'Not found'),
      );
    }
    final current = _accounts[index];
    final updated = current.copyWith(archived: archived);
    _accounts[index] = updated;
    return Success(updated);
  }

  @override
  Future<Result<void>> deleteAccount({
    required String accountId,
  }) async {
    _accounts.removeWhere((a) => a.id == accountId);
    return const Success(null);
  }
}

void main() {
  test('load navigates to sign-in when session missing', () async {
    final cubit = AccountsCubit(
      GetCachedSessionUseCase(FakeAuthRepository()),
      GetAccountsUseCase(FakeAccountRepository(const [])),
      SetAccountArchivedUseCase(FakeAccountRepository(const [])),
      DeleteAccountUseCase(FakeAccountRepository(const [])),
    );

    await cubit.load();

    expect(cubit.state.navigation?.destination, AccountsDestination.signIn);
  });

  test('load splits active and archived accounts', () async {
    final now = DateTime(2026, 2, 10);
    final accounts = [
      AccountEntity(
        id: 'a1',
        name: 'Cash',
        type: AccountType.cash,
        archived: false,
        createdAt: now,
        updatedAt: now,
      ),
      AccountEntity(
        id: 'a2',
        name: 'Bank',
        type: AccountType.bank,
        archived: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final repo = FakeAccountRepository(accounts);
    final cubit = AccountsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      GetAccountsUseCase(repo),
      SetAccountArchivedUseCase(repo),
      DeleteAccountUseCase(repo),
    );

    await cubit.load();

    expect(cubit.state.activeAccounts.length, 1);
    expect(cubit.state.archivedAccounts.length, 1);
    expect(cubit.state.activeAccounts.first.id, 'a1');
    expect(cubit.state.archivedAccounts.first.id, 'a2');
  });

  test('deleteAccount removes account from state', () async {
    final now = DateTime(2026, 2, 10);
    final accounts = [
      AccountEntity(
        id: 'a1',
        name: 'Cash',
        type: AccountType.cash,
        archived: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final repo = FakeAccountRepository(accounts);
    final cubit = AccountsCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      GetAccountsUseCase(repo),
      SetAccountArchivedUseCase(repo),
      DeleteAccountUseCase(repo),
    );

    await cubit.load();
    await cubit.deleteAccount('a1');

    expect(cubit.state.activeAccounts, isEmpty);
  });
}
