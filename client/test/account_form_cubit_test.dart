import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/repository/i_account_repository.dart';
import 'package:asset_tuner/domain/account/usecase/create_account_usecase.dart';
import 'package:asset_tuner/domain/account/usecase/get_accounts_usecase.dart';
import 'package:asset_tuner/domain/account/usecase/update_account_usecase.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/presentation/account/bloc/account_form_cubit.dart';
import 'test_fixtures.dart';

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

class FakeProfileRepository implements IProfileRepository {
  FakeProfileRepository({required this.profile});

  final ProfileEntity profile;

  @override
  Future<Result<ProfileBootstrapEntity>> ensureProfile() async {
    return Success(
      ProfileBootstrapEntity(
        profile: profile,
        isNew: false,
        wasBaseCurrencyDefaulted: false,
      ),
    );
  }

  @override
  Future<Result<ProfileEntity>> getProfile() async {
    return Success(profile);
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(String baseCurrency) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String plan) async {
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
    final now = DateTime(2026, 2, 10);
    final created = AccountEntity(
      id: 'new_1',
      name: name,
      type: type,
      archived: false,
      createdAt: now,
      updatedAt: now,
    );
    _accounts.add(created);
    return Success(created);
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
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<void>> deleteAccount({
    required String accountId,
  }) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }
}

void main() {
  test('save validates name required', () async {
    final cubit = AccountFormCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      GetProfileUseCase(FakeProfileRepository(profile: freeProfile())),
      BootstrapProfileUseCase(FakeProfileRepository(profile: freeProfile())),
      GetAccountsUseCase(FakeAccountRepository([])),
      CreateAccountUseCase(FakeAccountRepository([])),
      UpdateAccountUseCase(FakeAccountRepository([])),
    );

    await cubit.load();
    cubit.updateName('   ');
    await cubit.save();

    expect(cubit.state.nameError, 'required');
  });

  test('create routes to paywall when free and limit reached', () async {
    final now = DateTime(2026, 2, 10);
    final accounts = List.generate(
      5,
      (i) => AccountEntity(
        id: 'a$i',
        name: 'Acc $i',
        type: AccountType.bank,
        archived: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final accountRepo = FakeAccountRepository(accounts);
    final profileRepo = FakeProfileRepository(profile: freeProfile());

    final cubit = AccountFormCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      GetProfileUseCase(profileRepo),
      BootstrapProfileUseCase(profileRepo),
      GetAccountsUseCase(accountRepo),
      CreateAccountUseCase(accountRepo),
      UpdateAccountUseCase(accountRepo),
    );

    await cubit.load();
    cubit.updateName('New');
    await cubit.save();

    expect(cubit.state.navigation?.destination, AccountFormDestination.paywall);
  });

  test('create navigates backSaved on success', () async {
    final accountRepo = FakeAccountRepository([]);
    final profileRepo = FakeProfileRepository(profile: paidProfile());

    final cubit = AccountFormCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      GetProfileUseCase(profileRepo),
      BootstrapProfileUseCase(profileRepo),
      GetAccountsUseCase(accountRepo),
      CreateAccountUseCase(accountRepo),
      UpdateAccountUseCase(accountRepo),
    );

    await cubit.load();
    cubit.updateName('My account');
    cubit.selectType(AccountType.cash);
    await cubit.save();

    expect(
      cubit.state.navigation?.destination,
      AccountFormDestination.backSaved,
    );
    expect(cubit.state.navigation?.accountId, 'new_1');
  });
}
