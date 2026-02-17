part of 'overview_cubit.dart';

enum OverviewStatus { loading, ready, emptyNoAccounts, emptyNoAssets, emptyNoBalances, error }

@freezed
abstract class OverviewNavigation with _$OverviewNavigation {
  const factory OverviewNavigation({required OverviewDestination destination}) =
      _OverviewNavigation;
}

@freezed
abstract class OverviewAccountItem with _$OverviewAccountItem {
  const factory OverviewAccountItem({
    required String accountId,
    required String accountName,
    required AccountType accountType,
    required Decimal total,
    required int subaccountsCount,
    required bool hasUnpricedHoldings,
  }) = _OverviewAccountItem;
}

@freezed
abstract class OverviewUnpricedHolding with _$OverviewUnpricedHolding {
  const factory OverviewUnpricedHolding({required String assetCode, required Decimal amount}) =
      _OverviewUnpricedHolding;
}

@freezed
abstract class OverviewState with _$OverviewState {
  const factory OverviewState({
    @Default(OverviewStatus.loading) OverviewStatus status,
    String? baseCurrency,
    DateTime? ratesAsOf,
    Decimal? fullTotal,
    Decimal? pricedTotal,
    @Default(false) bool hasUnpricedHoldings,
    @Default([]) List<OverviewAccountItem> accounts,
    @Default([]) List<OverviewUnpricedHolding> unpricedHoldings,
    @Default(false) bool isOffline,
    DateTime? offlineCachedAt,
    String? failureCode,
    String? failureMessage,
    OverviewNavigation? navigation,
  }) = _OverviewState;
}
