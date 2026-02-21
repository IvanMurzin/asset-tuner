part of 'account_info_cubit.dart';

enum AccountInfoStatus { loading, ready, error }

enum AccountInfoDestination { signIn, back }

@freezed
abstract class AccountInfoNavigation with _$AccountInfoNavigation {
  const factory AccountInfoNavigation(AccountInfoDestination destination) =
      _AccountInfoNavigation;
}

@freezed
abstract class AccountInfoState with _$AccountInfoState {
  const factory AccountInfoState({
    @Default(AccountInfoStatus.loading) AccountInfoStatus status,
    AccountEntity? account,
    @Default(<AccountAssetEntity>[]) List<AccountAssetEntity> subaccounts,
    @Default(false) bool isSubaccountsLoading,
    String? failureCode,
    String? failureMessage,
    AccountInfoNavigation? navigation,
  }) = _AccountInfoState;
}
