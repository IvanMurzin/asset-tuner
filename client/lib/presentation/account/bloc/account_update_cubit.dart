import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/usecase/update_account_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';

part 'account_update_cubit.freezed.dart';
part 'account_update_state.dart';

@injectable
class AccountUpdateCubit extends Cubit<AccountUpdateState> {
  AccountUpdateCubit(this._getCachedSession, this._updateAccount)
    : super(const AccountUpdateState());

  final GetCachedSessionUseCase _getCachedSession;
  final UpdateAccountUseCase _updateAccount;

  Future<void> submit({
    required String accountId,
    required String name,
    required AccountType type,
  }) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      emit(
        state.copyWith(
          status: AccountUpdateStatus.error,
          nameError: AccountUpdateFieldError.required,
          failureCode: 'validation',
          failureMessage: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AccountUpdateStatus.loading,
        nameError: null,
        failureCode: null,
        failureMessage: null,
      ),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(state.copyWith(status: AccountUpdateStatus.error, failureCode: 'unauthorized'));
      return;
    }

    final result = await _updateAccount(accountId: accountId, name: normalized, type: type);
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success<AccountEntity>(value: final account):
        emit(state.copyWith(status: AccountUpdateStatus.success, account: account));
      case FailureResult<AccountEntity>(failure: final failure):
        emit(
          state.copyWith(
            status: AccountUpdateStatus.error,
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
    emit(const AccountUpdateState());
  }
}
