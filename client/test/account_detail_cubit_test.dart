import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/repository/i_account_repository.dart';
import 'package:asset_tuner/domain/account/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/account/usecase/get_accounts_usecase.dart';
import 'package:asset_tuner/domain/account/usecase/set_account_archived_usecase.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/repository/i_account_asset_repository.dart';
import 'package:asset_tuner/domain/account_asset/usecase/get_account_assets_usecase.dart';
import 'package:asset_tuner/domain/account_asset/usecase/remove_asset_from_account_usecase.dart';
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
import 'package:asset_tuner/presentation/account/bloc/account_detail_cubit.dart';
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

class FakeAccountRepository implements IAccountRepository {
  FakeAccountRepository(this.accounts);

  final List<AccountEntity> accounts;

  @override
  Future<Result<List<AccountEntity>>> fetchAccounts() async {
    return Success(accounts);
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
    final idx = accounts.indexWhere((a) => a.id == accountId);
    if (idx < 0) {
      return const FailureResult(
        Failure(code: 'not_found', message: 'Not found'),
      );
    }
    accounts[idx] = accounts[idx].copyWith(archived: archived);
    return Success(accounts[idx]);
  }

  @override
  Future<Result<void>> deleteAccount({
    required String accountId,
  }) async {
    accounts.removeWhere((a) => a.id == accountId);
    return const Success(null);
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
    positionsByAccount[accountId] = (positionsByAccount[accountId] ?? [])
        .where((p) => p.assetId != assetId)
        .toList();
    return const Success(null);
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

class FakeBalanceRepository implements IBalanceRepository {
  FakeBalanceRepository(this.currentBalances);

  final Map<String, Decimal> currentBalances;

  @override
  Future<Result<Map<String, Decimal>>> fetchCurrentBalances({
    required Set<String> accountAssetIds,
  }) async {
    return Success({
      for (final id in accountAssetIds)
        if (currentBalances.containsKey(id)) id: currentBalances[id]!,
    });
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

void main() {
  test('load navigates to sign-in when session missing', () async {
    final cubit = AccountDetailCubit(
      GetCachedSessionUseCase(FakeAuthRepository()),
      GetProfileUseCase(FakeProfileRepository(freeProfile())),
      BootstrapProfileUseCase(FakeProfileRepository(freeProfile())),
      GetAccountsUseCase(FakeAccountRepository([])),
      GetAssetsUseCase(FakeAssetRepository(const [])),
      GetAccountAssetsUseCase(FakeAccountAssetRepository({})),
      GetCurrentBalancesUseCase(FakeBalanceRepository(const {})),
      GetLatestUsdRatesUseCase(FakeRateRepository(const Success(null))),
      RemoveAssetFromAccountUseCase(FakeAccountAssetRepository({})),
      SetAccountArchivedUseCase(FakeAccountRepository([])),
      DeleteAccountUseCase(FakeAccountRepository([])),
    );

    await cubit.load('acc_1');

    expect(
      cubit.state.navigation?.destination,
      AccountDetailDestination.signIn,
    );
  });

  test('load builds asset view items', () async {
    final now = DateTime(2026, 2, 10);
    final accounts = [
      AccountEntity(
        id: 'acc_1',
        name: 'Cash',
        type: AccountType.cash,
        archived: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    final assets = const [
      AssetEntity(
        id: 'asset_usd',
        kind: AssetKind.fiat,
        code: 'USD',
        name: 'United States Dollar',
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

    final profile = freeProfile();
    final rates = RatesSnapshotEntity(
      usdPriceByAssetId: {'asset_usd': Decimal.one},
      asOf: DateTime(2026, 2, 10, 12, 0),
    );

    final positionsRepo = FakeAccountAssetRepository(positions);
    final cubit = AccountDetailCubit(
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
      GetAccountsUseCase(FakeAccountRepository(accounts)),
      GetAssetsUseCase(FakeAssetRepository(assets)),
      GetAccountAssetsUseCase(positionsRepo),
      GetCurrentBalancesUseCase(
        FakeBalanceRepository({'pos_1': Decimal.parse('100')}),
      ),
      GetLatestUsdRatesUseCase(FakeRateRepository(Success(rates))),
      RemoveAssetFromAccountUseCase(positionsRepo),
      SetAccountArchivedUseCase(FakeAccountRepository(accounts)),
      DeleteAccountUseCase(FakeAccountRepository(accounts)),
    );

    await cubit.load('acc_1');

    expect(cubit.state.items.length, 1);
    expect(cubit.state.items.first.assetCode, 'USD');
    expect(cubit.state.items.first.originalAmount, Decimal.parse('100'));
    expect(cubit.state.items.first.convertedAmount, Decimal.parse('100'));
  });

  test('removeAsset removes item from state on success', () async {
    final now = DateTime(2026, 2, 10);
    final accounts = [
      AccountEntity(
        id: 'acc_1',
        name: 'Cash',
        type: AccountType.cash,
        archived: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    final assets = const [
      AssetEntity(
        id: 'asset_usd',
        kind: AssetKind.fiat,
        code: 'USD',
        name: 'United States Dollar',
      ),
    ];
    final positionsRepo = FakeAccountAssetRepository({
      'acc_1': [
        AccountAssetEntity(
          id: 'pos_1',
          accountId: 'acc_1',
          assetId: 'asset_usd',
          createdAt: now,
        ),
      ],
    });

    final profile = freeProfile();
    final rates = RatesSnapshotEntity(
      usdPriceByAssetId: {'asset_usd': Decimal.one},
      asOf: DateTime(2026, 2, 10, 12, 0),
    );

    final cubit = AccountDetailCubit(
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
      GetAccountsUseCase(FakeAccountRepository(accounts)),
      GetAssetsUseCase(FakeAssetRepository(assets)),
      GetAccountAssetsUseCase(positionsRepo),
      GetCurrentBalancesUseCase(
        FakeBalanceRepository({'pos_1': Decimal.parse('100')}),
      ),
      GetLatestUsdRatesUseCase(FakeRateRepository(Success(rates))),
      RemoveAssetFromAccountUseCase(positionsRepo),
      SetAccountArchivedUseCase(FakeAccountRepository(accounts)),
      DeleteAccountUseCase(FakeAccountRepository(accounts)),
    );

    await cubit.load('acc_1');
    await cubit.removeAsset(accountId: 'acc_1', assetId: 'asset_usd');

    expect(cubit.state.items, isEmpty);
  });
}
