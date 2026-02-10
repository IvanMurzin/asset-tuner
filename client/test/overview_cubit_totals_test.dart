import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/local_storage/overview_cache_storage.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
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

class FakeAuthRepository implements IAuthRepository {
  FakeAuthRepository({required this.cachedSession});

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
  Future<Result<void>> deleteAccount(String userId) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }
}

class FakeProfileRepository implements IProfileRepository {
  FakeProfileRepository(this.profile);

  final ProfileEntity profile;

  @override
  Future<Result<ProfileBootstrapEntity>> ensureProfile(String userId) async {
    return Success(
      ProfileBootstrapEntity(
        profile: profile,
        isNew: false,
        wasBaseCurrencyDefaulted: false,
      ),
    );
  }

  @override
  Future<Result<ProfileEntity>> getProfile(String userId) async {
    return Success(profile);
  }

  @override
  Future<Result<ProfileEntity>> updateBaseCurrency(
    String userId,
    String baseCurrency,
  ) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<ProfileEntity>> updatePlan(String userId, String plan) async {
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
  FakeAccountRepository(this.result);

  final Result<List<AccountEntity>> result;

  @override
  Future<Result<List<AccountEntity>>> fetchAccounts(String userId) async {
    return result;
  }

  @override
  Future<Result<AccountEntity>> createAccount({
    required String userId,
    required String name,
    required AccountType type,
  }) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<AccountEntity>> updateAccount({
    required String userId,
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
    required String userId,
    required String accountId,
    required bool archived,
  }) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<void>> deleteAccount({
    required String userId,
    required String accountId,
  }) async {
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
    required String userId,
    required String accountId,
  }) async {
    return Success(positionsByAccount[accountId] ?? const []);
  }

  @override
  Future<Result<int>> countAssetPositions(String userId) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<AccountAssetEntity>> addAssetToAccount({
    required String userId,
    required String accountId,
    required String assetId,
  }) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }

  @override
  Future<Result<void>> removeAssetFromAccount({
    required String userId,
    required String accountId,
    required String assetId,
  }) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }
}

class FakeAssetRepository implements IAssetRepository {
  FakeAssetRepository(this.assets);

  final List<AssetEntity> assets;

  @override
  Future<Result<List<AssetEntity>>> fetchAssets() async {
    return Success(assets);
  }
}

class FakeBalanceRepository implements IBalanceRepository {
  FakeBalanceRepository(this.currentBalances);

  final Map<String, Decimal> currentBalances;

  @override
  Future<Result<Map<String, Decimal>>> fetchCurrentBalances({
    required String userId,
    required Set<String> accountAssetIds,
  }) async {
    return Success({
      for (final id in accountAssetIds)
        if (currentBalances.containsKey(id)) id: currentBalances[id]!,
    });
  }

