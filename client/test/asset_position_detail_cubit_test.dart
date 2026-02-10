import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:asset_tuner/domain/balance/usecase/get_balance_history_usecase.dart';
import 'package:asset_tuner/domain/profile/entity/profile_bootstrap_entity.dart';
import 'package:asset_tuner/domain/profile/entity/profile_entity.dart';
import 'package:asset_tuner/domain/profile/repository/i_profile_repository.dart';
import 'package:asset_tuner/domain/profile/usecase/bootstrap_profile_usecase.dart';
import 'package:asset_tuner/domain/profile/usecase/get_profile_usecase.dart';
import 'package:asset_tuner/domain/rate/entity/rates_snapshot_entity.dart';
import 'package:asset_tuner/domain/rate/repository/i_rate_repository.dart';
import 'package:asset_tuner/domain/rate/usecase/get_latest_usd_rates_usecase.dart';
import 'package:asset_tuner/presentation/balance/bloc/asset_position_detail_cubit.dart';

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
  Future<Result<void>> deleteAccount(String userId) async {
    return const FailureResult(
      Failure(code: 'validation', message: 'Not used'),
    );
  }
}

class FakeAccountRepository implements IAccountRepository {
  FakeAccountRepository(this.accounts);

  final List<AccountEntity> accounts;

  @override
  Future<Result<List<AccountEntity>>> fetchAccounts(String userId) async {
    return Success(accounts.where((a) => a.userId == userId).toList());
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
    return Success(positionsByAccount[accountId] ?? []);
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
  FakeBalanceRepository(this.entriesByPosition);

  final Map<String, List<BalanceEntryEntity>> entriesByPosition;

  @override
  Future<Result<Map<String, Decimal>>> fetchCurrentBalances({
    required String userId,
    required Set<String> accountAssetIds,
  }) async {
    return const Success(<String, Decimal>{});
  }

  @override
  Future<Result<BalanceHistoryPageEntity>> fetchHistory({
    required String userId,
    required String accountAssetId,
    required int limit,
    int? offset,
  }) async {
    final all =
        <BalanceEntryEntity>[
          ...(entriesByPosition[accountAssetId] ??
              const <BalanceEntryEntity>[]),
        ]..sort((a, b) {
          final dateCmp = b.entryDate.compareTo(a.entryDate);
          if (dateCmp != 0) return dateCmp;
          return b.createdAt.compareTo(a.createdAt);
        });
    final start = offset ?? 0;
    final page = all.skip(start).take(limit).toList();
    final next = start + page.length < all.length ? start + page.length : null;
    return Success(BalanceHistoryPageEntity(entries: page, nextOffset: next));
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

void main() {
  test('load navigates to sign-in when session missing', () async {
    final cubit = AssetPositionDetailCubit(
      GetCachedSessionUseCase(FakeAuthRepository()),
      GetProfileUseCase(
        FakeProfileRepository(
          const ProfileEntity(
            userId: 'user_1',
            baseCurrency: 'USD',
            plan: 'free',
          ),
        ),
      ),
      BootstrapProfileUseCase(
        FakeProfileRepository(
          const ProfileEntity(
            userId: 'user_1',
            baseCurrency: 'USD',
            plan: 'free',
          ),
        ),
      ),
      GetAccountsUseCase(FakeAccountRepository([])),
      GetAccountAssetsUseCase(FakeAccountAssetRepository(const {})),
      GetAssetsUseCase(FakeAssetRepository(const [])),
      GetBalanceHistoryUseCase(FakeBalanceRepository(const {})),
      GetLatestUsdRatesUseCase(FakeRateRepository(const Success(null))),
    );

    await cubit.load(accountId: 'acc_1', assetId: 'asset_usd');

    expect(
      cubit.state.navigation?.destination,
      AssetPositionDetailDestination.signIn,
    );
  });

  test('load computes current balance from snapshots and deltas', () async {
    final user = const AuthSessionEntity(userId: 'user_1', email: 'a@b.com');
    final now = DateTime(2026, 2, 10);

    final accounts = [
      AccountEntity(
        id: 'acc_1',
        userId: 'user_1',
        name: 'Cash',
        type: AccountType.cash,
        archived: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    final positions = {
      'acc_1': [
        AccountAssetEntity(
          id: 'pos_1',
          accountId: 'acc_1',
          assetId: 'asset_usd',
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
    ];

    final entries = {
      'pos_1': [
        BalanceEntryEntity(
          id: 'e1',
          accountAssetId: 'pos_1',
          entryDate: DateTime(2026, 2, 1),
          entryType: BalanceEntryType.snapshot,
          snapshotAmount: Decimal.parse('100'),
          createdAt: DateTime(2026, 2, 1, 10, 0),
        ),
        BalanceEntryEntity(
          id: 'e2',
          accountAssetId: 'pos_1',
          entryDate: DateTime(2026, 2, 5),
          entryType: BalanceEntryType.delta,
          deltaAmount: Decimal.parse('-20'),
          createdAt: DateTime(2026, 2, 5, 11, 0),
        ),
        BalanceEntryEntity(
          id: 'e3',
          accountAssetId: 'pos_1',
          entryDate: DateTime(2026, 2, 7),
          entryType: BalanceEntryType.snapshot,
          snapshotAmount: Decimal.parse('50'),
          createdAt: DateTime(2026, 2, 7, 9, 0),
        ),
        BalanceEntryEntity(
          id: 'e4',
          accountAssetId: 'pos_1',
          entryDate: DateTime(2026, 2, 8),
          entryType: BalanceEntryType.delta,
          deltaAmount: Decimal.parse('10'),
          createdAt: DateTime(2026, 2, 8, 12, 0),
        ),
      ],
    };

    final profile = const ProfileEntity(
      userId: 'user_1',
      baseCurrency: 'USD',
      plan: 'free',
    );
    final rates = RatesSnapshotEntity(
      usdPriceByAssetId: {'asset_usd': Decimal.one},
      asOf: DateTime(2026, 2, 10, 12, 0),
    );

    final cubit = AssetPositionDetailCubit(
      GetCachedSessionUseCase(FakeAuthRepository(cachedSession: user)),
      GetProfileUseCase(FakeProfileRepository(profile)),
      BootstrapProfileUseCase(FakeProfileRepository(profile)),
      GetAccountsUseCase(FakeAccountRepository(accounts)),
      GetAccountAssetsUseCase(FakeAccountAssetRepository(positions)),
      GetAssetsUseCase(FakeAssetRepository(assets)),
      GetBalanceHistoryUseCase(FakeBalanceRepository(entries)),
      GetLatestUsdRatesUseCase(FakeRateRepository(Success(rates))),
    );

    await cubit.load(accountId: 'acc_1', assetId: 'asset_usd');

    expect(cubit.state.currentBalance, Decimal.parse('60'));
    expect(cubit.state.convertedValue, Decimal.parse('60'));
    expect(cubit.state.entries, isNotEmpty);
  });
}
