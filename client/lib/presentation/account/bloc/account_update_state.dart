part of 'account_update_cubit.dart';

enum AccountUpdateStatus { idle, loading, success, error }

enum AccountUpdateFieldError { required }

@freezed
abstract class AccountUpdateState with _$AccountUpdateState {
  const factory AccountUpdateState({
    @Default(AccountUpdateStatus.idle) AccountUpdateStatus status,
    AccountEntity? account,
    AccountUpdateFieldError? nameError,
    String? failureCode,
    String? failureMessage,
  }) = _AccountUpdateState;
}
