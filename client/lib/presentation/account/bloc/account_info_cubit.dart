import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/domain/subaccount/usecase/get_subaccounts_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';

part 'account_info_cubit.freezed.dart';
part 'account_info_state.dart';

@injectable
class AccountInfoCubit extends Cubit<AccountInfoState> {
  AccountInfoCubit(this._getCachedSession, this._getSubaccounts) : super(const AccountInfoState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetSubaccountsUseCase _getSubaccounts;

  bool _isFetching = false;
  bool _queuedFetch = false;
  bool _queuedSilent = true;

  Future<void> load({required String accountId, required AccountEntity? account}) async {
    if (account == null) {
      emit(
        state.copyWith(
          status: AccountInfoStatus.error,
          account: null,
          failureCode: 'not_found',
          failureMessage: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AccountInfoStatus.ready,
        account: account,
        isSubaccountsLoading: true,
        failureCode: null,
        failureMessage: null,
        navigation: null,
      ),
    );
    await _fetchSubaccounts(accountId: accountId, silent: false);
  }

  void setAccount(AccountEntity? account) {
    if (account == null) {
      emit(
        state.copyWith(
          status: AccountInfoStatus.error,
          account: null,
          failureCode: 'not_found',
          failureMessage: null,
        ),
      );
      return;
    }

    emit(state.copyWith(status: AccountInfoStatus.ready, account: account));
  }

  Future<void> refreshSubaccounts({bool silent = true}) async {
    final accountId = state.account?.id;
    if (accountId == null) {
      return;
    }
    await _fetchSubaccounts(accountId: accountId, silent: silent);
  }

  Future<void> applyUpdatedSubaccount(SubaccountEntity updated) async {
    updateSubaccount(updated);
    await refreshSubaccounts(silent: true);
  }

  Future<void> applyUpdatedSubaccountBalance({
    required String subaccountId,
    required Decimal amountAtomic,
    required int amountDecimals,
  }) async {
    updateSubaccountBalance(
      subaccountId: subaccountId,
      amountAtomic: amountAtomic,
      amountDecimals: amountDecimals,
    );
    await refreshSubaccounts(silent: true);
  }

  Future<void> applyDeletedSubaccount(String subaccountId) async {
    deleteSubaccount(subaccountId);
    await refreshSubaccounts(silent: true);
  }

  Future<void> applyCreatedSubaccount(SubaccountEntity created) async {
    createSubaccount(created);
    await refreshSubaccounts(silent: true);
  }

  Future<void> _fetchSubaccounts({required String accountId, required bool silent}) async {
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
            status: AccountInfoStatus.error,
            failureCode: 'unauthorized',
            failureMessage: null,
            navigation: const AccountInfoNavigation(AccountInfoDestination.signIn),
          ),
        );
        return;
      }

      if (!silent) {
        emit(state.copyWith(isSubaccountsLoading: true, failureCode: null, failureMessage: null));
      }

      final result = await _getSubaccounts(accountId: accountId);
      if (isClosed) {
        return;
      }

      switch (result) {
        case Success<List<SubaccountEntity>>(value: final list):
          emit(
            state.copyWith(
              status: AccountInfoStatus.ready,
              subaccounts: _sort(list),
              isSubaccountsLoading: false,
              failureCode: null,
              failureMessage: null,
            ),
          );
        case FailureResult<List<SubaccountEntity>>(failure: final failure):
          if (!silent) {
            emit(
              state.copyWith(
                isSubaccountsLoading: false,
                failureCode: failure.code,
                failureMessage: failure.message,
              ),
            );
          }
      }
    } finally {
      _isFetching = false;
      if (_queuedFetch) {
        final nextSilent = _queuedSilent;
        _queuedFetch = false;
        _queuedSilent = true;
        unawaited(_fetchSubaccounts(accountId: accountId, silent: nextSilent));
      }
    }
  }

  void updateSubaccount(SubaccountEntity updated) {
    emit(
      state.copyWith(
        subaccounts: _sort([
          for (final item in state.subaccounts)
            if (item.id == updated.id) updated else item,
        ]),
      ),
    );
  }

  void updateSubaccountBalance({
    required String subaccountId,
    required Decimal amountAtomic,
    required int amountDecimals,
  }) {
    emit(
      state.copyWith(
        subaccounts: _sort([
          for (final item in state.subaccounts)
            if (item.id == subaccountId)
              item.copyWith(
                currentAmountAtomic: amountAtomic,
                currentAmountDecimals: amountDecimals,
              )
            else
              item,
        ]),
      ),
    );
  }

  void deleteSubaccount(String subaccountId) {
    emit(
      state.copyWith(
        subaccounts: state.subaccounts.where((item) => item.id != subaccountId).toList(),
      ),
    );
  }

  void createSubaccount(SubaccountEntity created) {
    emit(state.copyWith(subaccounts: _sort([...state.subaccounts, created])));
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  List<SubaccountEntity> _sort(List<SubaccountEntity> items) {
    return [...items]..sort((a, b) => a.name.compareTo(b.name));
  }
}
