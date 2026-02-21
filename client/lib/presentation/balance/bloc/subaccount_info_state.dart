part of 'subaccount_info_cubit.dart';

enum SubaccountInfoStatus { loading, ready, error }

enum SubaccountInfoDestination { signIn, backDeleted }

@freezed
abstract class SubaccountInfoNavigation with _$SubaccountInfoNavigation {
  const factory SubaccountInfoNavigation(SubaccountInfoDestination destination) =
      _SubaccountInfoNavigation;
}

@freezed
abstract class SubaccountInfoState with _$SubaccountInfoState {
  const factory SubaccountInfoState({
    @Default(SubaccountInfoStatus.loading) SubaccountInfoStatus status,
    AccountEntity? account,
    SubaccountEntity? subaccount,
    @Default(<BalanceEntryEntity>[]) List<BalanceEntryEntity> entries,
    String? nextCursor,
    @Default(false) bool isHistoryLoading,
    @Default(false) bool isLoadingMore,
    String? failureCode,
    String? failureMessage,
    SubaccountInfoNavigation? navigation,
  }) = _SubaccountInfoState;
}
