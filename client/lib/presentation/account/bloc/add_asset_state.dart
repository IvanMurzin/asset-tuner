part of 'add_asset_cubit.dart';

enum AddAssetStatus { loading, ready, error }

enum AddAssetDestination { signIn, paywall, backAdded }

@freezed
abstract class AddAssetNavigation with _$AddAssetNavigation {
  const factory AddAssetNavigation({required AddAssetDestination destination}) =
      _AddAssetNavigation;
}

@freezed
abstract class AddAssetState with _$AddAssetState {
  const factory AddAssetState({
    @Default(AddAssetStatus.loading) AddAssetStatus status,
    String? accountId,
    String? plan,
    EntitlementsEntity? entitlements,
    AssetKind? selectedKind,
    @Default([]) List<AssetPickerItemEntity> assets,
    @Default([]) List<AssetPickerItemEntity> visibleAssets,
    @Default('') String query,
    String? selectedAssetId,
    @Default('') String name,
    @Default('') String balanceText,
    String? nameError,
    String? balanceError,
    String? failureCode,
    String? failureMessage,
    @Default(0) int totalPositionsCount,
    @Default(false) bool isSaving,
    @Default(false) bool isCatalogLoading,
    AddAssetNavigation? navigation,
  }) = _AddAssetState;
}
