part of 'assets_cubit.dart';

enum AssetsStatus { initial, loading, ready, error }

@freezed
abstract class AssetsState with _$AssetsState {
  const AssetsState._();

  const factory AssetsState({
    @Default(AssetsStatus.initial) AssetsStatus status,
    @Default(<AssetEntity>[]) List<AssetEntity> assets,
    String? failureCode,
    String? failureMessage,
  }) = _AssetsState;

  List<AssetEntity> get fiatAssets =>
      assets.where((item) => item.kind == AssetKind.fiat).toList(growable: false);

  List<AssetEntity> get cryptoAssets =>
      assets.where((item) => item.kind == AssetKind.crypto).toList(growable: false);
}
