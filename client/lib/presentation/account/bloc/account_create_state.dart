part of 'account_create_cubit.dart';

enum AccountCreateStatus { idle, loading, success, error }

@freezed
abstract class AccountCreateState with _$AccountCreateState {
  const factory AccountCreateState({
    @Default(AccountCreateStatus.idle) AccountCreateStatus status,
    AccountEntity? account,
    String? failureCode,
    String? failureMessage,
  }) = _AccountCreateState;
}
