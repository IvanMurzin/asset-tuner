import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/repository/i_account_repository.dart';
import 'package:asset_tuner/domain/account/usecase/create_account_usecase.dart';
import 'package:asset_tuner/domain/account/usecase/update_account_usecase.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/presentation/account/bloc/account_create_cubit.dart';
import 'package:asset_tuner/presentation/account/bloc/account_update_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Account form cubits validation', () {
    late _FakeAuthRepository authRepository;
    late _FakeAccountRepository accountRepository;
    late GetCachedSessionUseCase getCachedSessionUseCase;
    late CreateAccountUseCase createAccountUseCase;
    late UpdateAccountUseCase updateAccountUseCase;

    setUp(() {
      authRepository = _FakeAuthRepository();
      accountRepository = _FakeAccountRepository();
      getCachedSessionUseCase = GetCachedSessionUseCase(authRepository);
      createAccountUseCase = CreateAccountUseCase(accountRepository);
      updateAccountUseCase = UpdateAccountUseCase(accountRepository);
    });

    test('AccountCreateCubit maps empty name to inline field error', () async {
      final cubit = AccountCreateCubit(getCachedSessionUseCase, createAccountUseCase);

      await cubit.submit(name: '   ', type: AccountType.bank);

      expect(cubit.state.status, AccountCreateStatus.error);
      expect(cubit.state.failureCode, 'validation');
      expect(cubit.state.failureMessage, isNull);
      expect(cubit.state.nameError, AccountCreateFieldError.required);
      await cubit.close();
    });

    test('AccountCreateCubit clears name error on input change', () async {
      final cubit = AccountCreateCubit(getCachedSessionUseCase, createAccountUseCase);

      await cubit.submit(name: '', type: AccountType.bank);
      expect(cubit.state.nameError, AccountCreateFieldError.required);

      cubit.clearNameError();

      expect(cubit.state.nameError, isNull);
      await cubit.close();
    });

    test('AccountUpdateCubit maps empty name to inline field error', () async {
      final cubit = AccountUpdateCubit(getCachedSessionUseCase, updateAccountUseCase);

      await cubit.submit(accountId: 'account-1', name: ' ', type: AccountType.bank);

      expect(cubit.state.status, AccountUpdateStatus.error);
      expect(cubit.state.failureCode, 'validation');
      expect(cubit.state.failureMessage, isNull);
      expect(cubit.state.nameError, AccountUpdateFieldError.required);
      await cubit.close();
    });

    test('AccountUpdateCubit clears name error on input change', () async {
      final cubit = AccountUpdateCubit(getCachedSessionUseCase, updateAccountUseCase);

      await cubit.submit(accountId: 'account-1', name: '', type: AccountType.cash);
      expect(cubit.state.nameError, AccountUpdateFieldError.required);

      cubit.clearNameError();

      expect(cubit.state.nameError, isNull);
      await cubit.close();
    });

    test('AccountCreateCubit keeps backend validation message as banner error', () async {
      accountRepository.createResult = const FailureResult(
        Failure(code: 'validation', message: 'Backend validation message'),
      );
      final cubit = AccountCreateCubit(getCachedSessionUseCase, createAccountUseCase);

      await cubit.submit(name: 'Valid name', type: AccountType.bank);

      expect(cubit.state.status, AccountCreateStatus.error);
      expect(cubit.state.nameError, isNull);
      expect(cubit.state.failureCode, 'validation');
      expect(cubit.state.failureMessage, 'Backend validation message');
      await cubit.close();
    });

    test('AccountUpdateCubit keeps backend validation message as banner error', () async {
      accountRepository.updateResult = const FailureResult(
        Failure(code: 'validation', message: 'Backend validation message'),
      );
      final cubit = AccountUpdateCubit(getCachedSessionUseCase, updateAccountUseCase);

      await cubit.submit(accountId: 'account-1', name: 'Valid name', type: AccountType.bank);

      expect(cubit.state.status, AccountUpdateStatus.error);
      expect(cubit.state.nameError, isNull);
      expect(cubit.state.failureCode, 'validation');
      expect(cubit.state.failureMessage, 'Backend validation message');
      await cubit.close();
    });
  });
}

class _FakeAuthRepository implements IAuthRepository {
  @override
  Stream<AuthSessionEntity?> watchSession() => const Stream.empty();

  @override
  Future<AuthSessionEntity?> getCachedSession() async =>
      const AuthSessionEntity(userId: 'user-1', email: 'user@test.dev');

  @override
  Future<Result<void>> resendSignUpOtp(String email) async => const Success(null);

  @override
  Future<Result<void>> signInWithPassword(String email, String password) async =>
      const Success(null);

  @override
  Future<Result<OtpVerificationEntity>> signUpWithPassword(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthSessionEntity>> verifySignUpOtp(String email, String code) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthSessionEntity>> signInWithOAuth(AuthProvider provider) async {
    throw UnimplementedError();
  }

  @override
  Future<List<AuthProvider>> getAvailableProviders() async => const [];

  @override
  Future<Result<void>> signOut() async => const Success(null);

  @override
  Future<Result<void>> deleteAccount() async => const Success(null);
}

class _FakeAccountRepository implements IAccountRepository {
  Result<AccountEntity> createResult = const FailureResult(
    Failure(code: 'not_implemented', message: 'not implemented'),
  );
  Result<AccountEntity> updateResult = const FailureResult(
    Failure(code: 'not_implemented', message: 'not implemented'),
  );

  @override
  Future<Result<List<AccountEntity>>> fetchAccounts() async => const Success(<AccountEntity>[]);

  @override
  Future<Result<AccountEntity>> createAccount({
    required String name,
    required AccountType type,
  }) async => createResult;

  @override
  Future<Result<AccountEntity>> updateAccount({
    required String accountId,
    required String name,
    required AccountType type,
  }) async => updateResult;

  @override
  Future<Result<AccountEntity>> setArchived({required String accountId, required bool archived}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteAccount({required String accountId}) async => const Success(null);
}
