import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/usecase/create_account_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';

part 'account_create_cubit.freezed.dart';
part 'account_create_state.dart';

@injectable
class AccountCreateCubit extends Cubit<AccountCreateState> {
  AccountCreateCubit(this._getCachedSession, this._createAccount)
    : super(const AccountCreateState());

  final GetCachedSessionUseCase _getCachedSession;
  final CreateAccountUseCase _createAccount;

  Future<void> submit({required String name, required AccountType type}) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      emit(
        state.copyWith(
          status: AccountCreateStatus.error,
          nameError: AccountCreateFieldError.required,
          failureCode: 'validation',
          failureMessage: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AccountCreateStatus.loading,
        nameError: null,
        failureCode: null,
        failureMessage: null,
      ),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(state.copyWith(status: AccountCreateStatus.error, failureCode: 'unauthorized'));
      return;
    }

    final result = await _createAccount(name: normalized, type: type);
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success<AccountEntity>(value: final account):
        emit(state.copyWith(status: AccountCreateStatus.success, account: account));
      case FailureResult<AccountEntity>(failure: final failure):
        emit(
          state.copyWith(
            status: AccountCreateStatus.error,
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
    emit(const AccountCreateState());
  }
}
