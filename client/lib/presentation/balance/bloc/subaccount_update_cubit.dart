import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/usecase/rename_subaccount_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';

part 'subaccount_update_cubit.freezed.dart';
part 'subaccount_update_state.dart';

class SubaccountUpdateCubit extends Cubit<SubaccountUpdateState> {
  SubaccountUpdateCubit(this._getCachedSession, this._renameSubaccount)
    : super(const SubaccountUpdateState());

  final GetCachedSessionUseCase _getCachedSession;
  final RenameSubaccountUseCase _renameSubaccount;

  Future<void> submit({
    required String subaccountId,
    required String name,
  }) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      emit(
        state.copyWith(
          status: SubaccountUpdateStatus.error,
          failureCode: 'validation',
          failureMessage: 'Name is required',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: SubaccountUpdateStatus.loading,
        failureCode: null,
        failureMessage: null,
      ),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(
        state.copyWith(
          status: SubaccountUpdateStatus.error,
          failureCode: 'unauthorized',
        ),
      );
      return;
    }

    final result = await _renameSubaccount(
      subaccountId: subaccountId,
      name: normalized,
    );
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success<AccountAssetEntity>(value: final subaccount):
        emit(
          state.copyWith(
            status: SubaccountUpdateStatus.success,
            subaccount: subaccount,
          ),
        );
      case FailureResult<AccountAssetEntity>(failure: final failure):
        emit(
          state.copyWith(
            status: SubaccountUpdateStatus.error,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }

  void reset() {
    emit(const SubaccountUpdateState());
  }
}
