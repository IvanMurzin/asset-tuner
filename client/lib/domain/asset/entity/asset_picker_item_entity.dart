import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';

part 'asset_picker_item_entity.freezed.dart';

@freezed
abstract class AssetPickerItemEntity with _$AssetPickerItemEntity {
  const AssetPickerItemEntity._();

  const factory AssetPickerItemEntity({
    required String id,
    required AssetKind kind,
    required String code,
    required String name,
    String? provider,
    String? providerRef,
    required int rank,
    int? decimals,
    bool? isActive,
    bool? isLocked,
    AssetUsdRateEntity? usdRate,
  }) = _AssetPickerItemEntity;

  bool get isUnlocked => !(isLocked ?? false);
}
