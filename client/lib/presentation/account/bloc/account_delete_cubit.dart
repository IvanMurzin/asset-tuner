import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';

part 'account_delete_cubit.freezed.dart';
part 'account_delete_state.dart';

@injectable
class AccountDeleteCubit extends Cubit<AccountDeleteState> {
  AccountDeleteCubit(this._getCachedSession, this._deleteAccount)
    : super(const AccountDeleteState());

  final GetCachedSessionUseCase _getCachedSession;
  final DeleteAccountUseCase _deleteAccount;

  Future<void> submit(String accountId) async {
    emit(
      state.copyWith(status: AccountDeleteStatus.loading, failureCode: null, failureMessage: null),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(state.copyWith(status: AccountDeleteStatus.error, failureCode: 'unauthorized'));
      return;
    }

    final result = await _deleteAccount(accountId: accountId);
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success<void>():
        emit(state.copyWith(status: AccountDeleteStatus.success, deletedAccountId: accountId));
      case FailureResult<void>(failure: final failure):
        emit(
          state.copyWith(
            status: AccountDeleteStatus.error,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }

  void reset() {
    emit(const AccountDeleteState());
  }
}
