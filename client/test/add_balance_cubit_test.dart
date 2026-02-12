import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_history_page_entity.dart';
import 'package:asset_tuner/domain/balance/repository/i_balance_repository.dart';
import 'package:asset_tuner/domain/balance/usecase/update_balance_usecase.dart';
import 'package:asset_tuner/presentation/balance/bloc/add_balance_cubit.dart';

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

class FakeBalanceRepository implements IBalanceRepository {
  @override
  Future<Result<Map<String, Decimal>>> fetchCurrentBalances({
    required Set<String> subaccountIds,
  }) async {
    return const Success(<String, Decimal>{});
  }

  @override
  Future<Result<BalanceHistoryPageEntity>> fetchHistory({
    required String subaccountId,
    required int limit,
    int? offset,
  }) async {
    return const Success(
      BalanceHistoryPageEntity(entries: [], nextOffset: null),
    );
  }

  @override
  Future<Result<BalanceEntryEntity>> updateBalance({
    required String subaccountId,
    required DateTime entryDate,
    required Decimal snapshotAmount,
  }) async {
    return Success(
      BalanceEntryEntity(
        id: 'be_1',
        subaccountId: subaccountId,
        entryDate: entryDate,
        snapshotAmount: snapshotAmount,
        diffAmount: null,
        createdAt: DateTime(2026, 2, 10),
      ),
    );
  }
}

void main() {
  test('load navigates to sign-in when session missing', () async {
    final cubit = AddBalanceCubit(
      GetCachedSessionUseCase(FakeAuthRepository()),
      UpdateBalanceUseCase(FakeBalanceRepository()),
    );

    await cubit.load(subaccountId: 'sub_1');

    expect(cubit.state.navigation?.destination, AddBalanceDestination.signIn);
  });

  test('save validates amount required', () async {
    final cubit = AddBalanceCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      UpdateBalanceUseCase(FakeBalanceRepository()),
    );

    await cubit.load(subaccountId: 'sub_1');
    cubit.updateAmount('   ');
    await cubit.save();

    expect(cubit.state.amountError, 'required');
  });

  test('save accepts negative amount and navigates backSaved', () async {
    final cubit = AddBalanceCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      UpdateBalanceUseCase(FakeBalanceRepository()),
    );

    await cubit.load(subaccountId: 'sub_1');
    cubit.updateAmount('-10.5');
    await cubit.save();

    expect(
      cubit.state.navigation?.destination,
      AddBalanceDestination.backSaved,
    );
  });
}
