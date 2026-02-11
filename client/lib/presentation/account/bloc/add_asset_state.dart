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
    @Default([]) List<AssetEntity> assets,
    @Default([]) List<AssetEntity> visibleAssets,
    @Default('') String query,
    @Default(<String>{}) Set<String> existingAssetIds,
    String? selectedAssetId,
    @Default(false) bool duplicateError,
    String? failureCode,
    @Default(0) int totalPositionsCount,
    @Default(false) bool isSaving,
    AddAssetNavigation? navigation,
  }) = _AddAssetState;
}
