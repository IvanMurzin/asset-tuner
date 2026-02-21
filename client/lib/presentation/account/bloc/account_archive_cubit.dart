import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/usecase/set_account_archived_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';

part 'account_archive_cubit.freezed.dart';
part 'account_archive_state.dart';

class AccountArchiveCubit extends Cubit<AccountArchiveState> {
  AccountArchiveCubit(this._getCachedSession, this._setArchived)
    : super(const AccountArchiveState());

  final GetCachedSessionUseCase _getCachedSession;
  final SetAccountArchivedUseCase _setArchived;

  Future<void> submit({required String accountId, required bool archived}) async {
    emit(
      state.copyWith(status: AccountArchiveStatus.loading, failureCode: null, failureMessage: null),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(state.copyWith(status: AccountArchiveStatus.error, failureCode: 'unauthorized'));
      return;
    }

    final result = await _setArchived(accountId: accountId, archived: archived);
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success<AccountEntity>(value: final account):
        emit(state.copyWith(status: AccountArchiveStatus.success, account: account));
      case FailureResult<AccountEntity>(failure: final failure):
        emit(
          state.copyWith(
            status: AccountArchiveStatus.error,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }

  void reset() {
    emit(const AccountArchiveState());
  }
}
