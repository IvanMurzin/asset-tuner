import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/usecase/delete_account_usecase.dart';
import 'package:asset_tuner/domain/account/usecase/get_accounts_usecase.dart';
import 'package:asset_tuner/domain/account/usecase/set_account_archived_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';

part 'accounts_cubit.freezed.dart';
part 'accounts_state.dart';

@injectable
class AccountsCubit extends Cubit<AccountsState> {
  AccountsCubit(
    this._getCachedSession,
    this._getAccounts,
    this._setArchived,
    this._deleteAccount,
  ) : super(const AccountsState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetAccountsUseCase _getAccounts;
  final SetAccountArchivedUseCase _setArchived;
  final DeleteAccountUseCase _deleteAccount;

  Future<void> load() async {
    emit(
      state.copyWith(
        status: AccountsStatus.loading,
        failureCode: null,
        actionFailureCode: null,
        actionFailureAccountId: null,
      ),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(
        state.copyWith(
          status: AccountsStatus.error,
          failureCode: 'unauthorized',
          navigation: const AccountsNavigation(
            destination: AccountsDestination.signIn,
          ),
        ),
      );
      return;
    }

    final result = await _getAccounts();
    switch (result) {
      case Success<List<AccountEntity>>(value: final accounts):
        emit(
          state.copyWith(
            status: AccountsStatus.ready,
            activeAccounts: accounts.where((a) => !a.archived).toList(),
            archivedAccounts: accounts.where((a) => a.archived).toList(),
          ),
        );
      case FailureResult<List<AccountEntity>>(failure: final failure):
        emit(
          state.copyWith(
            status: AccountsStatus.error,
            failureCode: failure.code,
          ),
        );
    }
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  Future<void> setArchived({
    required String accountId,
    required bool archived,
  }) async {
    if (state.status != AccountsStatus.ready) {
      return;
    }

    emit(
      state.copyWith(
        busyAccountIds: {...state.busyAccountIds, accountId},
        actionFailureCode: null,
        actionFailureAccountId: null,
      ),
    );

    final result = await _setArchived(accountId: accountId, archived: archived);
    switch (result) {
      case Success<AccountEntity>(value: final updated):
        emit(
          state.copyWith(
            busyAccountIds: {...state.busyAccountIds}..remove(accountId),
            activeAccounts: _replaceOrRemove(
              state.activeAccounts,
              updated,
              include: !updated.archived,
            ),
            archivedAccounts: _replaceOrRemove(
              state.archivedAccounts,
              updated,
              include: updated.archived,
            ),
          ),
        );
      case FailureResult<AccountEntity>(failure: final failure):
        emit(
          state.copyWith(
            busyAccountIds: {...state.busyAccountIds}..remove(accountId),
            actionFailureCode: failure.code,
            actionFailureAccountId: accountId,
          ),
        );
    }
  }

  Future<void> deleteAccount(String accountId) async {
    if (state.status != AccountsStatus.ready) {
      return;
    }

    emit(
      state.copyWith(
        busyAccountIds: {...state.busyAccountIds, accountId},
        actionFailureCode: null,
        actionFailureAccountId: null,
      ),
    );

    final result = await _deleteAccount(accountId: accountId);
    switch (result) {
      case Success<void>():
        emit(
          state.copyWith(
            busyAccountIds: {...state.busyAccountIds}..remove(accountId),
            activeAccounts: state.activeAccounts
                .where((a) => a.id != accountId)
                .toList(),
            archivedAccounts: state.archivedAccounts
                .where((a) => a.id != accountId)
                .toList(),
          ),
        );
      case FailureResult<void>(failure: final failure):
        emit(
          state.copyWith(
            busyAccountIds: {...state.busyAccountIds}..remove(accountId),
            actionFailureCode: failure.code,
            actionFailureAccountId: accountId,
          ),
        );
    }
  }

  List<AccountEntity> _replaceOrRemove(
    List<AccountEntity> current,
    AccountEntity updated, {
    required bool include,
  }) {
    final next = current.where((a) => a.id != updated.id).toList();
    if (!include) {
      return next;
    }
    return [...next, updated]..sort((a, b) => a.name.compareTo(b.name));
  }
}
