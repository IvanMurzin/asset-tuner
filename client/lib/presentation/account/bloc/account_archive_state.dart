part of 'account_archive_cubit.dart';

enum AccountArchiveStatus { idle, loading, success, error }

@freezed
abstract class AccountArchiveState with _$AccountArchiveState {
  const factory AccountArchiveState({
    @Default(AccountArchiveStatus.idle) AccountArchiveStatus status,
    AccountEntity? account,
    String? failureCode,
    String? failureMessage,
  }) = _AccountArchiveState;
}
