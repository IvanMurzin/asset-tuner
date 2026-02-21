import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/usecase/add_asset_to_account_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';

part 'subaccount_create_cubit.freezed.dart';
part 'subaccount_create_state.dart';

class SubaccountCreateCubit extends Cubit<SubaccountCreateState> {
  SubaccountCreateCubit(this._getCachedSession, this._addAssetToAccount)
    : super(const SubaccountCreateState());

  final GetCachedSessionUseCase _getCachedSession;
  final AddAssetToAccountUseCase _addAssetToAccount;

  Future<void> submit({
    required String accountId,
    required String name,
    required String assetId,
    required Decimal snapshotAmount,
  }) async {
    if (name.trim().isEmpty) {
      emit(
        state.copyWith(
          status: SubaccountCreateStatus.error,
          failureCode: 'validation',
          failureMessage: 'Name is required',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: SubaccountCreateStatus.loading,
        failureCode: null,
        failureMessage: null,
      ),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(
        state.copyWith(
          status: SubaccountCreateStatus.error,
          failureCode: 'unauthorized',
        ),
      );
      return;
    }

    final result = await _addAssetToAccount(
      accountId: accountId,
      name: name.trim(),
      assetId: assetId,
      snapshotAmount: snapshotAmount,
      entryDate: DateTime.now(),
    );
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success<AccountAssetEntity>(value: final subaccount):
        emit(
          state.copyWith(
            status: SubaccountCreateStatus.success,
            subaccount: subaccount,
          ),
        );
      case FailureResult<AccountAssetEntity>(failure: final failure):
        emit(
          state.copyWith(
            status: SubaccountCreateStatus.error,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }

  void reset() {
    emit(const SubaccountCreateState());
  }
}
