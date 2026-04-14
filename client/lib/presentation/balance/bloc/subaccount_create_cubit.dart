import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/domain/subaccount/usecase/create_subaccount_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';

part 'subaccount_create_cubit.freezed.dart';
part 'subaccount_create_state.dart';

@injectable
class SubaccountCreateCubit extends Cubit<SubaccountCreateState> {
  SubaccountCreateCubit(this._getCachedSession, this._createSubaccount)
    : super(const SubaccountCreateState());

  final GetCachedSessionUseCase _getCachedSession;
  final CreateSubaccountUseCase _createSubaccount;

  Future<void> submit({
    required String accountId,
    required String name,
    required AssetEntity asset,
    required Decimal snapshotAmount,
  }) async {
    if (name.trim().isEmpty) {
      emit(
        state.copyWith(
          status: SubaccountCreateStatus.error,
          nameError: SubaccountCreateFieldError.required,
          failureCode: 'validation',
          failureMessage: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: SubaccountCreateStatus.loading,
        nameError: null,
        failureCode: null,
        failureMessage: null,
      ),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(state.copyWith(status: SubaccountCreateStatus.error, failureCode: 'unauthorized'));
      return;
    }

    final result = await _createSubaccount(
      accountId: accountId,
      name: name.trim(),
      asset: asset,
      snapshotAmount: snapshotAmount,
      entryDate: DateTime.now(),
    );
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success<SubaccountEntity>(value: final subaccount):
        emit(state.copyWith(status: SubaccountCreateStatus.success, subaccount: subaccount));
      case FailureResult<SubaccountEntity>(failure: final failure):
        emit(
          state.copyWith(
            status: SubaccountCreateStatus.error,
            nameError: null,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }

  void clearNameError() {
    if (state.nameError == null) {
      return;
    }
    emit(state.copyWith(nameError: null));
  }

  void reset() {
    emit(const SubaccountCreateState());
  }
}
