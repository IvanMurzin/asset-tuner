import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';

class AssetPickerItemEntity {
  const AssetPickerItemEntity({
    required this.id,
    required this.kind,
    required this.code,
    required this.name,
    required this.rank,
    required this.isUnlocked,
  });

  final String id;
  final AssetKind kind;
  final String code;
  final String name;
  final int rank;
  final bool isUnlocked;
}
