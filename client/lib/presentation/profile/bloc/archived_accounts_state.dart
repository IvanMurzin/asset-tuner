part of 'archived_accounts_cubit.dart';

enum ArchivedAccountsStatus { loading, ready, error }

class ArchivedAccountsState {
  const ArchivedAccountsState({
    this.status = ArchivedAccountsStatus.loading,
    this.accounts = const [],
    this.failureCode,
    this.failureMessage,
  });

  final ArchivedAccountsStatus status;
  final List<AccountEntity> accounts;
  final String? failureCode;
  final String? failureMessage;

  ArchivedAccountsState copyWith({
    ArchivedAccountsStatus? status,
    List<AccountEntity>? accounts,
    String? failureCode,
    String? failureMessage,
    bool clearFailure = false,
  }) {
    return ArchivedAccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      failureCode: clearFailure ? null : (failureCode ?? this.failureCode),
      failureMessage: clearFailure ? null : (failureMessage ?? this.failureMessage),
    );
  }
}
