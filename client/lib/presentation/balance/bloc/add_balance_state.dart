part of 'add_balance_cubit.dart';

enum AddBalanceStatus { loading, ready, error }

enum AddBalanceDestination { signIn, backSaved }

@freezed
abstract class AddBalanceNavigation with _$AddBalanceNavigation {
  const factory AddBalanceNavigation({required AddBalanceDestination destination}) =
      _AddBalanceNavigation;
}

@freezed
abstract class AddBalanceState with _$AddBalanceState {
  const factory AddBalanceState({
    @Default(AddBalanceStatus.loading) AddBalanceStatus status,
    String? subaccountId,
    DateTime? entryDate,
    @Default('') String amountText,
    String? amountError,
    String? dateError,
    String? failureCode,
    String? failureMessage,
    @Default(false) bool isSaving,
    AddBalanceNavigation? navigation,
  }) = _AddBalanceState;
}
