part of 'subaccount_balance_cubit.dart';

enum SubaccountBalanceStatus { idle, loading, success, error }

@freezed
abstract class SubaccountBalanceState with _$SubaccountBalanceState {
  const factory SubaccountBalanceState({
    @Default(SubaccountBalanceStatus.idle) SubaccountBalanceStatus status,
    BalanceEntryEntity? entry,
    String? failureCode,
    String? failureMessage,
  }) = _SubaccountBalanceState;
}
