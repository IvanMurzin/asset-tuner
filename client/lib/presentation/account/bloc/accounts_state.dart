part of 'accounts_cubit.dart';

enum AccountsStatus { initial, loading, ready, error }

@freezed
abstract class AccountsState with _$AccountsState {
  const factory AccountsState({
    @Default(AccountsStatus.initial) AccountsStatus status,
    @Default(<AccountEntity>[]) List<AccountEntity> accounts,
    String? failureCode,
    String? failureMessage,
  }) = _AccountsState;
}
