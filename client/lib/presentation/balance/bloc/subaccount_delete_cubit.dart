import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/subaccount/usecase/delete_subaccount_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';

part 'subaccount_delete_cubit.freezed.dart';
part 'subaccount_delete_state.dart';

class SubaccountDeleteCubit extends Cubit<SubaccountDeleteState> {
  SubaccountDeleteCubit(this._getCachedSession, this._deleteSubaccount)
    : super(const SubaccountDeleteState());

  final GetCachedSessionUseCase _getCachedSession;
  final DeleteSubaccountUseCase _deleteSubaccount;

  Future<void> submit(String subaccountId) async {
    emit(
      state.copyWith(
        status: SubaccountDeleteStatus.loading,
        failureCode: null,
        failureMessage: null,
      ),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(state.copyWith(status: SubaccountDeleteStatus.error, failureCode: 'unauthorized'));
      return;
    }

    final result = await _deleteSubaccount(subaccountId: subaccountId);
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success<void>():
        emit(
          state.copyWith(status: SubaccountDeleteStatus.success, deletedSubaccountId: subaccountId),
        );
      case FailureResult<void>(failure: final failure):
        emit(
          state.copyWith(
            status: SubaccountDeleteStatus.error,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }

  void reset() {
    emit(const SubaccountDeleteState());
  }
}
