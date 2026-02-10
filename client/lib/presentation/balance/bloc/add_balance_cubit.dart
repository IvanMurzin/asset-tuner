import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:asset_tuner/core/types/result.dart';
import 'package:asset_tuner/domain/account_asset/entity/account_asset_entity.dart';
import 'package:asset_tuner/domain/account_asset/usecase/get_account_assets_usecase.dart';
import 'package:asset_tuner/domain/auth/usecase/get_cached_session_usecase.dart';
import 'package:asset_tuner/domain/balance/entity/balance_entry_entity.dart';
import 'package:asset_tuner/domain/balance/usecase/update_balance_usecase.dart';

part 'add_balance_cubit.freezed.dart';
part 'add_balance_state.dart';

@injectable
class AddBalanceCubit extends Cubit<AddBalanceState> {
  AddBalanceCubit(
    this._getCachedSession,
    this._getAccountAssets,
    this._updateBalance,
  ) : super(const AddBalanceState());

  final GetCachedSessionUseCase _getCachedSession;
  final GetAccountAssetsUseCase _getAccountAssets;
  final UpdateBalanceUseCase _updateBalance;

  Future<void> load({
    required String accountId,
    required String assetId,
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

    final positions = await _getAccountAssets(
      userId: session.userId,
      accountId: accountId,
    );
    final position = switch (positions) {
      Success<List<AccountAssetEntity>>(value: final list) =>
        list.where((p) => p.assetId == assetId).firstOrNull,
      FailureResult<List<AccountAssetEntity>>() => null,
    };
    if (position == null) {
      emit(
        state.copyWith(
          status: AddBalanceStatus.error,
          failureCode: 'not_found',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AddBalanceStatus.ready,
        userId: session.userId,
        accountAssetId: position.id,
        entryType: BalanceEntryType.snapshot,
        entryDate: initialDate ?? DateTime.now(),
      ),
    );
  }

  void consumeNavigation() {
    emit(state.copyWith(navigation: null));
  }

  void selectType(BalanceEntryType type) {
    emit(state.copyWith(entryType: type));
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(entryDate: date, dateError: null));
  }

  void updateAmount(String amount) {
    emit(state.copyWith(amountText: amount, amountError: null));
  }

  Future<void> save() async {
    final userId = state.userId;
    final accountAssetId = state.accountAssetId;
    final date = state.entryDate;
    final type = state.entryType;
    if (userId == null ||
        accountAssetId == null ||
        date == null ||
        type == null) {
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
      userId: userId,
      accountAssetId: accountAssetId,
      entryDate: date,
      snapshotAmount: type == BalanceEntryType.snapshot ? parsed : null,
      deltaAmount: type == BalanceEntryType.delta ? parsed : null,
    );

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
        if (failure.code == 'validation') {
          emit(
            state.copyWith(
              isSaving: false,
              amountError: failure.message == 'amount' ? 'invalid' : null,
              dateError: failure.message == 'date' ? 'invalid' : null,
              failureCode: failure.code,
            ),
          );
          return;
        }
        emit(state.copyWith(isSaving: false, failureCode: failure.code));
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

extension<T> on Iterable<T> {
  T? get firstOrNull {
    for (final item in this) {
      return item;
    }
    return null;
  }
}
