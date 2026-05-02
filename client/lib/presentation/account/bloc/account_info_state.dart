part of 'account_info_cubit.dart';

enum AccountInfoStatus { loading, ready, error }

@freezed
abstract class AccountInfoState with _$AccountInfoState {
  const factory AccountInfoState({
    @Default(AccountInfoStatus.loading) AccountInfoStatus status,
    AccountEntity? account,
    @Default(<SubaccountEntity>[]) List<SubaccountEntity> subaccounts,
    @Default(false) bool isSubaccountsLoading,
    String? failureCode,
    String? failureMessage,
  }) = _AccountInfoState;
}
