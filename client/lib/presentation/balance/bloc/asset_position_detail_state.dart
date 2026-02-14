part of 'asset_position_detail_cubit.dart';

enum AssetPositionDetailStatus { loading, ready, error }

enum AssetPositionDetailDestination { signIn, backDeleted }

@freezed
abstract class AssetPositionDetailNavigation
    with _$AssetPositionDetailNavigation {
  const factory AssetPositionDetailNavigation({
    required AssetPositionDetailDestination destination,
  }) = _AssetPositionDetailNavigation;
}

@freezed
abstract class AssetPositionDetailState with _$AssetPositionDetailState {
  const factory AssetPositionDetailState({
    @Default(AssetPositionDetailStatus.loading)
    AssetPositionDetailStatus status,
    String? accountId,
    String? subaccountId,
    String? accountName,
    String? subaccountName,
    String? assetId,
    String? assetCode,
    String? assetName,
    String? baseCurrency,
    DateTime? ratesAsOf,
    Decimal? currentBalance,
    Decimal? convertedValue,
    @Default(false) bool isUnpriced,
    @Default([]) List<BalanceEntryEntity> entries,
    int? nextOffset,
    @Default(false) bool isLoadingMore,
    @Default(false) bool isMutating,
    String? failureCode,
    String? failureMessage,
    String? bannerFailureCode,
    String? bannerFailureMessage,
    AssetPositionDetailNavigation? navigation,
  }) = _AssetPositionDetailState;
}
