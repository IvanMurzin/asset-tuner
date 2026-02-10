part of 'asset_position_detail_cubit.dart';

enum AssetPositionDetailStatus { loading, ready, error }

enum AssetPositionDetailDestination { signIn }

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
    String? userId,
    String? accountId,
    String? assetId,
    String? accountAssetId,
    String? accountName,
    String? assetCode,
    String? assetName,
    Decimal? currentBalance,
    @Default([]) List<BalanceEntryEntity> entries,
    int? nextOffset,
    @Default(false) bool isLoadingMore,
    String? failureCode,
    String? bannerFailureCode,
    AssetPositionDetailNavigation? navigation,
  }) = _AssetPositionDetailState;
}
