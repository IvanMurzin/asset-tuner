part of 'account_detail_cubit.dart';

enum AccountDetailStatus { loading, ready, error }

enum AccountDetailDestination { signIn, backDeleted }

@freezed
abstract class AccountDetailNavigation with _$AccountDetailNavigation {
  const factory AccountDetailNavigation({required AccountDetailDestination destination}) =
      _AccountDetailNavigation;
}

@freezed
abstract class AccountDetailState with _$AccountDetailState {
  const factory AccountDetailState({
    @Default(AccountDetailStatus.loading) AccountDetailStatus status,
    AccountEntity? account,
    String? baseCurrency,
    DateTime? ratesAsOf,
    Decimal? total,
    Decimal? pricedTotal,
    @Default(false) bool hasUnpricedHoldings,
    @Default([]) List<AccountAssetViewItem> items,
    @Default(<String>{}) Set<String> busyAssetIds,
    @Default(false) bool isAccountActionBusy,
    @Default(false) bool isAccountArchived,
    String? failureCode,
    String? failureMessage,
    String? bannerFailureCode,
    String? bannerFailureMessage,
    AccountDetailNavigation? navigation,
  }) = _AccountDetailState;
}
