import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/types/failure.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/auth/entity/auth_provider.dart';
import 'package:asset_tuner/domain/auth/entity/auth_session_entity.dart';
import 'package:asset_tuner/domain/auth/entity/otp_verification_entity.dart';
import 'package:asset_tuner/domain/auth/repository/i_auth_repository.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/domain/subaccount/repository/i_subaccount_repository.dart';
import 'package:asset_tuner/domain/subaccount/usecase/create_subaccount_usecase.dart';
import 'package:asset_tuner/presentation/balance/bloc/subaccount_create_cubit.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubaccountCreateCubit validation', () {
    late _FakeSubaccountRepository subaccountRepository;
    late SubaccountCreateCubit cubit;

    setUp(() {
      subaccountRepository = _FakeSubaccountRepository();
      cubit = SubaccountCreateCubit(
        GetCachedSessionUseCase(_FakeAuthRepository()),
        CreateSubaccountUseCase(subaccountRepository),
        AppAnalytics(),
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('maps empty name to inline field error', () async {
      await cubit.submit(
        accountId: 'account-1',
        name: ' ',
        asset: const AssetEntity(
          id: 'asset-1',
          kind: AssetKind.fiat,
          code: 'USD',
          name: 'US Dollar',
        ),
        snapshotAmount: Decimal.one,
      );

      expect(cubit.state.status, SubaccountCreateStatus.error);
      expect(cubit.state.failureCode, 'validation');
      expect(cubit.state.failureMessage, isNull);
      expect(cubit.state.nameError, SubaccountCreateFieldError.required);
    });

    test('clearNameError resets inline validation state', () async {
      await cubit.submit(
        accountId: 'account-1',
        name: '',
        asset: const AssetEntity(
          id: 'asset-1',
          kind: AssetKind.crypto,
          code: 'BTC',
          name: 'Bitcoin',
        ),
        snapshotAmount: Decimal.fromInt(2),
      );
      expect(cubit.state.nameError, SubaccountCreateFieldError.required);

      cubit.clearNameError();

      expect(cubit.state.nameError, isNull);
    });

    test('keeps backend validation message as banner error', () async {
      subaccountRepository.createResult = const FailureResult(
        Failure(code: 'validation', message: 'Backend validation message'),
      );

      await cubit.submit(
        accountId: 'account-1',
        name: 'Main balance',
        asset: const AssetEntity(
          id: 'asset-1',
          kind: AssetKind.crypto,
          code: 'BTC',
          name: 'Bitcoin',
        ),
        snapshotAmount: Decimal.fromInt(1),
      );

      expect(cubit.state.status, SubaccountCreateStatus.error);
      expect(cubit.state.nameError, isNull);
      expect(cubit.state.failureCode, 'validation');
      expect(cubit.state.failureMessage, 'Backend validation message');
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

class _FakeSubaccountRepository implements ISubaccountRepository {
  Result<SubaccountEntity> createResult = const FailureResult(
    Failure(code: 'not_implemented', message: 'not implemented'),
  );

  @override
  Future<Result<List<SubaccountEntity>>> fetchSubaccounts({required String accountId}) async =>
      const Success(<SubaccountEntity>[]);

  @override
  Future<Result<SubaccountEntity>> createSubaccount({
    required String accountId,
    required String name,
    required AssetEntity asset,
    required Decimal snapshotAmount,
    required DateTime entryDate,
  }) async => createResult;

  @override
  Future<Result<SubaccountEntity>> renameSubaccount({
    required String subaccountId,
    required String name,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteSubaccount({required String subaccountId}) async =>
      const Success(null);
}
