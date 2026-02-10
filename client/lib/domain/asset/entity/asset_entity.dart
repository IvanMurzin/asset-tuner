import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_entity.freezed.dart';

enum AssetKind { fiat, crypto }

@freezed
abstract class AssetEntity with _$AssetEntity {
  const factory AssetEntity({
    required String id,
    required AssetKind kind,
    required String code,
    required String name,
    int? decimals,
  }) = _AssetEntity;
}
