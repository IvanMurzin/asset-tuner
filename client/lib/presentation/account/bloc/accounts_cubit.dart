import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/account/usecase/get_accounts_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';

part 'accounts_cubit.freezed.dart';
part 'accounts_state.dart';

@injectable
class AccountsCubit extends Cubit<AccountsState> {
  AccountsCubit(this._getCachedSession, this._getAccounts) : super(const AccountsState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetAccountsUseCase _getAccounts;

  bool _isFetching = false;
  bool _queuedFetch = false;
  bool _queuedSilent = true;

  Future<void> load() async {
    emit(state.copyWith(status: AccountsStatus.loading, failureCode: null, failureMessage: null));
    await _fetch(silent: false);
  }

  Future<void> refresh({bool silent = false}) async {
    await _fetch(silent: silent);
  }

  Future<void> create(AccountEntity account) async {
    applyCreated(account);
    await refresh(silent: true);
  }

  Future<void> update(AccountEntity account) async {
    applyUpdated(account);
    await refresh(silent: true);
  }

  Future<void> archive(AccountEntity account) async {
    applyArchived(account);
    await refresh(silent: true);
  }

  Future<void> delete(String accountId) async {
    applyDeleted(accountId);
    await refresh(silent: true);
  }

  Future<void> _fetch({required bool silent}) async {
    if (_isFetching) {
      _queuedFetch = true;
      _queuedSilent = _queuedSilent && silent;
      return;
    }

    _isFetching = true;
    try {
      final session = await _getCachedSession();
      if (isClosed) {
        return;
      }
      if (session == null) {
        emit(
          state.copyWith(
            status: AccountsStatus.error,
            accounts: const <AccountEntity>[],
            failureCode: 'unauthorized',
            failureMessage: null,
          ),
        );
        return;
      }

      final result = await _getAccounts();
      if (isClosed) {
        return;
      }

      switch (result) {
        case Success<List<AccountEntity>>(value: final accounts):
          emit(
            state.copyWith(
              status: AccountsStatus.ready,
              accounts: _sort(accounts),
              failureCode: null,
              failureMessage: null,
            ),
          );
        case FailureResult<List<AccountEntity>>(failure: final failure):
          if (!silent || state.status != AccountsStatus.ready) {
            emit(
              state.copyWith(
                status: AccountsStatus.error,
                failureCode: failure.code,
                failureMessage: failure.message,
              ),
            );
          } else {
            emit(state.copyWith(failureCode: failure.code, failureMessage: failure.message));
          }
      }
    } finally {
      _isFetching = false;
      if (_queuedFetch) {
        final nextSilent = _queuedSilent;
        _queuedFetch = false;
        _queuedSilent = true;
        unawaited(_fetch(silent: nextSilent));
      }
    }
  }

  void applyCreated(AccountEntity account) {
    emit(
      state.copyWith(
        status: AccountsStatus.ready,
        accounts: _sort([...state.accounts, account]),
        failureCode: null,
        failureMessage: null,
      ),
    );
  }

  void applyUpdated(AccountEntity account) {
    final next = [
      for (final item in state.accounts)
        if (item.id == account.id) account else item,
    ];
    emit(
      state.copyWith(
        status: AccountsStatus.ready,
        accounts: _sort(next),
        failureCode: null,
        failureMessage: null,
      ),
    );
  }

  void applyArchived(AccountEntity account) {
    applyUpdated(account);
  }

  void applyDeleted(String accountId) {
    emit(
      state.copyWith(
        status: AccountsStatus.ready,
        accounts: _sort(state.accounts.where((item) => item.id != accountId).toList()),
        failureCode: null,
        failureMessage: null,
      ),
    );
  }

  AccountEntity? findById(String id) {
    for (final account in state.accounts) {
      if (account.id == id) {
        return account;
      }
    }
    return null;
  }

  List<AccountEntity> _sort(List<AccountEntity> accounts) {
    return [...accounts]..sort((a, b) => a.name.compareTo(b.name));
  }
}
