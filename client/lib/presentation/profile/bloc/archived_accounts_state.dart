part of 'archived_accounts_cubit.dart';

enum ArchivedAccountsStatus { loading, ready, error }

class ArchivedAccountsState {
  const ArchivedAccountsState({
    this.status = ArchivedAccountsStatus.loading,
    this.accounts = const [],
    this.failureCode,
  });

  final ArchivedAccountsStatus status;
  final List<AccountEntity> accounts;
  final String? failureCode;

  ArchivedAccountsState copyWith({
    ArchivedAccountsStatus? status,
    List<AccountEntity>? accounts,
    String? failureCode,
  }) {
    return ArchivedAccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      failureCode: failureCode,
    );
  }
}
