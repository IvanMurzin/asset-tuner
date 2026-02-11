import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/core/local_storage/overview_cache_storage.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/repository/i_account_repository.dart';
import 'package:asset_tuner/domain/account/usecase/get_accounts_usecase.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/repository/i_account_asset_repository.dart';
import 'package:asset_tuner/domain/account_asset/usecase/get_account_assets_usecase.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/repository/i_asset_repository.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_usecase.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_history_page_entity.dart';
import 'package:asset_tuner/domain/balance/repository/i_balance_repository.dart';
import 'package:asset_tuner/domain/balance/usecase/get_current_balances_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/repository/i_rate_repository.dart';
import 'package:asset_tuner/domain/rate/usecase/get_latest_usd_rates_usecase.dart';
import 'package:asset_tuner/presentation/overview/bloc/overview_cubit.dart';
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
  FakeProfileRepository(this.profile);

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

class FakeRateRepository implements IRateRepository {
  FakeRateRepository(this.result);

  final Result<RatesSnapshotEntity?> result;

  @override
  Future<Result<RatesSnapshotEntity?>> fetchLatestUsdRates() async {
    return result;
  }
}

class FakeAccountRepository implements IAccountRepository {
  FakeAccountRepository(this.accountsResult);

  final Result<List<AccountEntity>> accountsResult;

  @override
  Future<Result<List<AccountEntity>>> fetchAccounts() async {
    return accountsResult;
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

class FakeAccountAssetRepository implements IAccountAssetRepository {
  @override
  Future<Result<List<AccountAssetEntity>>> fetchAccountAssets({
    required String accountId,
  }) async {
    return const Success(<AccountAssetEntity>[]);
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

class FakeAssetRepository implements IAssetRepository {
  @override
  Future<Result<List<AssetEntity>>> fetchAssets() async {
    return const Success(<AssetEntity>[]);
  }
}

class FakeBalanceRepository implements IBalanceRepository {
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
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<BalanceEntryEntity>> updateBalance({
    required String accountAssetId,
    required DateTime entryDate,
    Decimal? snapshotAmount,
    Decimal? deltaAmount,
  }) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }
}

class FakeOverviewCacheStorage extends OverviewCacheStorage {
  @override
  Future<StoredOverviewSnapshot?> readSnapshot(String userId) async {
    return null;
  }

  @override
  Future<void> writeSnapshot(
    String userId,
    StoredOverviewSnapshot snapshot,
  ) async {}

  @override
  Future<void> deleteSnapshot(String userId) async {}
}

void main() {
  test('load sets ratesAsOf when rates available', () async {
    final asOf = DateTime(2026, 2, 10, 12, 0);
    final cubit = OverviewCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      GetProfileUseCase(FakeProfileRepository(freeProfile())),
      BootstrapProfileUseCase(FakeProfileRepository(freeProfile())),
      GetAccountsUseCase(
        FakeAccountRepository(const Success(<AccountEntity>[])),
      ),
      GetAccountAssetsUseCase(FakeAccountAssetRepository()),
      GetAssetsUseCase(FakeAssetRepository()),
      GetCurrentBalancesUseCase(FakeBalanceRepository()),
      GetLatestUsdRatesUseCase(
        FakeRateRepository(
          Success(RatesSnapshotEntity(usdPriceByAssetId: const {}, asOf: asOf)),
        ),
      ),
      FakeOverviewCacheStorage(),
    );

    await cubit.load();

    expect(cubit.state.ratesAsOf, asOf);
  });

  test('load keeps ratesAsOf null when rates missing', () async {
    final cubit = OverviewCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      GetProfileUseCase(FakeProfileRepository(freeProfile())),
      BootstrapProfileUseCase(FakeProfileRepository(freeProfile())),
      GetAccountsUseCase(
        FakeAccountRepository(const Success(<AccountEntity>[])),
      ),
      GetAccountAssetsUseCase(FakeAccountAssetRepository()),
      GetAssetsUseCase(FakeAssetRepository()),
      GetCurrentBalancesUseCase(FakeBalanceRepository()),
      GetLatestUsdRatesUseCase(FakeRateRepository(const Success(null))),
      FakeOverviewCacheStorage(),
    );

    await cubit.load();

    expect(cubit.state.ratesAsOf, isNull);
  });
}
