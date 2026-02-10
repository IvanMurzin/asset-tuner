import 'package:asset_tuner/data/asset/dto/asset_dto.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';

abstract final class AssetMapper {
  static AssetEntity toEntity(AssetDto dto) {
    return AssetEntity(
      id: dto.id,
      kind: _kindFromWire(dto.kind),
      code: dto.code,
      name: dto.name,
      decimals: dto.decimals,
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
