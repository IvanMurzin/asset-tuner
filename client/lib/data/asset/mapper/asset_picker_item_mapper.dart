import 'package:asset_tuner/data/asset/dto/asset_picker_item_dto.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_picker_item_entity.dart';

abstract final class AssetPickerItemMapper {
  static AssetPickerItemEntity toEntity(AssetPickerItemDto dto) {
    return AssetPickerItemEntity(
      id: dto.id,
      kind: _kindFromWire(dto.kind),
      code: dto.code,
      name: dto.name,
      rank: dto.rank,
      isUnlocked: dto.isUnlocked,
    );
  }

  static AssetKind _kindFromWire(String kind) {
    return switch (kind) {
      'fiat' => AssetKind.fiat,
      'crypto' => AssetKind.crypto,
      _ => AssetKind.fiat,
    };
  }
}
