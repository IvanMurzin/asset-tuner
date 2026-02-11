part of 'accounts_cubit.dart';

enum AccountsStatus { loading, ready, error }

enum AccountsDestination { signIn }

@freezed
abstract class AccountsNavigation with _$AccountsNavigation {
  const factory AccountsNavigation({required AccountsDestination destination}) =
      _AccountsNavigation;
}

@freezed
abstract class AccountsState with _$AccountsState {
  const factory AccountsState({
    @Default(AccountsStatus.loading) AccountsStatus status,
    @Default([]) List<AccountEntity> activeAccounts,
    @Default([]) List<AccountEntity> archivedAccounts,
    @Default(<String>{}) Set<String> busyAccountIds,
    String? failureCode,
    String? actionFailureCode,
    String? actionFailureAccountId,
    AccountsNavigation? navigation,
  }) = _AccountsState;
}
