part of 'account_delete_cubit.dart';

enum AccountDeleteStatus { idle, loading, success, error }

@freezed
abstract class AccountDeleteState with _$AccountDeleteState {
  const factory AccountDeleteState({
    @Default(AccountDeleteStatus.idle) AccountDeleteStatus status,
    String? deletedAccountId,
    String? failureCode,
    String? failureMessage,
  }) = _AccountDeleteState;
}