  @override
  Future<Result<BalanceHistoryPageEntity>> fetchHistory({
    required String userId,
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
    required String userId,
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
  FakeOverviewCacheStorage({this.snapshot});

  StoredOverviewSnapshot? snapshot;

  @override
  Future<StoredOverviewSnapshot?> readSnapshot(String userId) async {
    return snapshot;
  }

  @override
  Future<void> writeSnapshot(
    String userId,
    StoredOverviewSnapshot snapshot,
  ) async {
    this.snapshot = snapshot;
  }

  @override
  Future<void> deleteSnapshot(String userId) async {}
}

void main() {
  test('missing rates yields pricedTotal and fullTotal N/A', () async {
    final now = DateTime(2026, 2, 10);
    final profile = const ProfileEntity(
      userId: 'user_1',
      baseCurrency: 'USD',
      plan: 'free',
    );
    final rates = RatesSnapshotEntity(
      usdPriceByAssetId: {'asset_usd': Decimal.one},
      asOf: DateTime(2026, 2, 10, 12, 0),
    );

    final accounts = [
      AccountEntity(
        id: 'acc_1',
        userId: 'user_1',
        name: 'Main',
        type: AccountType.cash,
        archived: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    final positions = {
      'acc_1': [
        AccountAssetEntity(
          id: 'pos_usd',
          accountId: 'acc_1',
          assetId: 'asset_usd',
          createdAt: now,
        ),
        AccountAssetEntity(
          id: 'pos_btc',
          accountId: 'acc_1',
          assetId: 'asset_btc',
          createdAt: now,
        ),
      ],
    };
    final assets = const [
      AssetEntity(
        id: 'asset_usd',
        kind: AssetKind.fiat,
        code: 'USD',
        name: 'United States Dollar',
      ),
      AssetEntity(
        id: 'asset_btc',
        kind: AssetKind.crypto,
        code: 'BTC',
        name: 'Bitcoin',
      ),
    ];

    final cubit = OverviewCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      GetProfileUseCase(FakeProfileRepository(profile)),
      BootstrapProfileUseCase(FakeProfileRepository(profile)),
      GetAccountsUseCase(FakeAccountRepository(Success(accounts))),
      GetAccountAssetsUseCase(FakeAccountAssetRepository(positions)),
      GetAssetsUseCase(FakeAssetRepository(assets)),
      GetCurrentBalancesUseCase(
        FakeBalanceRepository({
          'pos_usd': Decimal.parse('1000'),
          'pos_btc': Decimal.parse('2'),
        }),
      ),
      GetLatestUsdRatesUseCase(FakeRateRepository(Success(rates))),
      FakeOverviewCacheStorage(),
    );

    await cubit.load();

    expect(cubit.state.status, OverviewStatus.ready);
    expect(cubit.state.fullTotal, isNull);
    expect(cubit.state.pricedTotal, Decimal.parse('1000'));
    expect(cubit.state.hasUnpricedHoldings, isTrue);
    expect(cubit.state.unpricedHoldings.length, 1);
    expect(cubit.state.unpricedHoldings.first.assetCode, 'BTC');
    expect(cubit.state.ratesAsOf, rates.asOf);
  });

  test('uses cached snapshot when accounts fetch fails', () async {
    final computedAt = DateTime(2026, 2, 10, 8, 0);
    final cache = FakeOverviewCacheStorage(
      snapshot: StoredOverviewSnapshot(
        computedAtIso: computedAt.toIso8601String(),
        baseCurrencyCode: 'USD',
        fullTotal: '123',
        pricedTotal: null,
        hasUnpricedHoldings: false,
        ratesAsOfIso: null,
        accountTotals: const [
          StoredOverviewAccountTotal(
            accountId: 'acc_1',
            accountName: 'Main',
            total: '123',
            hasUnpriced: false,
          ),
        ],
        unpricedHoldings: const [],
      ),
    );

    final profile = const ProfileEntity(
      userId: 'user_1',
      baseCurrency: 'USD',
      plan: 'free',
    );

    final cubit = OverviewCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      GetProfileUseCase(FakeProfileRepository(profile)),
      BootstrapProfileUseCase(FakeProfileRepository(profile)),
      GetAccountsUseCase(
        FakeAccountRepository(
          const FailureResult(Failure(code: 'network', message: 'Offline')),
        ),
      ),
      GetAccountAssetsUseCase(FakeAccountAssetRepository(const {})),
      GetAssetsUseCase(FakeAssetRepository(const [])),
      GetCurrentBalancesUseCase(FakeBalanceRepository(const {})),
      GetLatestUsdRatesUseCase(FakeRateRepository(const Success(null))),
      cache,
    );

    await cubit.load();

    expect(cubit.state.status, OverviewStatus.ready);
    expect(cubit.state.isOffline, isTrue);
    expect(cubit.state.offlineCachedAt, computedAt);
    expect(cubit.state.fullTotal, Decimal.parse('123'));
    expect(cubit.state.failureCode, 'network');
  });
}
