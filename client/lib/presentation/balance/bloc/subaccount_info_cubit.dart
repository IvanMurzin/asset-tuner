import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:decimal/decimal.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/subaccount/entity/subaccount_entity.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/entity/balance_history_page_entity.dart';
import 'package:asset_tuner/domain/balance/usecase/get_balance_history_usecase.dart';

part 'subaccount_info_cubit.freezed.dart';
part 'subaccount_info_state.dart';

@injectable
class SubaccountInfoCubit extends Cubit<SubaccountInfoState> {
  SubaccountInfoCubit(this._getCachedSession, this._getHistory)
    : super(const SubaccountInfoState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetBalanceHistoryUseCase _getHistory;

  Future<void> load({required AccountEntity account, required SubaccountEntity subaccount}) async {
    emit(
      state.copyWith(
        status: SubaccountInfoStatus.ready,
        account: account,
        subaccount: subaccount,
        isHistoryLoading: true,
        failureCode: null,
        failureMessage: null,
        navigation: null,
      ),
    );
    await refreshHistory(showLoading: true);
  }

  Future<void> refreshHistory({bool showLoading = true}) async {
    final subaccountId = state.subaccount?.id;
    if (subaccountId == null) {
      emit(
        state.copyWith(
          status: SubaccountInfoStatus.error,
          failureCode: 'not_found',
          failureMessage: null,
        ),
      );
      return;
    }

    final session = await _getCachedSession();
    if (isClosed) {
      return;
    }
    if (session == null) {
      emit(
        state.copyWith(
          status: SubaccountInfoStatus.error,
          failureCode: 'unauthorized',
          failureMessage: null,
          navigation: const SubaccountInfoNavigation(SubaccountInfoDestination.signIn),
        ),
      );
      return;
    }

    if (showLoading) {
      emit(state.copyWith(isHistoryLoading: true, failureCode: null, failureMessage: null));
    }

    final result = await _getHistory(subaccountId: subaccountId, limit: 50);
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success<BalanceHistoryPageEntity>(value: final page):
        emit(
          state.copyWith(
            status: SubaccountInfoStatus.ready,
            entries: _filterZeroDeltaEntries(page.entries),
            nextCursor: page.nextCursor,
            isHistoryLoading: false,
            failureCode: null,
            failureMessage: null,
          ),
        );
      case FailureResult<BalanceHistoryPageEntity>(failure: final failure):
        emit(
          state.copyWith(
            status: SubaccountInfoStatus.error,
            isHistoryLoading: false,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }

  Future<void> loadMore() async {
    final subaccountId = state.subaccount?.id;
    final cursor = state.nextCursor;
    if (subaccountId == null || cursor == null || state.isLoadingMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, failureCode: null, failureMessage: null));

    final result = await _getHistory(subaccountId: subaccountId, limit: 50, cursor: cursor);
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success<BalanceHistoryPageEntity>(value: final page):
        emit(
          state.copyWith(
            isLoadingMore: false,
            entries: [...state.entries, ..._filterZeroDeltaEntries(page.entries)],
            nextCursor: page.nextCursor,
          ),
        );
      case FailureResult<BalanceHistoryPageEntity>(failure: final failure):
        emit(
          state.copyWith(
            isLoadingMore: false,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }

  void updateSubaccount(SubaccountEntity subaccount) {
    emit(state.copyWith(subaccount: subaccount));
  }

  void onDeleted() {
    emit(
      state.copyWith(
        navigation: const SubaccountInfoNavigation(SubaccountInfoDestination.backDeleted),
      ),
    );
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  List<BalanceEntryEntity> _filterZeroDeltaEntries(List<BalanceEntryEntity> entries) {
    return entries
        .where((entry) {
          final diff = entry.diffAmount;
          if (diff == null) {
            return true;
          }
          return diff.compareTo(Decimal.zero) != 0;
        })
        .toList(growable: false);
  }
}
