import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/balance/usecase/update_balance_usecase.dart';

part 'add_balance_cubit.freezed.dart';
part 'add_balance_state.dart';

@injectable
class AddBalanceCubit extends Cubit<AddBalanceState> {
  AddBalanceCubit(this._getCachedSession, this._updateBalance)
    : super(const AddBalanceState());

  final GetCachedSessionUseCase _getCachedSession;
  final UpdateBalanceUseCase _updateBalance;

  Future<void> load({
    required String subaccountId,
    DateTime? initialDate,
  }) async {
    emit(
      state.copyWith(
        status: AddBalanceStatus.loading,
        failureCode: null,
        amountError: null,
        dateError: null,
        isSaving: false,
        navigation: null,
      ),
    );

    final session = await _getCachedSession();
    if (isClosed) return;
    if (session == null) {
      emit(
        state.copyWith(
          status: AddBalanceStatus.error,
          failureCode: 'unauthorized',
          navigation: const AddBalanceNavigation(
            destination: AddBalanceDestination.signIn,
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AddBalanceStatus.ready,
        subaccountId: subaccountId,
        entryDate: initialDate ?? DateTime.now(),
      ),
    );
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(entryDate: date, dateError: null));
  }

  void updateAmount(String amount) {
    emit(state.copyWith(amountText: amount, amountError: null));
  }

  Future<void> save() async {
    final subaccountId = state.subaccountId;
    final date = state.entryDate;
    if (state.status != AddBalanceStatus.ready ||
        subaccountId == null ||
        date == null) {
      return;
    }

    final normalizedText = state.amountText.trim();
    if (normalizedText.isEmpty) {
      emit(state.copyWith(amountError: 'required'));
      return;
    }

    final parsed = _parseDecimal(normalizedText);
    if (parsed == null) {
      emit(state.copyWith(amountError: 'invalid'));
      return;
    }

    emit(state.copyWith(isSaving: true, failureCode: null));
    final result = await _updateBalance(
      subaccountId: subaccountId,
      entryDate: date,
      snapshotAmount: parsed,
    );
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(
          state.copyWith(
            isSaving: false,
            navigation: const AddBalanceNavigation(
              destination: AddBalanceDestination.backSaved,
            ),
          ),
        );
      case FailureResult(failure: final failure):
        emit(state.copyWith(isSaving: false, failureCode: failure.code, failureMessage: failure.message));
    }
  }

  Decimal? _parseDecimal(String input) {
    final trimmed = input.trim();
    final withoutPlus = trimmed.startsWith('+')
        ? trimmed.substring(1)
        : trimmed;
    final normalized = withoutPlus.replaceAll(',', '.');
    try {
      return Decimal.parse(normalized);
    } catch (_) {
      return null;
    }
  }
}
