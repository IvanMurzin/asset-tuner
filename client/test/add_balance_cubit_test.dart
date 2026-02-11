import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/repository/i_account_asset_repository.dart';
import 'package:asset_tuner/domain/account_asset/usecase/get_account_assets_usecase.dart';
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

class FakeAccountAssetRepository implements IAccountAssetRepository {
  FakeAccountAssetRepository(this.positionsByAccount);

  final Map<String, List<AccountAssetEntity>> positionsByAccount;

  @override
  Future<Result<List<AccountAssetEntity>>> fetchAccountAssets({
    required String accountId,
  }) async {
    return Success(positionsByAccount[accountId] ?? []);
  }

  @override
  Future<Result<int>> countAssetPositions() async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<AccountAssetEntity>> addAssetToAccount({
    required String accountId,
    required String assetId,
  }) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<void>> removeAssetFromAccount({
    required String accountId,
    required String assetId,
  }) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }
}

class FakeBalanceRepository implements IBalanceRepository {
  FakeBalanceRepository();

  @override
  Future<Result<Map<String, Decimal>>> fetchCurrentBalances({
    required Set<String> accountAssetIds,
  }) async {
    return const Success(<String, Decimal>{});
  }

  @override
  Future<Result<BalanceHistoryPageEntity>> fetchHistory({
    required String accountAssetId,
    required int limit,
    int? offset,
  }) async {
    return const Success(
      BalanceHistoryPageEntity(entries: [], nextOffset: null),
    );
  }

  @override
  Future<Result<BalanceEntryEntity>> updateBalance({
    required String accountAssetId,
    required DateTime entryDate,
    Decimal? snapshotAmount,
    Decimal? deltaAmount,
  }) async {
    final created = BalanceEntryEntity(
      id: 'be_1',
      accountAssetId: accountAssetId,
      entryDate: entryDate,
      entryType: snapshotAmount != null
          ? BalanceEntryType.snapshot
          : BalanceEntryType.delta,
      snapshotAmount: snapshotAmount,
      deltaAmount: deltaAmount,
      impliedDeltaAmount: null,
      createdAt: DateTime(2026, 2, 10),
    );
    return Success(created);
  }
}

void main() {
  test('load navigates to sign-in when session missing', () async {
    final cubit = AddBalanceCubit(
      GetCachedSessionUseCase(FakeAuthRepository()),
      GetAccountAssetsUseCase(FakeAccountAssetRepository(const {})),
      UpdateBalanceUseCase(FakeBalanceRepository()),
    );

    await cubit.load(accountId: 'acc_1', assetId: 'asset_usd');

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
      GetAccountAssetsUseCase(
        FakeAccountAssetRepository({
          'acc_1': [
            AccountAssetEntity(
              id: 'pos_1',
              accountId: 'acc_1',
              assetId: 'asset_usd',
              createdAt: DateTime(2026, 2, 10),
            ),
          ],
        }),
      ),
      UpdateBalanceUseCase(FakeBalanceRepository()),
    );

    await cubit.load(accountId: 'acc_1', assetId: 'asset_usd');
    cubit.updateAmount('   ');
    await cubit.save();

    expect(cubit.state.amountError, 'required');
  });

  test('save delta accepts negative amount and navigates backSaved', () async {
    final cubit = AddBalanceCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      GetAccountAssetsUseCase(
        FakeAccountAssetRepository({
          'acc_1': [
            AccountAssetEntity(
              id: 'pos_1',
              accountId: 'acc_1',
              assetId: 'asset_usd',
              createdAt: DateTime(2026, 2, 10),
            ),
          ],
        }),
      ),
      UpdateBalanceUseCase(FakeBalanceRepository()),
    );

    await cubit.load(accountId: 'acc_1', assetId: 'asset_usd');
    cubit.selectType(BalanceEntryType.delta);
    cubit.updateAmount('-10.5');
    await cubit.save();

    expect(
      cubit.state.navigation?.destination,
      AddBalanceDestination.backSaved,
    );
  });
}
