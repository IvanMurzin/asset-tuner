import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/analytics/app_analytics.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/usecase/update_balance_usecase.dart';

part 'subaccount_balance_cubit.freezed.dart';
part 'subaccount_balance_state.dart';

@injectable
class SubaccountBalanceCubit extends Cubit<SubaccountBalanceState> {
  SubaccountBalanceCubit(this._getCachedSession, this._updateBalance, this._analytics)
    : super(const SubaccountBalanceState());

  final GetCachedSessionUseCase _getCachedSession;
  final UpdateBalanceUseCase _updateBalance;
  final AppAnalytics _analytics;

  Future<void> submit({
    required String subaccountId,
    required DateTime entryDate,
    required Decimal snapshotAmount,
  }) async {
    emit(
      state.copyWith(
        status: SubaccountBalanceStatus.loading,
        failureCode: null,
        failureMessage: null,
      ),
    );

    final session = await _getCachedSession();
    if (session == null) {
      emit(state.copyWith(status: SubaccountBalanceStatus.error, failureCode: 'unauthorized'));
      return;
    }

    final result = await _updateBalance(
      subaccountId: subaccountId,
      entryDate: entryDate,
      snapshotAmount: snapshotAmount,
    );
    if (isClosed) {
      return;
    }

    switch (result) {
      case Success<BalanceEntryEntity>(value: final entry):
        _analytics.log(AnalyticsEventName.balanceUpdated);
        emit(state.copyWith(status: SubaccountBalanceStatus.success, entry: entry));
      case FailureResult<BalanceEntryEntity>(failure: final failure):
        emit(
          state.copyWith(
            status: SubaccountBalanceStatus.error,
            failureCode: failure.code,
            failureMessage: failure.message,
          ),
        );
    }
  }

  void reset() {
    emit(const SubaccountBalanceState());
  }
}
