import 'package:flutter_test/flutter_test.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/repository/i_account_asset_repository.dart';
import 'package:asset_tuner/domain/account_asset/usecase/add_asset_to_account_usecase.dart';
import 'package:asset_tuner/domain/account_asset/usecase/count_asset_positions_usecase.dart';
import 'package:asset_tuner/domain/account_asset/usecase/get_account_assets_usecase.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/repository/i_asset_repository.dart';
import 'package:asset_tuner/domain/asset/usecase/get_assets_usecase.dart';
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
import 'package:asset_tuner/presentation/account/bloc/add_asset_cubit.dart';
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

class FakeAssetRepository implements IAssetRepository {
  FakeAssetRepository(this.assets);

  final List<AssetEntity> assets;

  @override
  Future<Result<List<AssetEntity>>> fetchAssets() async {
    return Success(assets);
  }
}

class FakeAccountAssetRepository implements IAccountAssetRepository {
  FakeAccountAssetRepository({
    required this.positionsByAccount,
    required this.totalPositionsCount,
  });

  final Map<String, List<AccountAssetEntity>> positionsByAccount;
  int totalPositionsCount;

  @override
  Future<Result<List<AccountAssetEntity>>> fetchAccountAssets({
    required String accountId,
  }) async {
    return Success(positionsByAccount[accountId] ?? []);
  }

  @override
  Future<Result<int>> countAssetPositions() async {
    return Success(totalPositionsCount);
  }

  @override
  Future<Result<AccountAssetEntity>> addAssetToAccount({
    required String accountId,
    required String assetId,
  }) async {
    final now = DateTime(2026, 2, 10);
    final created = AccountAssetEntity(
      id: 'pos_1',
      accountId: accountId,
      assetId: assetId,
      createdAt: now,
    );
    final list = <AccountAssetEntity>[
      ...(positionsByAccount[accountId] ?? const []),
      created,
    ];
    positionsByAccount[accountId] = list;
    totalPositionsCount += 1;
    return Success(created);
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

void main() {
  test('load navigates to sign-in when session missing', () async {
    final cubit = AddAssetCubit(
      GetCachedSessionUseCase(FakeAuthRepository()),
      GetProfileUseCase(FakeProfileRepository(profile: freeProfile())),
      BootstrapProfileUseCase(FakeProfileRepository(profile: freeProfile())),
      GetAssetsUseCase(
        FakeAssetRepository(const [
          AssetEntity(
            id: 'asset_usd',
            kind: AssetKind.fiat,
            code: 'USD',
            name: 'United States Dollar',
          ),
        ]),
      ),
      GetAccountAssetsUseCase(
        FakeAccountAssetRepository(
          positionsByAccount: {},
          totalPositionsCount: 0,
        ),
      ),
      CountAssetPositionsUseCase(
        FakeAccountAssetRepository(
          positionsByAccount: {},
          totalPositionsCount: 0,
        ),
      ),
      AddAssetToAccountUseCase(
        FakeAccountAssetRepository(
          positionsByAccount: {},
          totalPositionsCount: 0,
        ),
      ),
    );

    await cubit.load('acc_1');

    expect(cubit.state.navigation?.destination, AddAssetDestination.signIn);
  });

  test('selectAsset shows duplicate error when already in account', () async {
    final repo = FakeAccountAssetRepository(
      positionsByAccount: {
        'acc_1': [
          AccountAssetEntity(
            id: 'pos_0',
            accountId: 'acc_1',
            assetId: 'asset_usd',
            createdAt: DateTime(2026, 2, 10),
          ),
        ],
      },
      totalPositionsCount: 1,
    );

    final cubit = AddAssetCubit(
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
      GetAssetsUseCase(
        FakeAssetRepository(const [
          AssetEntity(
            id: 'asset_usd',
            kind: AssetKind.fiat,
            code: 'USD',
            name: 'United States Dollar',
          ),
        ]),
      ),
      GetAccountAssetsUseCase(repo),
      CountAssetPositionsUseCase(repo),
      AddAssetToAccountUseCase(repo),
    );

    await cubit.load('acc_1');
    cubit.selectAsset('asset_usd');

    expect(cubit.state.duplicateError, isTrue);
  });

  test(
    'addSelected routes to paywall when free and positions limit reached',
    () async {
      final repo = FakeAccountAssetRepository(
        positionsByAccount: {'acc_1': []},
        totalPositionsCount: 20,
      );

      final cubit = AddAssetCubit(
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
        GetAssetsUseCase(
          FakeAssetRepository(const [
            AssetEntity(
              id: 'asset_btc',
              kind: AssetKind.crypto,
              code: 'BTC',
              name: 'Bitcoin',
            ),
          ]),
        ),
        GetAccountAssetsUseCase(repo),
        CountAssetPositionsUseCase(repo),
        AddAssetToAccountUseCase(repo),
      );

      await cubit.load('acc_1');
      cubit.selectAsset('asset_btc');
      await cubit.addSelected();

      expect(cubit.state.navigation?.destination, AddAssetDestination.paywall);
    },
  );

  test('addSelected navigates backAdded on success', () async {
    final repo = FakeAccountAssetRepository(
      positionsByAccount: {'acc_1': []},
      totalPositionsCount: 0,
    );

    final cubit = AddAssetCubit(
      GetCachedSessionUseCase(
        FakeAuthRepository(
          cachedSession: const AuthSessionEntity(
            userId: 'user_1',
            email: 'user@example.com',
          ),
        ),
      ),
      GetProfileUseCase(FakeProfileRepository(profile: paidProfile())),
      BootstrapProfileUseCase(FakeProfileRepository(profile: paidProfile())),
      GetAssetsUseCase(
        FakeAssetRepository(const [
          AssetEntity(
            id: 'asset_btc',
            kind: AssetKind.crypto,
            code: 'BTC',
            name: 'Bitcoin',
          ),
        ]),
      ),
      GetAccountAssetsUseCase(repo),
      CountAssetPositionsUseCase(repo),
      AddAssetToAccountUseCase(repo),
    );

    await cubit.load('acc_1');
    cubit.selectAsset('asset_btc');
    await cubit.addSelected();

    expect(cubit.state.navigation?.destination, AddAssetDestination.backAdded);
  });
}
